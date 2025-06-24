import 'dart:async';

import 'package:flutter/services.dart';

/// 硬件按键事件
class HardwareButton {
  /// 按键代码
  final int buttonKey;

  /// 按键名称
  final String buttonName;

  /// 事件时间戳
  final DateTime timestamp;

  HardwareButton({
    required this.buttonKey,
    required this.buttonName,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'HardwareButton(buttonKey: $buttonKey, buttonName: $buttonName, timestamp: $timestamp)';
  }
}

/// 硬件按键监听器
class HardwareButtonListener {
  static const MethodChannel _channel = MethodChannel('volume_button_listener');

  /// 硬件按键事件流控制器
  static final StreamController<HardwareButton> _eventController =
      StreamController<HardwareButton>.broadcast();

  /// 硬件按键事件流
  static Stream<HardwareButton> get onHardwareButtonPressed =>
      _eventController.stream;

  /// 是否显示音量UI
  static bool _showVolumeUI = true;

  /// 获取当前是否显示音量UI
  static bool get showVolumeUI => _showVolumeUI;

  /// 初始化插件
  static Future<void> initialize() async {
    _channel.setMethodCallHandler(_handleMethodCall);
    await _channel.invokeMethod('initialize');
  }

  /// 设置是否显示音量UI
  static Future<void> setShowVolumeUI(bool show) async {
    _showVolumeUI = show;
    await _channel.invokeMethod('setShowVolumeUI', {'show': show});
  }

  /// 开始监听硬件按键
  static Future<void> startListening() async {
    await _channel.invokeMethod('startListening');
  }

  /// 停止监听硬件按键
  static Future<void> stopListening() async {
    await _channel.invokeMethod('stopListening');
  }

  /// 处理来自原生平台的方法调用
  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onVolumeButtonPressed':
        final String typeString = call.arguments['type'] as String;
        final int buttonKey = call.arguments['buttonKey'] as int? ?? 0;
        final String buttonName =
            call.arguments['buttonName'] as String? ?? typeString;

        final event = HardwareButton(
          buttonKey: buttonKey,
          buttonName: buttonName,
          timestamp: DateTime.now(),
        );

        _eventController.add(event);
        break;
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: 'Method ${call.method} not implemented',
        );
    }
  }

  /// 释放资源
  static void dispose() {
    _eventController.close();
  }
}

/// 音量按键事件类型
enum VolumeButtonType {
  /// 音量增加
  volumeUp,

  /// 音量减少
  volumeDown,
}

/// 音量按键事件
class VolumeButtonEvent {
  /// 按键类型
  final VolumeButtonType type;

  /// 按键代码
  final int buttonKey;

  /// 按键名称
  final String buttonName;

  /// 事件时间戳
  final DateTime timestamp;

  VolumeButtonEvent({
    required this.type,
    required this.buttonKey,
    required this.buttonName,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'VolumeButtonEvent(type: $type, buttonKey: $buttonKey, buttonName: $buttonName, timestamp: $timestamp)';
  }
}

/// 音量按键监听器
class VolumeButtonListener {
  static const MethodChannel _channel = MethodChannel('volume_button_listener');

  /// 音量按键事件流控制器
  static final StreamController<VolumeButtonEvent> _eventController =
      StreamController<VolumeButtonEvent>.broadcast();

  /// 音量按键事件流
  static Stream<VolumeButtonEvent> get onVolumeButtonPressed =>
      _eventController.stream;

  /// 是否显示音量UI
  static bool _showVolumeUI = true;

  /// 获取当前是否显示音量UI
  static bool get showVolumeUI => _showVolumeUI;

  /// 初始化插件
  static Future<void> initialize() async {
    _channel.setMethodCallHandler(_handleMethodCall);
    await _channel.invokeMethod('initialize');
  }

  /// 设置是否显示音量UI
  static Future<void> setShowVolumeUI(bool show) async {
    _showVolumeUI = show;
    await _channel.invokeMethod('setShowVolumeUI', {'show': show});
  }

  /// 开始监听音量按键
  static Future<void> startListening() async {
    await _channel.invokeMethod('startListening');
  }

  /// 停止监听音量按键
  static Future<void> stopListening() async {
    await _channel.invokeMethod('stopListening');
  }

  /// 处理来自原生平台的方法调用
  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onVolumeButtonPressed':
        final String typeString = call.arguments['type'] as String;
        final int buttonKey = call.arguments['buttonKey'] as int? ?? 0;
        final String buttonName =
            call.arguments['buttonName'] as String? ?? typeString;

        final VolumeButtonType type = typeString == 'volumeUp'
            ? VolumeButtonType.volumeUp
            : VolumeButtonType.volumeDown;

        final event = VolumeButtonEvent(
          type: type,
          buttonKey: buttonKey,
          buttonName: buttonName,
          timestamp: DateTime.now(),
        );

        _eventController.add(event);
        break;
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: 'Method ${call.method} not implemented',
        );
    }
  }

  /// 释放资源
  static void dispose() {
    _eventController.close();
  }
}
