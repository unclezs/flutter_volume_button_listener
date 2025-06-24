import Flutter
import UIKit
import AVFoundation
import MediaPlayer

public class VolumeButtonListenerPlugin: NSObject, FlutterPlugin {
    private var methodChannel: FlutterMethodChannel?
    private var isListening = false
    private var showVolumeUI = true
    private var initialVolume: Float = 0.0
    private var volumeTimer: Timer?
    private var lastVolumeChangeTime: Date = Date()
    private var audioSession: AVAudioSession?
    private var customVolumeController: CustomVolumeController?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "volume_button_listener", binaryMessenger: registrar.messenger())
        let instance = VolumeButtonListenerPlugin()
        instance.methodChannel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            initializeAudioSession()
            result(nil)
        case "setShowVolumeUI":
            if let args = call.arguments as? [String: Any],
               let show = args["show"] as? Bool {
                showVolumeUI = show
                updateVolumeControl(show: show)
                print("Volume UI setting changed to: \(show)")
            }
            result(nil)
        case "startListening":
            startListening()
            result(nil)
        case "stopListening":
            stopListening()
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func initializeAudioSession() {
        do {
            audioSession = AVAudioSession.sharedInstance()
            // 使用ambient类别来最小化系统音量UI
            try audioSession?.setCategory(.ambient, mode: .default, options: [])
            try audioSession?.setActive(true)
            
            // 获取初始音量
            initialVolume = audioSession?.outputVolume ?? 0.0
            print("Initial volume: \(initialVolume)")
            
            // 设置自定义音量控制器
            setupCustomVolumeController()
            
        } catch {
            print("Failed to initialize audio session: \(error)")
        }
    }
    
    private func setupCustomVolumeController() {
        customVolumeController = CustomVolumeController()
        customVolumeController?.delegate = self
        print("Custom volume controller initialized")
    }
    
    private func updateVolumeControl(show: Bool) {
        if show {
            // 显示系统音量UI
            try? audioSession?.setCategory(.playback, mode: .default, options: [])
            try? audioSession?.setActive(true)
            print("Switched to system volume control")
        } else {
            // 使用自定义音量控制
            try? audioSession?.setCategory(.ambient, mode: .default, options: [])
            try? audioSession?.setActive(true)
            print("Switched to custom volume control")
        }
    }
    
    private func startListening() {
        isListening = true
        // 重新获取当前音量作为基准
        initialVolume = audioSession?.outputVolume ?? 0.0
        print("Started listening, initial volume: \(initialVolume)")
        
        // 使用定时器定期检查音量变化
        volumeTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.checkVolumeChange()
        }
    }
    
    private func stopListening() {
        isListening = false
        volumeTimer?.invalidate()
        volumeTimer = nil
        print("Stopped listening")
    }
    
    private func checkVolumeChange() {
        guard isListening else { return }
        
        let currentVolume = audioSession?.outputVolume ?? 0.0
        
        // 只有当音量变化超过阈值时才触发
        let threshold: Float = 0.005
        let volumeDiff = abs(currentVolume - initialVolume)
        
        if volumeDiff > threshold {
            let now = Date()
            // 防止过于频繁的触发
            if now.timeIntervalSince(lastVolumeChangeTime) > 0.1 {
                lastVolumeChangeTime = now
                
                print("Volume changed from \(initialVolume) to \(currentVolume)")
                
                // 判断音量变化方向
                if currentVolume > initialVolume {
                    // 音量增加
                    print("Volume UP detected")
                    methodChannel?.invokeMethod("onVolumeButtonPressed", arguments: [
                        "type": "volumeUp",
                        "buttonKey": 24,
                        "buttonName": "Volume Up"
                    ])
                } else if currentVolume < initialVolume {
                    // 音量减少
                    print("Volume DOWN detected")
                    methodChannel?.invokeMethod("onVolumeButtonPressed", arguments: [
                        "type": "volumeDown",
                        "buttonKey": 25,
                        "buttonName": "Volume Down"
                    ])
                }
                
                // 如果不显示音量UI，立即恢复音量
                if !showVolumeUI {
                    print("Volume UI disabled, restoring volume...")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        self.restoreVolume()
                    }
                } else {
                    // 更新初始音量
                    initialVolume = currentVolume
                }
            }
        }
    }
    
    private func restoreVolume() {
        customVolumeController?.setVolume(initialVolume)
        print("Volume restored to: \(initialVolume)")
        
        // 延迟更新初始音量，确保恢复生效
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.initialVolume = self.audioSession?.outputVolume ?? 0.0
        }
    }
    
    deinit {
        stopListening()
    }
}

// MARK: - CustomVolumeControllerDelegate
extension VolumeButtonListenerPlugin: CustomVolumeControllerDelegate {
    func volumeDidChange(_ volume: Float) {
        // 自定义音量控制回调
        print("Custom volume changed to: \(volume)")
    }
}

// MARK: - CustomVolumeController
protocol CustomVolumeControllerDelegate: AnyObject {
    func volumeDidChange(_ volume: Float)
}

class CustomVolumeController {
    weak var delegate: CustomVolumeControllerDelegate?
    private var volumeView: MPVolumeView?
    private var volumeSlider: UISlider?
    
    init() {
        setupVolumeControl()
    }
    
    private func setupVolumeControl() {
        // 创建隐藏的MPVolumeView
        volumeView = MPVolumeView(frame: CGRect.zero)
        volumeView?.isHidden = true
        volumeView?.showsRouteButton = false
        
        // 查找音量滑块
        for subview in volumeView?.subviews ?? [] {
            if let slider = subview as? UISlider {
                volumeSlider = slider
                slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
                print("Custom volume slider found")
                break
            }
        }
        
        // 将volumeView添加到主窗口（隐藏）
        if let window = UIApplication.shared.windows.first {
            window.addSubview(volumeView!)
            volumeView?.frame = CGRect(x: -1000, y: -1000, width: 1, height: 1)
            print("Custom volume view added to window")
        }
    }
    
    func setVolume(_ volume: Float) {
        guard let slider = volumeSlider else {
            print("Volume slider not found")
            return
        }
        
        // 设置音量值
        slider.value = volume
        print("Setting volume to: \(volume)")
        
        // 触发音量变化事件
        slider.sendActions(for: .valueChanged)
    }
    
    @objc private func sliderValueChanged() {
        guard let slider = volumeSlider else { return }
        delegate?.volumeDidChange(slider.value)
    }
    
    deinit {
        volumeView?.removeFromSuperview()
    }
} 