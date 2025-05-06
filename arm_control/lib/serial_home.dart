import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:usb_serial/usb_serial.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arduino Serial App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SerialHomePage(),
    );
  }
}

class SerialHomePage extends StatefulWidget {
  @override
  _SerialHomePageState createState() => _SerialHomePageState();
}

class _SerialHomePageState extends State<SerialHomePage> {
  UsbPort? _port;
  String _status = "Disconnected";
  String _receivedData = "";
  TextEditingController _controller = TextEditingController();

  void _connectToDevice() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();
    if (devices.isEmpty) {
      setState(() => _status = "No USB device found");
      return;
    }

    UsbPort? port = await devices[0].create();
    bool open = await (port?.open() ?? Future.value(false));
    if (!open) {
      setState(() => _status = "Failed to open port");
      return;
    }

    await port?.setDTR(true);
    await port?.setRTS(true);
    await port?.setPortParameters(
      9600,
      UsbPort.DATABITS_8,
      UsbPort.STOPBITS_1,
      UsbPort.PARITY_NONE,
    );

    port!.inputStream?.listen((Uint8List data) {
      setState(() {
        _receivedData += String.fromCharCodes(data);
      });
    });

    setState(() {
      _port = port;
      _status = "Connected to ${devices[0].productName}";
    });
  }

  void _sendData(String text) {
    if (_port == null) return;
    _port!.write(Uint8List.fromList("$text\n".codeUnits));
  }

  @override
  void dispose() {
    _port?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Arduino Serial USB")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Status: $_status"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _connectToDevice,
              child: Text("Connect to Arduino"),
            ),
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: "Enter message"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _sendData(_controller.text),
              child: Text("Send"),
            ),
            SizedBox(height: 20),
            Text("Received Data:"),
            Expanded(child: SingleChildScrollView(child: Text(_receivedData))),
          ],
        ),
      ),
    );
  }
}
