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
      // Save PDF to document directory first (this is fast)
      String filePath = await savePdfToDocumentDirectory(pdfData,
          transactionId: transactionId);

      // For Android, always trigger printing immediately
      // for debugging we also print on maocs to save image and be able to troubleshoot
      if (Platform.isAndroid || Platform.isMacOS && !kIsWeb) {
        // This ensures printing happens regardless of path
        PlatformPrinter().printFile(image);
      }

      // Immediately open/share file without waiting for printer checks
      if (Platform.isAndroid && !kIsWeb) {
        // Open file immediately
        await OpenFilex.open(filePath);
      } else {
        await OpenFilex.open(filePath);
      }

      // The rest of the printer detection logic can run in background
      // We're removing the call to _openOrShareFile from _checkPrintersInBackground
      // to avoid opening the file twice
      _checkPrintersInBackground(filePath, pdfData, image, emails,
          skipFileOpen: true);
    } catch (e) {
      rethrow;
    }
  }

  void _checkPrintersInBackground(
      String filePath, Uint8List pdfData, Uint8List image, List<String>? emails,
      {bool skipFileOpen = false}) {
    Future(() async {
      try {
        final printingInfo = await Printing.info();
        const defaultPrinter = Printer(url: "", isAvailable: false);
        final talker = TalkerFlutter.init();
        talker.info(printingInfo);

        if (!Platform.isAndroid && !Platform.isIOS) {
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
              talker.info('PRINTER_AVAILABLE');
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
                // await sharePdfViaEmail(pdfData, emails);
                if (!skipFileOpen) {
                  _openOrShareFile(filePath, bytes: pdfData, image: image);
                }
              } else {
                if (!skipFileOpen) {
                  _openOrShareFile(filePath, bytes: pdfData, image: image);
                }
              }
            }
          } else {
            // Unable to list printers, share the PDF via email
            if (Platform.isAndroid || Platform.isIOS) {
              // await sharePdfViaEmail(pdfData, emails);
              if (!skipFileOpen) {
                _openOrShareFile(filePath, bytes: pdfData, image: image);
              }
            } else {
              if (!skipFileOpen) {
                _openOrShareFile(filePath, bytes: pdfData, image: image);
              }
            }
          }
        } else {
          // For Android and iOS devices
          if (Platform.isAndroid || Platform.isIOS) {
            // await sharePdfViaEmail(pdfData, emails);
            if (!skipFileOpen) {
              _openOrShareFile(filePath, bytes: pdfData, image: image);
            }
          } else {
            if (!skipFileOpen) {
              _openOrShareFile(filePath, bytes: pdfData, image: image);
            }
          }
        }
      } catch (e) {
        print('Printer check error: $e');
      }
    });
  }

  Future<void> _openOrShareFile(String filePath,
      {required Uint8List bytes, required Uint8List image}) async {
    if (Platform.isAndroid || Platform.isMacOS && !kIsWeb) {
      // Start printing in background
      PlatformPrinter().printFile(image);
    }
    // Open file immediately
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
