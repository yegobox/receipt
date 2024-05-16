/// this code use syncfusion_flutter_pdf to generate PDF receipt
/// this receipt has ability to accept signature
///
/// import 'dart:io';
import 'dart:io';

import 'package:flipper_models/realm_model_export.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:universal_platform/universal_platform.dart';

final isDesktopOrWeb = UniversalPlatform.isDesktopOrWeb;

/// TODO: handle printing later here https://www.syncfusion.com/forums/166034/how-to-print-a-pdf-document
/// [generatePdfAndPrint] example
/// an extension on DateTime that return a string of date time separated by space
extension DateTimeToDateTimeString on DateTime {
  String toDateTimeString() {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm:ss');
    final dateString = dateFormat.format(this);
    final timeString = timeFormat.format(this);
    return '$dateString $timeString';
  }
}

/// given a string E2P2VANEFD7PWY3COLUULSL3JU as a string, I want an extension that take
/// this string and apply dashed dashes come after 4 char
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
  Future<void> generatePdfAndPrint({
    String brandName = "yegobox shop",
    String brandAddress = "CITY CENTER, Kigali Rwanda",
    String brandTel = "271311123",
    String brandTIN = "1211287390",
    String brandDescription = "We build app that server you!",
    String brandFooter = "yegobox shop",
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
    //Create a new PDF document
    final PdfDocument document = PdfDocument();
    //Add a new page to the document
    final PdfPage page = document.pages.add();

    //Draw the image
    final PdfBitmap image = PdfBitmap(File('assets/rra.jpg').readAsBytesSync());
    page.graphics.drawImage(image, const Rect.fromLTWH(0, 0, 150, 150));

    // Create a PDF grid
    final PdfGrid grid = PdfGrid();
    // Add the columns to the grid
    grid.columns.add(count: 4);
    // Add header row
    final PdfGridRow headerRow = grid.headers.add(1)[0];
    headerRow.cells[0].value = 'Item';
    headerRow.cells[1].value = 'Price';
    headerRow.cells[2].value = 'Qty';
    headerRow.cells[3].value = 'Total';
    //Add rows to grid
    for (var item in items) {
      double total = item.price * item.qty;
      // log(item.name, name: "in the loop");
      String taxLabel = item.isTaxExempted ? "(EX)" : "(B)";
      PdfGridRow row = grid.rows.add();
      row.cells[0].value =
          item.name!.length > 12 ? item.name!.substring(0, 12) : item.name!;
      row.cells[1].value = item.price.toString();
      row.cells[2].value = item.qty.toString();
      row.cells[3].value = '$total $taxLabel';
    }

    //Set the grid style
    grid.style = PdfGridStyle(
        cellPadding: PdfPaddings(left: 2, top: 2, right: 2, bottom: 2),
        backgroundBrush: PdfBrushes.white,
        textBrush: PdfBrushes.black,
        font: PdfStandardFont(PdfFontFamily.timesRoman, 14));

    //Draw the header section by creating text elements
    final PdfFont contentFont = PdfStandardFont(PdfFontFamily.helvetica, 9);
    //Draw string
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
    //Draw the receipt type
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

    //Draw the grid
    grid.draw(page: page, bounds: const Rect.fromLTWH(0, 300, 0, 0));

    //Draw Total
    page.graphics.drawString('TOTAL: $totalPayable', contentFont,
        brush: PdfBrushes.black, bounds: const Rect.fromLTWH(0, 450, 400, 30));

    //Draw a dashed line
    page.graphics
        .drawLine(PdfPens.gray, const Offset(0, 470), const Offset(200, 470));

    //Draw Pay Mode
    page.graphics.drawString('Pay Mode: $payMode', contentFont,
        brush: PdfBrushes.black, bounds: const Rect.fromLTWH(0, 480, 400, 30));

    //Draw SDC Information
    page.graphics.drawString('SDC INFORMATION', contentFont,
        brush: PdfBrushes.black, bounds: const Rect.fromLTWH(0, 510, 400, 30));

    //Draw a dashed line
    page.graphics
        .drawLine(PdfPens.gray, const Offset(0, 530), const Offset(200, 530));

    //Draw SDC ID
    page.graphics.drawString('SDC ID: $sdcId', contentFont,
        brush: PdfBrushes.black, bounds: const Rect.fromLTWH(0, 540, 400, 30));
    //Draw Receipt Number
    page.graphics.drawString(
        'RECEIPT NUMBER: $sdcReceiptNum $receiptType', contentFont,
        brush: PdfBrushes.black, bounds: const Rect.fromLTWH(0, 550, 400, 30));

    //Draw Receipt Signature
    page.graphics.drawString('Receipt Signature: ', contentFont,
        brush: PdfBrushes.black, bounds: const Rect.fromLTWH(0, 570, 400, 30));
    page.graphics.drawString(receiptSignature.toDashedString(), contentFont,
        brush: PdfBrushes.black,
        bounds: const Rect.fromLTWH(100, 570, 400, 30));

    //Draw internal data
    page.graphics.drawString('Internal Data: ', contentFont,
        brush: PdfBrushes.black, bounds: const Rect.fromLTWH(0, 590, 400, 30));
    page.graphics.drawString(internalData.toDashedString(), contentFont,
        brush: PdfBrushes.black,
        bounds: const Rect.fromLTWH(100, 590, 400, 30));

    //Draw QR Code
    // final PdfQRBarcode qrCode = PdfQRBarcode(receiptQrCode);
    // qrCode.size = const Size(100, 100);
    // page.graphics.drawBarcode(qrCode, const Offset(150, 610));
    SfBarcodeGenerator(
      value: receiptQrCode,
      symbology: QRCode(),
    );

    //Draw Invoice Number
    page.graphics.drawString('INVOICE NUMBER: $invoiceNum', contentFont,
        brush: PdfBrushes.black, bounds: const Rect.fromLTWH(0, 720, 400, 30));

    //Draw MRC
    page.graphics.drawString('MRC: $mrc', contentFont,
        brush: PdfBrushes.black, bounds: const Rect.fromLTWH(0, 730, 400, 30));

    //Draw Thank you
    page.graphics.drawString('Thank you!', contentFont,
        brush: PdfBrushes.black, bounds: const Rect.fromLTWH(0, 750, 400, 30));

    //Draw EBM v2
    page.graphics.drawString('EBM v2: v1.12', contentFont,
        brush: PdfBrushes.black, bounds: const Rect.fromLTWH(0, 760, 400, 30));

    //Save the PDF document
    final List<int> bytes = await document.save();
    //Dispose the document
    document.dispose();
    //Save and launch the file
    saveAndLaunchFile(bytes, 'Output.pdf');
  }

  Future<void> saveAndLaunchFile(List<int> bytes, String fileName) async {
    final path = (await getApplicationDocumentsDirectory()).path;
    final file = File('$path/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    if (isDesktopOrWeb) {
      await Process.run('start', <String>['$path/$fileName'], runInShell: true);
    } else {
      //Launch the saved file
      await OpenFilex.open('$path/$fileName');
    }
  }
}
