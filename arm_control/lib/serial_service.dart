import 'dart:typed_data';
import 'package:usb_serial/usb_serial.dart';
import 'package:usb_serial/transaction.dart';

class SerialService {
  UsbPort? _port;
  Transaction<String>? _transaction;

  Future<bool> connectToDevice() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();
    if (devices.isNotEmpty) {
      _port = await devices[0].create();
      bool openResult = await _port!.open();
      if (openResult) {
        await _port!.setDTR(true);
        await _port!.setRTS(true);
        await _port!.setPortParameters(
          9600,
          UsbPort.DATABITS_8,
          UsbPort.STOPBITS_1,
          UsbPort.PARITY_NONE,
        );
        _transaction = Transaction.stringTerminated(
          _port!.inputStream!,
          Uint8List.fromList([13, 10]), // \r\n
        );
        return true;
      }
    }
    return false;
  }

  Stream<String>? getInputStream() {
    return _transaction?.stream;
  }

  Future<void> sendData(String data) async {
    if (_port != null) {
      await _port!.write(Uint8List.fromList(data.codeUnits));
    }
  }

  Future<void> disconnect() async {
    _transaction?.dispose();
    await _port?.close();
    _port = null;
  }
}
