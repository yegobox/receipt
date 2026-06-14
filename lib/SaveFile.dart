import 'dart:io';
import 'package:flipper_services/digital_receipt_service.dart';
import 'package:flipper_services/proxy.dart';
import 'package:flipper_services/receipt_sync_service.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:path/path.dart' as p;
import 'package:talker_flutter/talker_flutter.dart';
import 'platform_printer.dart';

final isDesktopOrWeb = UniversalPlatform.isDesktopOrWeb;

mixin SaveFile {
  CustomPaint dashWidget() {
    return CustomPaint(
      size: const PdfPoint(double.infinity, 10),
      painter: (PdfGraphics canvas, PdfPoint size) {
        const double dashWidth = 2.0, dashSpace = 2.0;
        double startX = 0.0;
        while (startX < size.x) {
          canvas
            ..moveTo(startX, 0)
            ..lineTo(startX + dashWidth, 0)
            ..setColor(PdfColors.black)
            ..setLineWidth(0.5)
            ..strokePath();
          startX += dashWidth + dashSpace;
        }
      },
    );
  }

  /// Prints the provided PDF data by sending it to the system printing dialog.
  ///
  /// The `pdfData` parameter contains the raw bytes of the PDF file to print.
  ///
  /// The `name` parameter provides a suggested filename to use in the printing
  /// dialog.
  Future<void> printPdf(Uint8List pdfData,
      {required String transactionId}) async {
    await Printing.layoutPdf(
      name: generateFileName(),
      onLayout: (PdfPageFormat format) async => pdfData,
    );
  }

  /// Saves the provided PDF data as a series of PNG image files,
  /// by rasterizing each page and writing to the downloads directory.
  ///
  /// The `pdfData` parameter contains the raw bytes of the PDF to save.
  ///
  /// This handles requesting permissions, finding the downloads directory,
  /// rasterizing each page, generating a filename, writing the PNG data,
  /// and incrementing the page count.
  Future<void> savePdfAsImage(Uint8List pdfData,
      {required String transactionId, required Uint8List image}) async {
    Directory? dir = await getApplicationSupportDirectory();
    final path = dir.path;
    var i = 0;
    await for (final page in Printing.raster(pdfData, dpi: 1120)) {
      final png = await page.toPng();
      final file = File(p.normalize(
          '$path/page-${i.toString().padLeft(3, generateFileName())}.png'));
      await file.writeAsBytes(png);
      i++;
    }
  }

  /// Shares the provided PDF data by opening the system share sheet.
  ///
  /// The `pdfData` parameter contains the raw bytes of the PDF to share.
  ///
  /// The `filename` parameter provides a suggested filename for the PDF.
  ///
  /// The `subject` and `body` parameters populate the share sheet with
  /// prefilled content.
  ///
  /// The `emails` parameter optionally specifies email addresses to prefill
  /// in the share sheet.

  Future<void> sharePdf(Uint8List pdfData, List<String>? emails,
      {required String transactionId, required Uint8List image}) async {
    try {
      // Save PDF to document directory first (also kicks off the S3 upload)
      String filePath = await savePdfToDocumentDirectory(pdfData,
          transactionId: transactionId);

      // Try to print on a connected printer first; only open the PDF
      // when no printer accepted the job.
      final printed = await _tryDirectPrint(pdfData, image);
      if (!printed) {
        await OpenFilex.open(filePath);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Attempts to print the receipt on a connected printer without showing
  /// any dialog. On Android this targets the device's built-in POS printer;
  /// on desktop it picks the first available system printer.
  ///
  /// Returns true when a printer accepted the job, false otherwise so the
  /// caller can fall back to presenting the PDF.
  Future<bool> _tryDirectPrint(Uint8List pdfData, Uint8List image) async {
    final talker = TalkerFlutter.init();
    try {
      if (!kIsWeb && Platform.isAndroid) {
        return await PlatformPrinter().printFile(image);
      }

      final printingInfo = await Printing.info();
      talker.info(printingInfo);
      if (!printingInfo.canListPrinters) return false;

      final printers = await Printing.listPrinters();
      final firstAvailablePrinter = printers.firstWhere(
        (printer) => printer.isAvailable,
        orElse: () => const Printer(url: "", isAvailable: false),
      );
      if (!firstAvailablePrinter.isAvailable) return false;

      talker.info('PRINTER_AVAILABLE: ${firstAvailablePrinter.name}');
      return await Printing.directPrintPdf(
        printer: firstAvailablePrinter,
        format: PdfPageFormat.roll80,
        onLayout: (PdfPageFormat format) async => pdfData,
      );
    } catch (e) {
      talker.warning('Direct print failed, falling back to PDF: $e');
      return false;
    }
  }

  /// Generates a filename string based on the current date and time,
  /// with hypens, colons, and periods removed.
  ///
  /// This is useful for generating unique filenames for things like
  /// saved files, that include a timestamp.
  String generateFileName() {
    final now = DateTime.now();
    return '${now.year}${_pad(now.month)}${_pad(now.day)}_${_pad(now.hour)}${_pad(now.minute)}${_pad(now.second)}';
  }

  String _pad(int number) {
    return number.toString().padLeft(2, '0');
  }

  Future<String> savePdfToDocumentDirectory(Uint8List pdfData,
      {required String transactionId}) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = generateFileName();
    final filePath = '${directory.path}/$fileName.pdf';
    final file = File(filePath);
    await file.writeAsBytes(pdfData);

    // Run S3 upload in the background to avoid blocking UI
    _uploadToS3InBackground(
      pdfData,
      fileName,
      transactionId,
      localPath: filePath,
    );

    return filePath;
  }

  void _uploadToS3InBackground(
    Uint8List pdfData,
    String fileName,
    String transactionId, {
    required String localPath,
  }) {
    // Fire and forget - don't await this
    Future(() async {
      try {
        await ProxyService.strategy.uploadPdfToS3(
          pdfData,
          fileName,
          transactionId: transactionId,
        );
      } catch (e) {
        if (ReceiptSyncService.isUploadNetworkError(e)) {
          await ReceiptSyncService().queuePendingUpload(
            transactionId: transactionId,
            fileName: fileName,
            localPath: localPath,
            sendSmsAfterUpload: DigitalReceiptService.isQueuedForSms(
              transactionId,
            ),
          );
        } else {
          print('S3 upload error: $e');
        }
      }
    });
  }

  Future<void> sharePdfViaEmail(Uint8List pdfData, List<String>? emails) async {
    final fileName = generateFileName();
    await Printing.sharePdf(
      bytes: pdfData,
      filename: "$fileName.pdf",
      subject: "$fileName-receipt",
      body: "Thank you for visiting our shop",
      emails: emails,
    );
  }

  /// Handles saving and printing/sharing the generated PDF data.
  ///
  /// If autoPrint is true, it will attempt to directly print the PDF
  /// on desktop/web, or save individual PNG pages on mobile.
  ///
  /// If autoPrint is false, it will instead share the PDF data as an
  /// attachment via the provided email addresses.
  ///
  /// The pdfData is the Uint8List containing the actual PDF data.
  /// emails is an optional list of email addresses to share to.
  /// autoPrint defaults to false if not provided.
  Future<void> handlePdfData({
    required Uint8List pdfData,
    required List<String>? emails,
    bool? autoPrint = false,
    bool skipPresentation = false,
    required String transactionId,
    required Uint8List image,
  }) async {
    if (skipPresentation) {
      await DigitalReceiptService.queueSmsAfterReceiptUpload(transactionId);
      await savePdfToDocumentDirectory(
        pdfData,
        transactionId: transactionId,
      );
      return;
    }
    if (autoPrint!) {
      if (isDesktopOrWeb) {
        await printPdf(pdfData, transactionId: transactionId);
      } else {
        await savePdfAsImage(pdfData,
            transactionId: transactionId, image: image);
      }
    } else {
      await sharePdf(pdfData, emails,
          transactionId: transactionId, image: image);
    }
  }
}
