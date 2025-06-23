import 'package:flipper_services/proxy.dart';
import 'package:pdf/pdf.dart';
import 'widgets/receipt_footer.dart';
import 'package:pdf/widgets.dart';
import 'package:receipt/SaveFile.dart';
import 'package:receipt/printable.dart';
import 'package:supabase_models/brick/models/all_models.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart' as c;
import 'package:printing/printing.dart';
import 'package:flipper_models/helperModels/extensions.dart';
import 'widgets/a4_header.dart';
import 'widgets/a4_invoice_info.dart';
import 'widgets/a4_items_table.dart';
import 'widgets/a4_disclaimer.dart';
import 'widgets/a4_refund_header.dart';

//
class OmniPrinterA4 with SaveFile implements Printable {
  static Font? _unicodeFont;
  static Future<void> loadUnicodeFont() async {
    if (_unicodeFont == null) {
      final fontData = await rootBundle
          .load('packages/receipt/assets/fonts/NotoSans-Regular.ttf');
      _unicodeFont = Font.ttf(fontData);
    }
  }

  Future<ImageProvider?> _loadLogoImage({required String position}) async {
    ImageProvider? image;
    switch (position) {
      case "left":
        const imageLogo =
            c.AssetImage('assets/logo_left.png', package: 'receipt');
        image = await flutterImageProvider(imageLogo,
            configuration: const c.ImageConfiguration(size: Size(600, 600)));
        break;
      case "middle":
        const imageLogo =
            c.AssetImage('assets/flipper_logo.png', package: 'receipt');
        image = await flutterImageProvider(imageLogo,
            configuration: const c.ImageConfiguration(size: Size(100, 100)));
        break;
      case "right":
        const imageLogo =
            c.AssetImage('assets/logo_right.png', package: 'receipt');
        image = await flutterImageProvider(imageLogo,
            configuration: const c.ImageConfiguration(size: Size(100, 100)));
        break;
      default:
        throw ArgumentError('Invalid position: $position');
    }
    return image;
  }

  // Utility: Safe double parsing to avoid invalid double errors everywhere
  double safeParseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) {
      if (value.isNaN || value.isInfinite) return 0.0;
      return value;
    }
    if (value is int) return value.toDouble();
    if (value is String) {
      final cleaned = value.replaceAll(',', '').trim();
      final parsed = double.tryParse(cleaned);
      if (parsed == null || parsed.isNaN || parsed.isInfinite) return 0.0;
      return parsed;
    }
    return 0.0;
  }

  String _getPaymentType(String paymentCode) {
    switch (paymentCode) {
      case '01':
        return 'CASH';
      case '02':
        return 'CREDIT CARD';
      case '03':
        return 'CASH/CREDIT CARD';
      case '04':
        return 'BANK CHECK';
      case '05':
        return 'DEBIT&CREDIT CARD';
      case '06':
        return 'MOBILE MONEY';
      case '07':
      default:
        return 'OTHER';
    }
  }

  @override
  Future<void> generatePdfAndPrint({
    required double taxA,
    required double taxB,
    required double taxC,
    required double taxD,
    required double totalDiscount,
    String brandName = "yegobox shop",
    String brandAddress = "CITY CENTER, Kigali Rwanda",
    String brandTel = "271311123",
    String brandTIN = "1211287390",
    String brandDescription = "We build app that server you!",
    String brandFooter = "yegobox shop",
    List<String>? emails,
    String? customerTin = "000000000",
    String? customerPhone,
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
    required String transactionId,
    required Function(Uint8List bytes) printCallback,
    required DateTime timeFromServer,
    String? brandEmail,
  }) async {
    await loadUnicodeFont(); // Load font before generating PDF
    final pdf = Document(
      compress: true,
      // Ensures all content fits on a single page (no multipage)
      pageMode: PdfPageMode.none,
    );
    final left = await _loadLogoImage(position: "left");
    final middle = await _loadLogoImage(position: "middle");
    final right = await _loadLogoImage(position: "right");
    pdf.addPage(
      Page(
        pageFormat: PdfPageFormat.a4,
        build: (Context context) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                A4Header(
                  leftLogo: left,
                  rightLogo: right,
                  brandName: brandName,
                  brandAddress: brandAddress,
                  brandTel: brandTel,
                  brandTIN: brandTIN,
                  brandEmail: brandEmail,
                  font: _unicodeFont,
                ),
                SizedBox(height: 5),

                // Training and Proforma Labels - Added to match omni_printer.dart implementation
                if (receiptType == "TS")
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "TRAINING MODE",
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              font: _unicodeFont), // Use _unicodeFont
                        ),
                        SizedBox(height: 2),
                      ],
                    ),
                  ),
                if (receiptType == "PS")
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "PROFORMA",
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              font: _unicodeFont), // Use _unicodeFont
                        ),
                        SizedBox(height: 2),
                      ],
                    ),
                  ),
                SizedBox(height: 4),

                // Copy Title - Added to match omni_printer.dart implementation
                if (receiptType == "CS" ||
                    receiptType == "CR" ||
                    receiptType == "CP")
                  Center(
                    child: Column(
                      children: [
                        Text('COPY',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                font: _unicodeFont)), // Use _unicodeFont
                        dashWidget(),
                        SizedBox(height: 5),
                      ],
                    ),
                  ),

                // Refund header
                A4RefundHeader(
                  receiptType: receiptType,
                  invoiceNumber: transaction.invoiceNumber?.toString(),
                  font: _unicodeFont,
                  dashWidget: dashWidget,
                ),
                // Invoice Information
                A4InvoiceInfo(
                  customerTin: customerTin,
                  customerName: customerName,
                  customerPhone: customerPhone,
                  invoiceNum: invoiceNum,
                  invoiceNumber: invoiceNum.toString(),
                  whenCreated: whenCreated,
                  receiptType: receiptType,
                  font: _unicodeFont,
                ),

                // Items Table
                A4ItemsTable(
                  items: items,
                  receiptType: receiptType,
                  font: _unicodeFont,
                ),
                SizedBox(height: 10),

                // Disclaimer with refund information if applicable
                A4Disclaimer(
                  receiptType: receiptType,
                  font: _unicodeFont,
                ),

                // SDC Information
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (receiptType != "TR")
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('SDC INFORMATION',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    font: _unicodeFont)), // Use _unicodeFont
                            dashWidget(),
                            SizedBox(height: 5),
                            Text('Date: ${timeFromServer.isoDateTime}',
                                style: TextStyle(
                                    fontSize: 10,
                                    font: _unicodeFont)), // Use _unicodeFont
                            Text('SDC ID: $sdcId',
                                style: TextStyle(
                                    fontSize: 10,
                                    font: _unicodeFont)), // Use _unicodeFont
                            Text(
                                'Receipt Number: $rcptNo/$totRcptNo $receiptType',
                                style: TextStyle(
                                    fontSize: 10,
                                    font: _unicodeFont)), // Use _unicodeFont
                            if (receiptType != "PS" &&
                                receiptType != "TS" &&
                                receiptType != "TR")
                              Text(
                                  'Internal Data: ${internalData.toDashedStringInternalData()}',
                                  style: TextStyle(
                                      fontSize: 10, font: _unicodeFont)),
                            if (receiptType != "PS" &&
                                receiptType != "TS" &&
                                receiptType != "TR") // Use _unicodeFont
                              Text(
                                  'Receipt Signature: ${receiptSignature.toDashedStringRcptSign()}',
                                  style: TextStyle(
                                      fontSize: 10, font: _unicodeFont)),
                            SizedBox(height: 5),
                            dashWidget(),
                            SizedBox(height: 5),
                            Text('Receipt Number: $invoiceNum',
                                style: TextStyle(
                                    fontSize: 10,
                                    font: _unicodeFont)), // Use _unicodeFont
                            Text('Date: ${whenCreated.isoDateTime}',
                                style: TextStyle(
                                    fontSize: 10,
                                    font: _unicodeFont)), // Use _unicodeFont
                            Text(
                                "MRC: ${(() {
                                  final boxMrc = ProxyService.box.mrc();
                                  if (boxMrc != null &&
                                      boxMrc.isNotEmpty &&
                                      boxMrc.length == 11) {
                                    return boxMrc;
                                  }
                                  return mrc;
                                })()}",
                                style: TextStyle(
                                    fontSize: 10,
                                    font: _unicodeFont)), // Use _unicodeFont
                            dashWidget(),
                          ],
                        ),
                      ),
                    if (receiptType != "PS" &&
                        receiptType != "TS" &&
                        receiptType != "CR")
                      SizedBox(width: 20),
                    if (receiptType != "PS" &&
                        receiptType != "TS" &&
                        receiptType != "TR" &&
                        receiptType != "CR")
                      Center(
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: BarcodeWidget(
                            barcode: Barcode.qrCode(
                              errorCorrectLevel: BarcodeQRCorrectionLevel.high,
                            ),
                            data: receiptQrCode,
                          ),
                        ),
                      ),
                    SizedBox(width: 20), // Space between columns

                    // Summary Table
                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(height: 5),
                          Table(
                            border: TableBorder.all(width: 0.5),
                            children: [
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Text('TOTAL:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                            font:
                                                _unicodeFont)), // Use _unicodeFont
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Text(
                                        (receiptType == "NR" ||
                                                receiptType == "CR" ||
                                                receiptType == "TR")
                                            ? "-${safeParseDouble(totalPayable - totalDiscount).toNoCurrencyFormatted()}"
                                            : safeParseDouble(totalPayable -
                                                    totalDiscount)
                                                .toNoCurrencyFormatted(),
                                        style: TextStyle(
                                            fontSize: 10,
                                            font:
                                                _unicodeFont)), // Use _unicodeFont
                                  ),
                                ],
                              ),
                              // Only show TOTAL A-EX if there are items with tax type A
                              if (items.any((item) => item.taxTyCd == "A") &&
                                  items
                                          .where((item) => item.taxTyCd == "A")
                                          .fold<double>(
                                              0.0,
                                              (sum, item) =>
                                                  sum +
                                                  (item.price * item.qty)) >
                                      0)
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Text('TOTAL A-EX:'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Text(
                                          // Calculate total for A-EX items (tax type A)
                                          (receiptType == "NR" ||
                                                  receiptType == "CR" ||
                                                  receiptType == "TR")
                                              ? "-${items.where((item) => item.taxTyCd == "A").fold<double>(0.0, (sum, item) => sum + (item.price * item.qty)).toStringAsFixed(2)}"
                                              : items
                                                  .where((item) =>
                                                      item.taxTyCd == "A")
                                                  .fold<double>(
                                                      0.0,
                                                      (sum, item) =>
                                                          sum +
                                                          (item.price *
                                                              item.qty))
                                                  .toStringAsFixed(2),
                                          style: TextStyle(
                                              fontSize: 10,
                                              font:
                                                  _unicodeFont)), // Use _unicodeFont
                                    ),
                                  ],
                                ),
                              if (safeParseDouble(totalTaxB) != 0)
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Text('TOTAL B-18%:'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Text(
                                          (receiptType == "NR" ||
                                                  receiptType == "CR" ||
                                                  receiptType == "TR")
                                              ? "-${items.where((item) => item.taxTyCd == "B").fold<double>(0.0, (sum, item) => sum + (item.price * item.qty)).toNoCurrencyFormatted()}"
                                              : items
                                                  .where((item) =>
                                                      item.taxTyCd == "B")
                                                  .fold<double>(
                                                      0.0,
                                                      (sum, item) =>
                                                          sum +
                                                          (item.price *
                                                              item.qty))
                                                  .toNoCurrencyFormatted(),
                                          style: TextStyle(
                                              fontSize: 10,
                                              font:
                                                  _unicodeFont)), // Use _unicodeFont
                                    ),
                                  ],
                                ),
                              if (safeParseDouble(totalTaxB) != 0)
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Text('TOTAL TAX B:'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Text(
                                          (receiptType == "NR" ||
                                                  receiptType == "CR" ||
                                                  receiptType == "TR")
                                              ? "-${safeParseDouble(totalTaxB).toNoCurrencyFormatted()}"
                                              : safeParseDouble(totalTaxB)
                                                  .toNoCurrencyFormatted(),
                                          style: TextStyle(
                                              fontSize: 10,
                                              font:
                                                  _unicodeFont)), // Use _unicodeFont
                                    ),
                                  ],
                                ),
                              // Show if there are items with tax type C, even if the tax amount is zero
                              if (items.any((item) => item.taxTyCd == "C"))
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Text('TOTAL C:'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Text(
                                          (receiptType == "NR" ||
                                                  receiptType == "CR" ||
                                                  receiptType == "TR")
                                              ? "-${items.where((item) => item.taxTyCd == "C").fold<double>(0.0, (sum, item) => sum + (item.price * item.qty)).toNoCurrencyFormatted()}"
                                              : items
                                                  .where((item) =>
                                                      item.taxTyCd == "C")
                                                  .fold<double>(
                                                      0.0,
                                                      (sum, item) =>
                                                          sum +
                                                          (item.price *
                                                              item.qty))
                                                  .toNoCurrencyFormatted(),
                                          style: TextStyle(
                                              fontSize: 10,
                                              font:
                                                  _unicodeFont)), // Use _unicodeFont
                                    ),
                                  ],
                                ),
                              // Show TOTAL TAX: row unconditionally
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Text('TOTAL TAX:'),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Text(
                                        (receiptType == "NR" ||
                                                receiptType == "CR" ||
                                                receiptType == "TR")
                                            ? "-${safeParseDouble(totalTax).toStringAsFixed(2)}"
                                            : safeParseDouble(totalTax)
                                                .toStringAsFixed(2),
                                        style: TextStyle(
                                            fontSize: 10,
                                            font:
                                                _unicodeFont)), // Use _unicodeFont
                                  ),
                                ],
                              ),
                              if (safeParseDouble(totalTaxD) != 0)
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Text('Total D'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Text(
                                          (receiptType == "NR" ||
                                                  receiptType == "CR" ||
                                                  receiptType == "TR")
                                              ? "-${safeParseDouble(totalTaxD).toStringAsFixed(2)}"
                                              : safeParseDouble(totalTaxD)
                                                  .toStringAsFixed(2),
                                          style: TextStyle(
                                              fontSize: 10,
                                              font:
                                                  _unicodeFont)), // Use _unicodeFont
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          // Payment Method and Items Number table - placed directly below tax table
                          SizedBox(height: 5),
                          Table(
                            border: TableBorder.all(width: 0.5),
                            children: [
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Text('PAYMENT METHOD:'),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Text(
                                        "${_getPaymentType(ProxyService.box.pmtTyCd())}:",
                                        style: TextStyle(
                                            fontSize: 10,
                                            font:
                                                _unicodeFont)), // Use _unicodeFont
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Text('ITEMS NUMBER:'),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Text(items.length.toString(),
                                        style: TextStyle(
                                            fontSize: 10,
                                            font:
                                                _unicodeFont)), // Use _unicodeFont
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Ensure footer always shows at the end
                Spacer(),

                Center(child: ReceiptFooter(font: _unicodeFont)),
                if (middle != null) ...[
                  SizedBox(height: 4),
                  Center(
                    child: Image(
                      middle,
                      width: 20,
                      height: 20,
                    ),
                  ),
                ],
              ]);
        },
        // Try to keep everything on a single page
        margin: EdgeInsets.all(8),
        clip: true,
      ),
    );

    Uint8List pdfData = await pdf.save();
    Uint8List? image;
    await for (var page in Printing.raster(pdfData, pages: [0], dpi: 72)) {
      image = await page.toPng();
      break; // Only need the first page
    }
    handlePdfData(
      pdfData: pdfData,
      image: image!,
      emails: emails,
      autoPrint: autoPrint,
      transactionId: transactionId,
    );
    return printCallback(pdfData);
  }
}
