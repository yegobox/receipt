import 'dart:io';
import 'package:receipt/SaveFile.dart';
import 'package:receipt/printable.dart';
import 'package:flipper_models/realm_model_export.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class OmniPrinterA4 with SaveFile implements Printable {
  @override
  Future<void> generatePdfAndPrint({
    required double taxA,
    required double taxB,
    required double taxC,
    required double totalDiscount,
    required double taxD,
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
    required String totalTax,
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
    required String customerName,
    required int rcptNo,
    required int totRcptNo,
    required DateTime whenCreated,
    required Function(Uint8List bytes) printCallback,
  }) async {
    // Create a PDF document
    final PdfDocument document = PdfDocument();
    final PdfPage page = document.pages.add();
    final PdfGraphics graphics = page.graphics;
    double yOffset = 40; // Starting position from top

    // Define fonts
    final PdfFont headerFont =
        PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold);
    final PdfFont normalFont = PdfStandardFont(PdfFontFamily.helvetica, 10);
    final PdfFont smallFont = PdfStandardFont(PdfFontFamily.helvetica, 9);

    // Header Section
    graphics.drawString(
      brandName,
      headerFont,
      bounds: Rect.fromLTWH(0, yOffset, page.getClientSize().width, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.left),
    );
    yOffset += 20;

    graphics.drawString(
      brandAddress,
      normalFont,
      bounds: Rect.fromLTWH(0, yOffset, page.getClientSize().width, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.left),
    );
    yOffset += 20;

    graphics.drawString(
      'TEL :$brandTel',
      normalFont,
      bounds: Rect.fromLTWH(0, yOffset, page.getClientSize().width, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.left),
    );
    yOffset += 20;

    graphics.drawString(
      'EMAIL :"',
      normalFont,
      bounds: Rect.fromLTWH(0, yOffset, page.getClientSize().width, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.left),
    );
    yOffset += 20;

    graphics.drawString(
      'TIN: $brandTIN',
      normalFont,
      bounds: Rect.fromLTWH(0, yOffset, page.getClientSize().width, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.left),
    );
    yOffset += 30;

    // Invoice Information
    graphics.drawString(
      'INVOICE TO',
      headerFont,
      bounds: Rect.fromLTWH(0, yOffset, page.getClientSize().width, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.left),
    );
    yOffset += 20;

    graphics.drawString(
      'TIN :$customerTin',
      normalFont,
      bounds: Rect.fromLTWH(0, yOffset, page.getClientSize().width, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.left),
    );
    yOffset += 20;

    graphics.drawString(
      'Name :$customerName',
      normalFont,
      bounds: Rect.fromLTWH(0, yOffset, page.getClientSize().width, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.left),
    );
    yOffset += 20;

    graphics.drawString(
      'INVOICE NO : $rcptNo',
      normalFont,
      bounds: Rect.fromLTWH(0, yOffset, page.getClientSize().width, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.left),
    );
    yOffset += 20;

    graphics.drawString(
      'Date : ${whenCreated.toLocal().toString().split('.')[0]}',
      normalFont,
      bounds: Rect.fromLTWH(0, yOffset, page.getClientSize().width, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.left),
    );
    yOffset += 30;

    // Items Table
    final PdfGrid itemsGrid = PdfGrid();
    itemsGrid.columns.add(count: 6);

// Set column widths
    itemsGrid.columns[0].width = 80; // Item code
    itemsGrid.columns[1].width = 150; // Description
    itemsGrid.columns[2].width = 50; // Qty
    itemsGrid.columns[3].width = 50; // Tax
    itemsGrid.columns[4].width = 80; // Unit Price
    itemsGrid.columns[5].width = 80; // Total Price

// Add headers with style
    final PdfGridRow header = itemsGrid.headers.add(1)[0];
    header.cells[0].value = 'Item code';
    header.cells[1].value = 'Item Description';
    header.cells[2].value = 'Qty';
    header.cells[3].value = 'Tax';
    header.cells[4].value = 'Unit Price';
    header.cells[5].value = 'Total Price';

// Header style (bold, centered, and with a background color)
    PdfGridCellStyle headerStyle = PdfGridCellStyle(
      font: PdfStandardFont(PdfFontFamily.helvetica, 10,
          style: PdfFontStyle.bold),
      backgroundBrush: PdfBrushes.lightGray,
      format: PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
      ),
      borders: PdfBorders(
        left: PdfPen(PdfColor(0, 0, 0), width: 0.5),
        right: PdfPen(PdfColor(0, 0, 0), width: 0.5),
        top: PdfPen(PdfColor(255, 255, 255)), // Transparent top border
        bottom: PdfPen(PdfColor(0, 0, 0),
            width: 0.5), // Black bottom border for the header
      ),
    );

// Apply the style to header cells
    for (int i = 0; i < header.cells.count; i++) {
      header.cells[i].style = headerStyle;
    }

// Add items with consistent border styles
    for (var item in items) {
      final PdfGridRow row = itemsGrid.rows.add();
      row.cells[0].value = item.itemCd;
      row.cells[1].value = item.name;
      row.cells[2].value = item.qty.toStringAsFixed(2);
      row.cells[3].value = item.taxTyCd;
      row.cells[4].value = item.price.toStringAsFixed(2);
      row.cells[5].value = (item.qty * item.price).toStringAsFixed(2);

      // Apply style to each cell in the row
      PdfGridCellStyle cellStyle = PdfGridCellStyle(
        borders: PdfBorders(
          left: PdfPen(PdfColor(0, 0, 0), width: 0.5), // Visible left border
          right: PdfPen(PdfColor(0, 0, 0), width: 0.5), // Visible right border
          top: PdfPen(PdfColor(255, 255, 255)), // Transparent top border
          bottom: PdfPen(PdfColor(
              255, 255, 255)), // Transparent bottom border for inner rows
        ),
        format: PdfStringFormat(
          alignment: PdfTextAlignment.center,
          lineAlignment: PdfVerticalAlignment.middle,
        ),
      );

      // Apply cell style
      for (int j = 0; j < row.cells.count; j++) {
        row.cells[j].style = cellStyle;
      }
    }

// Ensure the bottom border of the last row is visible
    if (itemsGrid.rows.count > 0) {
      final PdfGridRow lastRow = itemsGrid.rows[itemsGrid.rows.count - 1];
      for (int j = 0; j < lastRow.cells.count; j++) {
        lastRow.cells[j].style.borders.bottom =
            PdfPen(PdfColor(0, 0, 0), width: 0.5);
      }
    }

// Apply overall grid styles
    itemsGrid.style = PdfGridStyle(
      font: PdfStandardFont(PdfFontFamily.helvetica, 10),
      cellPadding: PdfPaddings(left: 5, right: 5, top: 3, bottom: 3),
    );

    // Draw items grid and get its layout result
    PdfLayoutResult gridResult =
        itemsGrid.draw(page: page, bounds: Rect.fromLTWH(0, yOffset, 0, 0))!;

    // Update yOffset using the bottom of the grid layout
    yOffset = gridResult.bounds.bottom + 30;

    // SDC Information
    graphics.drawString(
      'SDC INFORMATION',
      headerFont,
      bounds: Rect.fromLTWH(0, yOffset, page.getClientSize().width, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.left),
    );
    yOffset += 20;

    // Draw separator line
    graphics.drawString(
      '------------------------------------',
      normalFont,
      bounds: Rect.fromLTWH(0, yOffset, page.getClientSize().width, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.left),
    );
    yOffset += 20;

    // SDC Details
    List<String> sdcDetails = [
      'Date : ${whenCreated.toLocal().toString().split('.')[0]}',
      'SDC ID : $sdcId',
      'RECEIPT NUMBER : $rcptNo/$totRcptNo (NS)',
      'Internal Data : $internalData',
      'Receipt Signature : $receiptSignature',
    ];

    for (var detail in sdcDetails) {
      graphics.drawString(
        detail,
        normalFont,
        bounds: Rect.fromLTWH(0, yOffset, page.getClientSize().width, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
      );
      yOffset += 20;
    }

    // Draw separator lines and additional information
    graphics.drawString(
      '------------------------------------',
      normalFont,
      bounds: Rect.fromLTWH(0, yOffset, page.getClientSize().width, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.left),
    );
    yOffset += 20;

    List<String> receiptDetails = [
      'RECEIPT NUMBER : $rcptNo',
      'Date :${whenCreated.toLocal().toString().split('.')[0]}',
      'MRC : $mrc',
    ];

    for (var detail in receiptDetails) {
      graphics.drawString(
        detail,
        normalFont,
        bounds: Rect.fromLTWH(0, yOffset, page.getClientSize().width, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
      );
      yOffset += 20;
    }

    graphics.drawString(
      '------------------------------------',
      normalFont,
      bounds: Rect.fromLTWH(0, yOffset, page.getClientSize().width, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.left),
    );
    yOffset += 20;

    graphics.drawString(
      'Powered by EBM v2',
      normalFont,
      bounds: Rect.fromLTWH(0, yOffset, page.getClientSize().width, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.left),
    );
    yOffset += 30;

    // Totals section
    List<String> totals = [
      'Total Rwf ${totalPayable.toStringAsFixed(2)}',
      'Total A-EX Rwf ${totalTaxA.toStringAsFixed(2)}',
      'Total B-18% Rwf ${totalTaxB.toStringAsFixed(2)}',
      'Total D ${totalTaxD.toStringAsFixed(2)}',
      'Total Tax Rwf ${totalTax}',
    ];

    for (var total in totals) {
      graphics.drawString(
        total,
        normalFont,
        bounds: Rect.fromLTWH(0, yOffset, page.getClientSize().width, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
      );
      yOffset += 20;
    }

    // Save and return the document
    final List<int> bytes = await document.save();
    document.dispose();

    Uint8List pdfData = Uint8List.fromList(bytes);
    handlePdfData(
      pdfData: pdfData,
      emails: emails,
      autoPrint: autoPrint,
    );
    return printCallback(pdfData);
  }
}
