import 'dart:io';
import 'dart:typed_data';
import 'package:flipper_models/helperModels/random.dart';
import 'package:flipper_models/realm_model_export.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:receipt/printable.dart';
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

class SignableOmniPrinter implements Printable {
  /// Loads the logo image from assets.
  Future<PdfBitmap> _loadLogoImage({required String position}) async {
    if (position == 'left') {
      final ByteData data = await rootBundle.load('assets/logo_left.png');
      return PdfBitmap(data.buffer.asUint8List());
    } else {
      final ByteData data = await rootBundle.load('assets/logo_right.png');
      return PdfBitmap(data.buffer.asUint8List());
    }
  }

  /// Generates a PDF receipt and handles saving or launching it.
  @override
  Future<void> generatePdfAndPrint({
    required String customerName,
    String brandName = "Q Coffee Ltd",
    String brandAddress = "Kigali City",
    String brandTel = "0781968027",
    String brandTIN = "106536281",
    String brandDescription = "We build app that server you!",
    String brandFooter = "yegobox shop",
    List<String>? emails,
    String? customerTin = "121898608",
    required List<TransactionItem> items,
    required String receiptType,
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
    required double totalTaxA,
    required double totalTaxB,
    required double totalTaxC,
    required double totalTaxD,
    required String totalTax,
  }) async {
    // Calculate paper width in pixels

    final PdfDocument document = PdfDocument();

    document.pageSettings =
        PdfPageSettings(const Size(250, 600), PdfPageOrientation.portrait);
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
    _drawReceiptType(page, contentFont, receiptType, "NS", customerTin);

    // Create and draw the items grid.
    final PdfGrid grid = _createItemsGrid(items, gridStyle);
    grid.draw(page: page, bounds: const Rect.fromLTWH(0, 180, 0, 0));

    // Draw the total amount.
    page.graphics.drawString('TOTAL: $totalPayable', contentFont,
        brush: PdfBrushes.black, bounds: const Rect.fromLTWH(0, 330, 400, 30));

    // Draw a dashed line separator.
    _drawDashedLine(page, const Offset(0, 350), const Offset(200, 350));

    // Draw payment information.
    _drawPaymentInfo(page, contentFont, payMode, received, items.length,
        cashierName, transaction);

    // Draw SDC information.
    _drawSDCInfo(page, contentFont, sdcId, "NS", receiptType, receiptSignature,
        internalData, receiptQrCode, transaction);

    // Draw Invoice Number and MRC.
    page.graphics.drawString('INVOICE NUMBER: $invoiceNum', contentFont,
        brush: PdfBrushes.black, bounds: const Rect.fromLTWH(0, 620, 400, 30));
    page.graphics.drawString('MRC: $mrc', contentFont,
        brush: PdfBrushes.black, bounds: const Rect.fromLTWH(0, 630, 400, 30));

    // Draw Thank you and EBM v2.
    page.graphics.drawString('Thank you!', contentFont,
        brush: PdfBrushes.black, bounds: const Rect.fromLTWH(0, 650, 400, 30));
    page.graphics.drawString('EBM v2: v1.12', contentFont,
        brush: PdfBrushes.black, bounds: const Rect.fromLTWH(0, 660, 400, 30));

    // Save the PDF document.
    final List<int> bytes = await document.save();

    document.dispose();

    // Save and launch the file.
    saveAndLaunchFile(bytes, '${randomString()}.pdf');
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
    double lineHeight = 15.0; // Adjust for desired line spacing
    double yPos = 150.0; // Initial vertical position

    // Brand name (centered)
    final double brandNameWidth = contentFont.measureString(brandName).width;
    page.graphics.drawString(brandName, contentFont,
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH((page.getClientSize().width - brandNameWidth) / 2,
            yPos, brandNameWidth, lineHeight));
    yPos += lineHeight; // Move to the next line

    // Brand Address
    page.graphics.drawString(brandAddress, contentFont,
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH(0, yPos, page.getClientSize().width, lineHeight));
    yPos += lineHeight;

    // Brand Email (adjust width if needed)
    page.graphics.drawString("Email: $brandTel", contentFont,
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH(0, yPos, 200, lineHeight));
    yPos += lineHeight;

    // Brand TIN (adjust width if needed)
    page.graphics.drawString("TIN  : $brandTIN", contentFont,
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH(0, yPos, 200, lineHeight));
    yPos += lineHeight;

    // Welcome message (centered)
    final double welcomeWidth =
        contentFont.measureString('Welcome to $brandName').width;
    page.graphics.drawString('Welcome to $brandName', contentFont,
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH((page.getClientSize().width - welcomeWidth) / 2,
            yPos, welcomeWidth, lineHeight));
    yPos += lineHeight;

    // Customer ID
    page.graphics.drawString('CLIENT: UNKNOWN', contentFont,
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH(0, yPos, page.getClientSize().width, lineHeight));
    yPos += lineHeight;

    // Customer TIN
    page.graphics.drawString('CLIENT TIN: $customerTin', contentFont,
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH(0, yPos, page.getClientSize().width, lineHeight));
  }

  void _drawCenteredText(PdfPage page, PdfFont font, String text, double yPos) {
    final double textWidth = font.measureString(text).width;
    page.graphics.drawString(text, font,
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH((page.getClientSize().width - textWidth) / 2,
            yPos, textWidth, font.height));
  }

  /// Draws the receipt type information.
  void _drawReceiptType(PdfPage page, PdfFont contentFont, String receiptType,
      String sdcReceiptNum, String? customerTin) {
    const double yPos = 230.0; // Adjust the initial vertical position as needed

    switch (receiptType) {
      case "NR":
        _drawCenteredText(page, contentFont, 'Refund', yPos);
        _drawCenteredText(page, contentFont,
            'REF.NORMAL RECEIPT:# $sdcReceiptNum', yPos + 10);
        _drawCenteredText(page, contentFont,
            'REFUND IS APPROVED FOR CLIENT ID:$customerTin', yPos + 20);
        break;
      case "CS":
        _drawCenteredText(page, contentFont, 'COPY', yPos);
        _drawCenteredText(page, contentFont,
            'REF.NORMAL RECEIPT:# $sdcReceiptNum', yPos + 10);
        _drawCenteredText(page, contentFont,
            'COPY OF RECEIPT FOR CLIENT ID:$customerTin', yPos + 20);

        break;
      case "TS":
        _drawCenteredText(page, contentFont, 'TRAINING MODE', yPos);
        break;
      default:
    }
  }

  /// Creates the grid for displaying purchased items.
  PdfGrid _createItemsGrid(
      List<TransactionItem> items, PdfGridStyle gridStyle) {
    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 4);
    grid.columns[0].width = 100; // Adjust the width for the 'Items' column
    grid.columns[1].width = 50; // Adjust the width for the 'Unit' column
    grid.columns[2].width = 30; // Adjust the width for the 'qty' column
    grid.columns[3].width = 70; // Adjust the width for the 'Total' column

    final PdfGridRow headerRow = grid.headers.add(1)[0];
    headerRow.cells[0].value = 'Items';
    headerRow.cells[1].value = 'Unit';
    headerRow.cells[2].value = 'qty';
    headerRow.cells[3].value = 'Total';
    for (var item in items) {
      double total = item.price * item.qty;
      String taxLabel = item.taxTyCd != null ? "(${item.taxTyCd!})" : "(B)";
      PdfGridRow row = grid.rows.add();
      row.cells[0].value = item.name!;
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
    const double yPos = 380.0; // Adjust the initial vertical position as needed

    _drawCenteredText(page, contentFont, 'Pay Mode: $payMode', yPos);
    _drawCenteredText(
        page, contentFont, 'Received Amount: $received', yPos + 10);
    _drawCenteredText(page, contentFont,
        'Change: ${transaction.subTotal - received}', yPos + 20);
    _drawCenteredText(page, contentFont, 'ITEMS NUMBER: $itemCount', yPos + 30);
    _drawCenteredText(
        page, contentFont, 'Cashier Name: $cashierName', yPos + 40);
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
    const double yPos = 460.0; // Adjust the initial vertical position as needed

    _drawCenteredText(page, contentFont, 'SDC INFORMATION', yPos);
    _drawDashedLine(
        page, const Offset(0, 480), Offset(page.getClientSize().width, 480));
    _drawCenteredText(page, contentFont, 'SDC ID: $sdcId', yPos + 20);
    _drawCenteredText(page, contentFont,
        'RECEIPT NUMBER: $sdcReceiptNum $receiptType', yPos + 30);
    _drawCenteredText(page, contentFont,
        transaction.lastTouched?.toDateTimeString() ?? "", yPos + 40);
    _drawCenteredText(page, contentFont, 'Receipt Signature: ', yPos + 60);
    _drawCenteredText(
        page, contentFont, receiptSignature.toDashedString(), yPos + 70);
    _drawCenteredText(page, contentFont, 'Internal Data: ', yPos + 80);
    _drawCenteredText(
        page, contentFont, internalData.toDashedString(), yPos + 90);

    // Draw QR Code
    // _drawQRCode(page, receiptQrCode);
  }

  /// Draws the QR code on the receipt.
  // void _drawQRCode(PdfPage page, String qrCodeData) async {
  //   final qrCodeImage = await _generateQrCodeImage(qrCodeData);
  //   page.graphics
  //       .drawImage(qrCodeImage!, const Rect.fromLTWH(150, 670, 100, 100));
  // }

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
    try {
      final qrCodeImage = await QrPainter(
        data: qrCodeData,
        version: QrVersions.auto,
        color: Colors.black,
        emptyColor: Colors.white,
      ).toImage(100); // Adjust size as needed

      final byteData =
          await qrCodeImage.toByteData(format: ui.ImageByteFormat.png);
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
