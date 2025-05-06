import 'package:flutter/material.dart';
import 'package:usb_serial/usb_serial.dart';
import 'package:usb_serial/transaction.dart';
import 'dart:typed_data';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceControlPage extends StatefulWidget {
  const VoiceControlPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _VoiceControlPage createState() => _VoiceControlPage();
}

class _VoiceControlPage extends State<VoiceControlPage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "Press the button to start listening";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() {
          _isListening = true;
          _text = "Listening...";
        });
        _speech.listen(
          onResult: (val) {
            setState(() {
              _text = val.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() {
        _isListening = false;
        _text = "Press the button to start listening";
      });
      _speech.stop();
    }
  }

  void _stopListening() {
    if (_isListening) {
      setState(() {
        _isListening = false;
        _text = "Press the button to start listening";
      });
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Voice control page"),
            const SizedBox(height: 20),
            Text(_text, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isListening ? _stopListening : _startListening,
              child: Text(_isListening ? "Stop Listening" : "Start Listening"),
            ),
          ],
        ),
      ),
    );
  }
}
