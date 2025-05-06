import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:usb_serial/usb_serial.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Servo Control',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ServoControlPage(),
    );
  }
}

class ServoControlPage extends StatefulWidget {
  @override
  _ServoControlPageState createState() => _ServoControlPageState();
}

class _ServoControlPageState extends State<ServoControlPage> {
  UsbPort? _port;
  List<int> _angles = List.filled(5, 90);
  List<String> _motorNames = ["Base", "Shoulder", "Elbow", "Wrist", "Gripper"];
  String _connectionStatus = "Disconnected";

  @override
  void initState() {
    super.initState();
    _connectToDevice();
  }

  void _connectToDevice() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();
    if (devices.isEmpty) return;

    UsbPort? port = await devices[0].create();
    bool open = await (port?.open() ?? Future.value(false));
    if (!open) return;

    await port?.setDTR(true);
    await port?.setRTS(true);
    await port?.setPortParameters(
      9600,
      UsbPort.DATABITS_8,
      UsbPort.STOPBITS_1,
      UsbPort.PARITY_NONE,
    );

    setState(() {
      _port = port;
    });
  }

  void _connectToArduino() async {
    try {
      // Replace with your connection logic
      List<UsbDevice> devices = await UsbSerial.listDevices();
      if (devices.isNotEmpty) {
        _port = await devices[0].create();
        bool open = await (_port?.open() ?? Future.value(false));
        if (open) {
          await _port?.setDTR(true);
          await _port?.setRTS(true);
          await _port?.setPortParameters(
            9600,
            UsbPort.DATABITS_8,
            UsbPort.STOPBITS_1,
            UsbPort.PARITY_NONE,
          );
          setState(() {
            _connectionStatus = "Connected";
          });
        } else {
          setState(() {
            _connectionStatus = "Connection Failed";
          });
        }
      } else {
        setState(() {
          _connectionStatus = "No Devices Found";
        });
      }
      setState(() {
        _connectionStatus = "Connected";
      });
    } catch (e) {
      setState(() {
        _connectionStatus = "Connection Failed";
      });
    }
  }

  void _sendAngle(int motorIndex, int angle) {
    if (_port == null) return;
    String command = "$motorIndex:$angle\n";
    _port!.write(Uint8List.fromList(command.codeUnits));
  }

  int _currentDirection = 0;
  void _sendStepperAngle(int angle) {
    if (_port == null) return;
    if (_currentDirection == 0 & angle > 0) {
      String command = "rotate $angle\n";
      _port!.write(Uint8List.fromList(command.codeUnits));
    } else if (_currentDirection == 1 & angle < 0) {
      String command = "rotate $angle\n";
      _port!.write(Uint8List.fromList(command.codeUnits));
    } else if (_currentDirection == 1 & angle > 0) {
      String command = "dir\n";
      _port!.write(Uint8List.fromList(command.codeUnits));
      // set state of current direction to 0
      setState(() {
        _currentDirection = 0;
      });

      String command2 = "rotate $angle\n";
      _port!.write(Uint8List.fromList(command2.codeUnits));
    } else if (_currentDirection == 0 & angle < 0) {
      String command = "dir\n";
      _port!.write(Uint8List.fromList(command.codeUnits));
      // set state of current direction to 1
      setState(() {
        _currentDirection = 0;
      });

      String command2 = "rotate $angle\n";
      _port!.write(Uint8List.fromList(command2.codeUnits));
    }
  }

  void _adjustAngle(int motorIndex, int delta) {
    setState(() {
      _angles[motorIndex] = (_angles[motorIndex] + delta).clamp(-720, 720);
      _sendAngle(motorIndex, _angles[motorIndex]);
    });
  }

  @override
  void dispose() {
    _port?.close();
    super.dispose();
  }

  Widget _buildServoControl(int index) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text('${_motorNames[index]} — Angle: ${_angles[index]}°'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_left),
              onPressed: () => _adjustAngle(index, -5),
            ),
            IconButton(
              icon: Icon(Icons.arrow_right),
              onPressed: () => _adjustAngle(index, 5),
            ),
          ],
        ),
      ),
    );
  }

  int? _StepperSteps = 100;
  TextEditingController _stepController = TextEditingController(text: "100");
  Widget _angleStepInput() {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text('Angle Step'),
        subtitle: TextField(
          controller: _stepController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: 'Enter step value'),
          onSubmitted: (value) {
            setState(() {
              _StepperSteps = int.tryParse(value);
            });
          },
        ),
      ),
    );
  }

  Widget _stepperControl() {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text('Stepper Motor'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                int? step = int.tryParse(_stepController.text);
                if (step != null) {
                  _sendStepperAngle(step);
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: () {
                int? step = int.tryParse(_stepController.text);
                if (step != null) {
                  _sendStepperAngle(-step);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _gripperControl() {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text('Gripper'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {
                _sendAngle(4, 90); // Open gripper
              },
              child: Text('Open'),
            ),
            TextButton(
              onPressed: () {
                _sendAngle(4, 5); // Close gripper
              },
              child: Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Servo Controller')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _connectToArduino,
              child: Text('Connect to Arduino'),
            ),
            Text('Status: $_connectionStatus'),
            Expanded(
              child: ListView.builder(
                itemCount: _angles.length,
                itemBuilder:
                    (context, index) =>
                        index > 0
                            ? _buildServoControl(index)
                            : SizedBox.shrink(),
              ),
            ),
            _gripperControl(),
            _angleStepInput(),
            _stepperControl(),
          ],
        ),
      ),
    );
  }
}
