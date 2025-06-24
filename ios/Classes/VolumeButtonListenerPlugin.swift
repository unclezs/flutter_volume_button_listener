import Flutter
import UIKit
import AVFoundation

public class VolumeButtonListenerPlugin: NSObject, FlutterPlugin {
    private var methodChannel: FlutterMethodChannel?
    private var isListening = false
    private var showVolumeUI = true
    private var initialVolume: Float = 0.0
    
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
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
            
            // 获取初始音量
            initialVolume = audioSession.outputVolume
            
            // 添加音量变化通知
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(volumeChanged),
                name: AVAudioSession.outputVolumeDidChangeNotification,
                object: nil
            )
        } catch {
            print("Failed to initialize audio session: \(error)")
        }
    }
    
    @objc private func volumeChanged() {
        guard isListening else { return }
        
        let audioSession = AVAudioSession.sharedInstance()
        let currentVolume = audioSession.outputVolume
        
        // 判断音量变化方向
        if currentVolume > initialVolume {
            // 音量增加
            methodChannel?.invokeMethod("onVolumeButtonPressed", arguments: ["type": "volumeUp"])
        } else if currentVolume < initialVolume {
            // 音量减少
            methodChannel?.invokeMethod("onVolumeButtonPressed", arguments: ["type": "volumeDown"])
        }
        
        // 更新初始音量
        initialVolume = currentVolume
        
        // 如果不显示音量UI，立即恢复音量
        if !showVolumeUI {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.restoreVolume()
            }
        }
    }
    
    private func startListening() {
        isListening = true
        // 重新获取当前音量作为基准
        initialVolume = AVAudioSession.sharedInstance().outputVolume
    }
    
    private func stopListening() {
        isListening = false
    }
    
    private func restoreVolume() {
        // 这里可以通过 MPVolumeView 来设置音量，但需要额外的实现
        // 为了简化，这里只是记录音量变化事件
        print("Volume change detected, UI display: \(showVolumeUI)")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
} 