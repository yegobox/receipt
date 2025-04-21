import 'dart:io';
import 'package:flipper_rw/printer_service.dart';
import 'package:jni/jni.dart';
import 'dart:typed_data';

class PlatformPrinter {
  void printFile(Uint8List imageData) {
    if (Platform.isAndroid) {
      PrinterService.getInstance()?.initializePrinter();
      try {
        // 1. Convert Uint8List to JByteArray
        final byteArray = JByteArray.from(imageData);

        // 2. Call the printer.printNow function with the JByteArray
        final int status = PrinterService.getInstance()!.printNow(byteArray);

        if (status != 0) {
          throw Exception('Failed to print file');
        }
      } catch (e) {
        throw Exception('Failed to print file: $e');
      }
    }
  }
}
