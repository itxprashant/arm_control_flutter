import 'package:flutter/material.dart';
import 'serial_service.dart';

class SerialHomePage extends StatefulWidget {
  @override
  _SerialHomeState createState() => _SerialHomeState();
}

class _SerialHomeState extends State<SerialHomePage> {
  final SerialService _serialService = SerialService();
  final TextEditingController _controller = TextEditingController();
  String _output = '';

  @override
  void initState() {
    super.initState();
    _connectToDevice();
  }

  Future<void> _connectToDevice() async {
    bool connected = await _serialService.connectToDevice();
    if (connected) {
      _serialService.getInputStream()?.listen((data) {
        setState(() {
          _output += data;
        });
      });
    } else {
      setState(() {
        _output = 'Failed to connect to device';
      });
    }
  }

  Future<void> _sendData() async {
    await _serialService.sendData(_controller.text);
  }

  @override
  void dispose() {
    _serialService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Serial Communication')),
      body: Column(
        children: [
          TextField(controller: _controller),
          ElevatedButton(onPressed: _sendData, child: Text('Send')),
          Expanded(child: SingleChildScrollView(child: Text(_output))),
        ],
      ),
    );
  }
}
