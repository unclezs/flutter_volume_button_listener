import 'package:flutter/material.dart';
import 'package:volume_button_listener/volume_button_listener.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '音量按键监听器示例',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const VolumeButtonListenerDemo(),
    );
  }
}

class VolumeButtonListenerDemo extends StatefulWidget {
  const VolumeButtonListenerDemo({super.key});

  @override
  State<VolumeButtonListenerDemo> createState() =>
      _VolumeButtonListenerDemoState();
}

class _VolumeButtonListenerDemoState extends State<VolumeButtonListenerDemo> {
  bool _isListening = false;
  bool _showVolumeUI = true;
  final List<VolumeButtonEvent> _events = [];

  @override
  void initState() {
    super.initState();
    _initializePlugin();
  }

  Future<void> _initializePlugin() async {
    try {
      await VolumeButtonListener.initialize();
      await VolumeButtonListener.setShowVolumeUI(_showVolumeUI);

      // 监听音量按键事件
      VolumeButtonListener.onVolumeButtonPressed.listen((event) {
        setState(() {
          _events.insert(0, event);
          // 保持最多15个事件
          if (_events.length > 15) {
            _events.removeLast();
          }
        });
      });
    } catch (e) {
      _showError('初始化失败: $e');
    }
  }

  Future<void> _toggleListening() async {
    try {
      if (_isListening) {
        await VolumeButtonListener.stopListening();
      } else {
        await VolumeButtonListener.startListening();
      }
      setState(() {
        _isListening = !_isListening;
      });
    } catch (e) {
      _showError('操作失败: $e');
    }
  }

  Future<void> _toggleVolumeUI() async {
    try {
      await VolumeButtonListener.setShowVolumeUI(!_showVolumeUI);
      setState(() {
        _showVolumeUI = !_showVolumeUI;
      });
    } catch (e) {
      _showError('设置失败: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  IconData _getButtonIcon(VolumeButtonType type) {
    switch (type) {
      case VolumeButtonType.volumeUp:
        return Icons.volume_up;
      case VolumeButtonType.volumeDown:
        return Icons.volume_down;
    }
  }

  Color _getButtonColor(VolumeButtonType type) {
    switch (type) {
      case VolumeButtonType.volumeUp:
        return Colors.green;
      case VolumeButtonType.volumeDown:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('音量按键监听器'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _toggleListening,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _isListening ? Colors.red : Colors.green,
                            ),
                            child: Text(
                              _isListening ? '停止监听' : '开始监听',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _toggleVolumeUI,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _showVolumeUI ? Colors.blue : Colors.orange,
                            ),
                            child: Text(
                              _showVolumeUI ? '隐藏音量UI' : '显示音量UI',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          _isListening ? Icons.volume_up : Icons.volume_off,
                          color: _isListening ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text('监听状态: ${_isListening ? "开启" : "关闭"}'),
                        const Spacer(),
                        Icon(
                          _showVolumeUI
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: _showVolumeUI ? Colors.blue : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text('音量UI: ${_showVolumeUI ? "显示" : "隐藏"}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '音量按键事件记录:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Card(
                child: _events.isEmpty
                    ? const Center(
                        child: Text(
                          '暂无事件记录\n请开始监听并按下音量按键',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _events.length,
                        itemBuilder: (context, index) {
                          final event = _events[index];
                          return ListTile(
                            leading: Icon(
                              _getButtonIcon(event.type),
                              color: _getButtonColor(event.type),
                            ),
                            title: Text(
                              event.buttonName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('按键代码: ${event.buttonKey}'),
                                Text(
                                  '时间: ${event.timestamp.toString().substring(11, 19)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            trailing: Text(
                              '#${_events.length - index}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    VolumeButtonListener.dispose();
    super.dispose();
  }
}
