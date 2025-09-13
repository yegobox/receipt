import 'dart:io';
// import 'package:flipper_rw/printer_service.dart';
import 'package:example_receipt/printer_service.dart';
import 'package:jni/jni.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart'; // Import path_provider

class PlatformPrinter {
  Future<void> printFile(Uint8List imageData) async {
    // Save image to documents folder
    await _saveImageToDocuments(imageData);

    if (Platform.isAndroid) {
      PrinterService.getInstance()!.initializePrinter();

      final byteArray = JByteArray.from(imageData);
      final int status = PrinterService.getInstance()!.printNow(byteArray);
      print('Print status: $status');
    }
  }

  Future<void> _saveImageToDocuments(Uint8List imageData) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final String filePath =
          '${directory.path}/receipt_image_${DateTime.now().millisecondsSinceEpoch}.png';
      final File file = File(filePath);
      await file.writeAsBytes(imageData);
      print('Image saved to: $filePath');
    } catch (e) {
      print('Error saving image: $e');
    }
  }
}
