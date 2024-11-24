import 'dart:io';
import 'package:flipper_services/proxy.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;
import 'package:talker_flutter/talker_flutter.dart';

import 'package:sentry_flutter/sentry_flutter.dart';

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
  Future<void> printPdf(
    Uint8List pdfData,
  ) async {
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
  Future<void> savePdfAsImage(Uint8List pdfData) async {
    Map<Permission, PermissionStatus> statuses =
        await [Permission.storage, Permission.manageExternalStorage].request();
    if (statuses[Permission.storage]?.isGranted ?? false) {
      Directory? dir = await getApplicationDocumentsDirectory();
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

  Future<void> sharePdf(
    Uint8List pdfData,
    List<String>? emails,
  ) async {
    try {
      // Fetch printer information
      String filePath = await savePdfToDocumentDirectory(pdfData);

      /// because we are testing with real customer
      /// we are taking a bet that if auto print does not work then we call
      ///  handlePrint(pdfData); to print manually
      /// but we are doing both now to see what is working or if it work both!

      final printingInfo = await Printing.info();
      const defaultPrinter = Printer(url: "", isAvailable: false);
      final talker = TalkerFlutter.init();
      talker.info(printingInfo);

      if (printingInfo.canListPrinters) {
        final printers = await Printing.listPrinters();

        // Pick the first available printer
        final firstAvailablePrinter = printers.firstWhere(
          (printer) => printer.isAvailable,
          orElse: () => defaultPrinter,
        );
        talker.info('first available printer');
        talker.info(firstAvailablePrinter);
        if (firstAvailablePrinter.isAvailable) {
          Sentry.captureMessage("PRINTER_AVAILABLE");
          // Print directly to the first available printer
          await Printing.directPrintPdf(
            printer: firstAvailablePrinter,
            format: PdfPageFormat.roll80,
            onLayout: (PdfPageFormat format) async => pdfData,
          );

          //  await Printing.pickPrinter(
          //   printer: firstAvailablePrinter,
          //   format: PdfPageFormat.roll80,
          //   onLayout: (PdfPageFormat format) async => pdfData,
          // );
        } else {
          // No available printer found, share the PDF via email
          if (Platform.isAndroid || Platform.isIOS) {
            await sharePdfViaEmail(pdfData, emails);
          } else {
            _openOrShareFile(filePath);
          }
        }
      } else {
        // Unable to list printers, share the PDF via email
        if (Platform.isAndroid || Platform.isIOS) {
          await sharePdfViaEmail(pdfData, emails);
        } else {
          _openOrShareFile(filePath);
        }
      }
      // return handlePrint(pdfData);
    } catch (e) {
      // In case of any errors, share the PDF via email
      // await sharePdfViaEmail(pdfData, emails);
      // return handlePrint(pdfData);
    }
  }

  Future<void> _openOrShareFile(String filePath) async {
    await OpenFilex.open(filePath);
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

  Future<String> savePdfToDocumentDirectory(Uint8List pdfData) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = generateFileName();
    final filePath = '${directory.path}/$fileName.pdf';
    final file = File(filePath);
    await file.writeAsBytes(pdfData);
    try {
      ProxyService.local.uploadPdfToS3(pdfData, fileName);
    } catch (e) {
      print(e);
    }
    return filePath;
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
  }) async {
    if (autoPrint!) {
      if (isDesktopOrWeb) {
        await printPdf(pdfData);
      } else {
        await savePdfAsImage(pdfData);
      }
    } else {
      await sharePdf(pdfData, emails);
    }
  }
}
