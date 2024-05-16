import 'dart:io';
import 'dart:typed_data';
import 'package:flipper_models/realm_model_export.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:universal_platform/universal_platform.dart';
import 'dart:ui' as ui;

final isDesktopOrWeb = UniversalPlatform.isDesktopOrWeb;

/// An extension on DateTime that returns a string of date and time separated by space.
extension DateTimeToDateTimeString on DateTime {
  String toDateTimeString() {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm:ss');
    final dateString = dateFormat.format(this);
    final timeString = timeFormat.format(this);
    return '$dateString $timeString';
  }
}

/// An extension that takes a string and applies dashes after every 4 characters.
extension StringToDashedString on String {
  String toDashedString() {
    if (isEmpty) {
      return '';
    }
    var x = 0;
    final dashesInternalData = {2, 3, 4, 12, 6, 7};
    final replacedInternalData = splitMapJoin(RegExp('....'),
        onNonMatch: (s) => dashesInternalData.contains(x++) ? '-' : '');
    return replacedInternalData;
  }
}

class OmniPrinter {
  /// Loads the logo image from assets.
  Future<PdfBitmap> _loadLogoImage({required String position}) async {
    if (position == 'left') {
      final ByteData data = await rootBundle.load('assets/rra.jpg');
      return PdfBitmap(data.buffer.asUint8List());
    } else {
      final ByteData data = await rootBundle.load('assets/rra.jpg');
      return PdfBitmap(data.buffer.asUint8List());
    }
  }

  /// Generates a PDF receipt and handles saving or launching it.
  Future<void> generatePdfAndPrint({
    String brandName = "yegobox shop",
    String brandAddress = "CITY CENTER, Kigali Rwanda",
    String brandTel = "271311123",
    String brandTIN = "1211287390",
    List<String>? emails,
    String? customerTin = "000000000",
    required List<TransactionItem> items,
    required String receiptType,
    required String sdcReceiptNum,
    required String totalTax,
    required double totalB,
    required String totalB18,
    required double totalAEx,
    required double cash,
    required String cashierName,
    required double received,
    required String payMode,
    required String sdcId,
    required String internalData,
    required String receiptSignature,
    required String receiptQrCode,
    required int invoiceNum,
    required String mrc,
    required double totalPayable,
    required ITransaction transaction,
    bool? autoPrint = false,
  }) async {
    final PdfDocument document = PdfDocument();

    // Add a new page to the document.
    final PdfPage page = document.pages.add();

    // Load and draw the logo images.
    final PdfBitmap leftImage = await _loadLogoImage(position: 'left');
    final PdfBitmap rightImage = await _loadLogoImage(position: 'right');
    page.graphics.drawImage(leftImage, const Rect.fromLTWH(0, 0, 150, 150));
    page.graphics.drawImage(
        rightImage,
        Rect.fromLTWH(
            page.getClientSize().width - 150, 0, 150, 150)); // Right alignment

    // Define styles for text and grid.
    final PdfFont contentFont = PdfStandardFont(PdfFontFamily.helvetica, 9);
    final PdfGridStyle gridStyle = PdfGridStyle(
        cellPadding: PdfPaddings(left: 2, right: 2, top: 1, bottom: 2),
        backgroundBrush: PdfBrushes.white,
        textBrush: PdfBrushes.black,
        font: PdfStandardFont(PdfFontFamily.timesRoman, 14));

    // Draw the header section.
    _drawHeader(page, contentFont, brandName, brandAddress, brandTel, brandTIN,
        customerTin);

    // Draw the receipt type information.
    _drawReceiptType(
        page, contentFont, receiptType, sdcReceiptNum, customerTin);

    // Create and draw the items grid.
    final PdfGrid grid = _createItemsGrid(items, gridStyle);
    grid.draw(page: page, bounds: const Rect.fromLTWH(0, 300, 0, 0));

    // Draw the total amount.
    page.graphics.drawString('TOTAL: $totalPayable', contentFont,
        brush: PdfBrushes.black, bounds: const Rect.fromLTWH(0, 450, 400, 30));

    // Draw a dashed line separator.
    _drawDashedLine(page, const Offset(0, 470), const Offset(200, 470));

    // Draw payment information.
    _drawPaymentInfo(page, contentFont, payMode, received, items.length,
        cashierName, transaction);

    // Draw SDC information.
    _drawSDCInfo(page, contentFont, sdcId, sdcReceiptNum, receiptType,
        receiptSignature, internalData, receiptQrCode, transaction);

    // Draw Invoice Number and MRC.
    page.graphics.drawString('INVOICE NUMBER: $invoiceNum', contentFont,
        brush: PdfBrushes.black, bounds: const Rect.fromLTWH(0, 720, 400, 30));
    page.graphics.drawString('MRC: $mrc', contentFont,
        brush: PdfBrushes.black, bounds: const Rect.fromLTWH(0, 730, 400, 30));

    // Draw Thank you and EBM v2.
    page.graphics.drawString('Thank you!', contentFont,
        brush: PdfBrushes.black, bounds: const Rect.fromLTWH(0, 750, 400, 30));
    page.graphics.drawString('EBM v2: v1.12', contentFont,
        brush: PdfBrushes.black, bounds: const Rect.fromLTWH(0, 760, 400, 30));

    // Save the PDF document.
    final List<int> bytes = await document.save();

    // Dispose the document.
    document.dispose();

    // Save and launch the file.
    saveAndLaunchFile(bytes, 'Output.pdf');
  }

  /// Draws the header section of the receipt.
  void _drawHeader(
      PdfPage page,
      PdfFont contentFont,
      String brandName,
      String brandAddress,
      String brandTel,
      String brandTIN,
      String? customerTin) {
    page.graphics.drawString(brandName, contentFont,
        brush: PdfBrushes.black, bounds: const Rect.fromLTWH(0, 150, 400, 30));
    page.graphics.drawString(brandAddress, contentFont,
        brush: PdfBrushes.black, bounds: const Rect.fromLTWH(0, 160, 400, 30));
    page.graphics.drawString("Email: $brandTel", contentFont,
        brush: PdfBrushes.black, bounds: const Rect.fromLTWH(0, 170, 400, 30));
    page.graphics.drawString("TIN  : $brandTIN", contentFont,
        brush: PdfBrushes.black, bounds: const Rect.fromLTWH(0, 180, 400, 30));
    page.graphics.drawString('Welcome to $brandName', contentFont,
        brush: PdfBrushes.black, bounds: const Rect.fromLTWH(0, 200, 400, 30));
    page.graphics.drawString('Client ID: $customerTin', contentFont,
        brush: PdfBrushes.black, bounds: const Rect.fromLTWH(0, 210, 400, 30));
  }

  /// Draws the receipt type information.
  void _drawReceiptType(PdfPage page, PdfFont contentFont, String receiptType,
      String sdcReceiptNum, String? customerTin) {
    switch (receiptType) {
      case "NR":
        page.graphics.drawString('Refund', contentFont,
            brush: PdfBrushes.black,
            bounds: const Rect.fromLTWH(0, 230, 400, 30));
        page.graphics.drawString(
            'REF.NORMAL RECEIPT:# $sdcReceiptNum', contentFont,
            brush: PdfBrushes.black,
            bounds: const Rect.fromLTWH(0, 240, 400, 30));
        page.graphics.drawString(
            'REFUND IS APPROVED FOR CLIENT ID:$customerTin', contentFont,
            brush: PdfBrushes.black,
            bounds: const Rect.fromLTWH(0, 250, 400, 30));
        break;
      case "CS":
        page.graphics.drawString('COPY', contentFont,
            brush: PdfBrushes.black,
            bounds: const Rect.fromLTWH(0, 230, 400, 30));
        page.graphics.drawString(
            'REF.NORMAL RECEIPT#:$sdcReceiptNum', contentFont,
            brush: PdfBrushes.black,
            bounds: const Rect.fromLTWH(0, 240, 400, 30));
        page.graphics.drawString(
            'REFUND IS APPROVED FOR CLIENT ID:$customerTin', contentFont,
            brush: PdfBrushes.black,
            bounds: const Rect.fromLTWH(0, 250, 400, 30));
        break;
      case "TS":
        page.graphics.drawString('TRAINING MODE', contentFont,
            brush: PdfBrushes.black,
            bounds: const Rect.fromLTWH(0, 230, 400, 30));
        break;
      default:
    }
  }

  /// Creates the grid for displaying purchased items.
  PdfGrid _createItemsGrid(
      List<TransactionItem> items, PdfGridStyle gridStyle) {
    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 4);

    final PdfGridRow headerRow = grid.headers.add(1)[0];
    headerRow.cells[0].value = 'Item';
    headerRow.cells[1].value = 'Price';
    headerRow.cells[2].value = 'Qty';
    headerRow.cells[3].value = 'Total';

    for (var item in items) {
      double total = item.price * item.qty;
      String taxLabel = item.isTaxExempted ? "(EX)" : "(B)";
      PdfGridRow row = grid.rows.add();
      row.cells[0].value =
          item.name!.length > 12 ? item.name!.substring(0, 12) : item.name!;
      row.cells[1].value = item.price.toString();
      row.cells[2].value = item.qty.toString();
      row.cells[3].value = '$total $taxLabel';
    }
    grid.style = gridStyle;
    return grid;
  }

  /// Draws a dashed line separator on the PDF page.
  void _drawDashedLine(PdfPage page, Offset start, Offset end) {
    page.graphics.drawLine(PdfPens.gray, start, end);
  }

  /// Draws payment information on the receipt.
  void _drawPaymentInfo(
      PdfPage page,
      PdfFont contentFont,
      String payMode,
      double received,
      int itemCount,
      String cashierName,
      ITransaction transaction) {
    page.graphics.drawString('Pay Mode: $payMode', contentFont,
        brush: PdfBrushes.black, bounds: const Rect.fromLTWH(0, 480, 400, 30));

    // Improve display of payment info
    page.graphics.drawString('Received Amount: $received', contentFont,
        brush: PdfBrushes.black, bounds: const Rect.fromLTWH(0, 490, 400, 30));
    page.graphics.drawString(
        'Change: ${transaction.subTotal - received}', contentFont,
        brush: PdfBrushes.black, bounds: const Rect.fromLTWH(0, 500, 400, 30));

    page.graphics.drawString('ITEMS NUMBER: $itemCount', contentFont,
        brush: PdfBrushes.black, bounds: const Rect.fromLTWH(0, 520, 400, 30));
    page.graphics.drawString('Cashier Name: $cashierName', contentFont,
        brush: PdfBrushes.black, bounds: const Rect.fromLTWH(0, 530, 400, 30));
  }

  /// Draws SDC (Sales Data Controller) information on the receipt.
  void _drawSDCInfo(
      PdfPage page,
      PdfFont contentFont,
      String sdcId,
      String sdcReceiptNum,
      String receiptType,
      String receiptSignature,
      String internalData,
      String receiptQrCode,
      ITransaction transaction) {
    page.graphics.drawString('SDC INFORMATION', contentFont,
        brush: PdfBrushes.black, bounds: const Rect.fromLTWH(0, 560, 400, 30));

    _drawDashedLine(page, const Offset(0, 580), const Offset(200, 580));

    page.graphics.drawString('SDC ID: $sdcId', contentFont,
        brush: PdfBrushes.black, bounds: const Rect.fromLTWH(0, 590, 400, 30));
    page.graphics.drawString(
        'RECEIPT NUMBER: $sdcReceiptNum $receiptType', contentFont,
        brush: PdfBrushes.black, bounds: const Rect.fromLTWH(0, 600, 400, 30));

    // Draw timestamp for SDC info
    page.graphics.drawString(
        transaction.lastTouched?.toDateTimeString() ?? "", contentFont,
        brush: PdfBrushes.black, bounds: const Rect.fromLTWH(0, 610, 400, 30));

    page.graphics.drawString('Receipt Signature: ', contentFont,
        brush: PdfBrushes.black, bounds: const Rect.fromLTWH(0, 630, 400, 30));
    page.graphics.drawString(receiptSignature.toDashedString(), contentFont,
        brush: PdfBrushes.black,
        bounds: const Rect.fromLTWH(100, 630, 400, 30));

    page.graphics.drawString('Internal Data: ', contentFont,
        brush: PdfBrushes.black, bounds: const Rect.fromLTWH(0, 650, 400, 30));
    page.graphics.drawString(internalData.toDashedString(), contentFont,
        brush: PdfBrushes.black,
        bounds: const Rect.fromLTWH(100, 650, 400, 30));

    // Draw QR Code
    _drawQRCode(page, receiptQrCode);
  }

  /// Draws the QR code on the receipt.
  void _drawQRCode(PdfPage page, String qrCodeData) async {
    final qrCodeImage = await _generateQrCodeImage(qrCodeData);
    page.graphics
        .drawImage(qrCodeImage!, const Rect.fromLTWH(150, 670, 100, 100));
  }

  final qrCodeKey = GlobalKey();

  /// qrCodeWidget:
  /// This variable holds a simple Flutter application with a SfBarcodeGenerator widget at its center.
  /// It's not the actual QR code image; it's the Flutter widget structure needed to render the QR code.
  /// RepaintBoundary:
  /// The RepaintBoundary widget is crucial. It creates a separate render object that can be captured as an image.
  /// qrCodeKey:
  /// This GlobalKey is associated with the RepaintBoundary. You use it to find the corresponding RenderRepaintBoundary object in the render tree.
  /// RenderRepaintBoundary.toImage():
  /// You call the toImage() method on the RenderRepaintBoundary object to capture the rendered output of the SfBarcodeGenerator as a ui.Image.
  /// ui.Image to PdfBitmap:
  /// The ui.Image is then converted to byte data (ByteData) and finally to a PdfBitmap, which is what the _generateQrCodeImage function returns.
  Future<PdfBitmap?> _generateQrCodeImage(String qrCodeData) async {
    material.MaterialApp(
      home: material.Scaffold(
        body: Center(
          child: RepaintBoundary(
            key: qrCodeKey,
            child: SfBarcodeGenerator(
              value: qrCodeData,
              symbology: QRCode(),
            ),
          ),
        ),
      ),
    );

    try {
      final boundary =
          qrCodeKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(
          pixelRatio: 3.0); // Adjust pixelRatio for quality
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();
      return PdfBitmap(pngBytes);
    } catch (e) {
      rethrow;
    }
  }

  /// Saves and launches the PDF file.
  Future<void> saveAndLaunchFile(List<int> bytes, String fileName) async {
    final path = (await getApplicationDocumentsDirectory()).path;
    final file = File('$path/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    if (isDesktopOrWeb) {
      await Process.run('start', <String>['$path/$fileName'], runInShell: true);
    } else {
      await OpenFilex.open('$path/$fileName');
    }
  }
}
