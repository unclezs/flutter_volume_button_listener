# Volume Button Listener

一个 Flutter 插件，用于监听系统音量按键事件并控制音量UI的显示。

## 功能特性

- 🔍 监听音量增加和减少按键事件
- 🎛️ 控制是否显示系统音量UI
- 📱 支持 Android 和 iOS 平台
- ⚡ 实时事件流处理
- 🛡️ 安全的资源管理
- 🔢 提供按键代码和按键名称信息

## 平台支持

- **Android**: 通过按键事件监听实现
- **iOS**: 通过 AVAudioSession 监听音量变化

## 安装

在你的 `pubspec.yaml` 文件中添加依赖：

```yaml
dependencies:
  volume_button_listener: ^1.0.0
```

然后运行：

```bash
flutter pub get
```

## 使用方法

### 1. 初始化插件

```dart
import 'package:volume_button_listener/volume_button_listener.dart';

// 初始化插件
await VolumeButtonListener.initialize();
```

### 2. 监听音量按键事件

```dart
// 监听音量按键事件
VolumeButtonListener.onVolumeButtonPressed.listen((event) {
  print('音量按键事件: ${event.type}');
  print('按键代码: ${event.buttonKey}');
  print('按键名称: ${event.buttonName}');
  print('时间戳: ${event.timestamp}');
  
  switch (event.type) {
    case VolumeButtonType.volumeUp:
      print('音量增加');
      break;
    case VolumeButtonType.volumeDown:
      print('音量减少');
      break;
  }
});
```

### 3. 控制音量UI显示

```dart
// 隐藏音量UI
await VolumeButtonListener.setShowVolumeUI(false);

// 显示音量UI
await VolumeButtonListener.setShowVolumeUI(true);
```

### 4. 开始/停止监听

```dart
// 开始监听
await VolumeButtonListener.startListening();

// 停止监听
await VolumeButtonListener.stopListening();
```

### 5. 完整示例

```dart
import 'package:flutter/material.dart';
import 'package:volume_button_listener/volume_button_listener.dart';

class VolumeButtonDemo extends StatefulWidget {
  @override
  _VolumeButtonDemoState createState() => _VolumeButtonDemoState();
}

class _VolumeButtonDemoState extends State<VolumeButtonDemo> {
  bool _isListening = false;
  bool _showVolumeUI = true;
  final List<VolumeButtonEvent> _events = [];

  @override
  void initState() {
    super.initState();
    _initializePlugin();
  }

  Future<void> _initializePlugin() async {
    await VolumeButtonListener.initialize();
    await VolumeButtonListener.setShowVolumeUI(_showVolumeUI);
    
    VolumeButtonListener.onVolumeButtonPressed.listen((event) {
      setState(() {
        _events.insert(0, event);
      });
    });
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await VolumeButtonListener.stopListening();
    } else {
      await VolumeButtonListener.startListening();
    }
    setState(() {
      _isListening = !_isListening;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('音量按键监听器')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _toggleListening,
            child: Text(_isListening ? '停止监听' : '开始监听'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final event = _events[index];
                return ListTile(
                  title: Text(event.buttonName),
                  subtitle: Text('按键代码: ${event.buttonKey}'),
                  trailing: Text(event.timestamp.toString().substring(11, 19)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    VolumeButtonListener.dispose();
    super.dispose();
  }
}
```

## API 参考

### VolumeButtonListener

主要的插件类，提供静态方法来控制音量按键监听。

#### 方法

- `initialize()`: 初始化插件
- `startListening()`: 开始监听音量按键
- `stopListening()`: 停止监听音量按键
- `setShowVolumeUI(bool show)`: 设置是否显示音量UI
- `dispose()`: 释放资源

#### 属性

- `onVolumeButtonPressed`: 音量按键事件流
- `showVolumeUI`: 获取当前是否显示音量UI

### VolumeButtonEvent

音量按键事件类。

#### 属性

- `type`: 按键类型 (VolumeButtonType.volumeUp 或 VolumeButtonType.volumeDown)
- `buttonKey`: 按键代码 (24: 音量增加, 25: 音量减少)
- `buttonName`: 按键名称 ("Volume Up" 或 "Volume Down")
- `timestamp`: 事件时间戳

### VolumeButtonType

音量按键类型枚举。

- `volumeUp`: 音量增加
- `volumeDown`: 音量减少

## 注意事项

1. **Android 权限**: 确保应用有适当的权限来监听按键事件
2. **音量UI控制**: 当 `setShowVolumeUI(false)` 时，音量按键事件会被消费，不会显示系统音量UI
3. **按键代码**: 
   - 24: 音量增加按键 (KEYCODE_VOLUME_UP)
   - 25: 音量减少按键 (KEYCODE_VOLUME_DOWN)

## 更新日志

### v1.0.0
- 初始版本，支持基本的音量按键监听
- 支持控制音量UI显示
- 提供按键代码和按键名称信息

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License 