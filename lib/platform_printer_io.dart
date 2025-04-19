import 'dart:io';
import 'package:flipper_rw/printer_service.dart';
import 'package:jni/jni.dart';

class PlatformPrinter {
  void printFile(String filePath) {
    if (Platform.isAndroid) {
      final printer = PrinterService();
      printer.printNow(filePath.toJString());
    }
  }
}
