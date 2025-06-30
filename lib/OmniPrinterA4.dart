import 'package:pdf/pdf.dart';
import 'package:receipt/widgets/receipt_summary_widget.dart'
    show ReceiptSummaryWidget;
import 'widgets/receipt_footer.dart';
import 'package:pdf/widgets.dart';
import 'package:receipt/SaveFile.dart';
import 'package:receipt/printable.dart';
import 'package:supabase_models/brick/models/all_models.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart' as c;
import 'package:printing/printing.dart';
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
    String? customerTin,
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
                if (receiptType != "CR") SizedBox(height: 5),

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
                if (receiptType != "CR") SizedBox(height: 4),

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
                  originalInvcNumber: transaction.invoiceNumber?.toString(),
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
                if (receiptType != "CR") SizedBox(height: 10),

                // Disclaimer with refund information if applicable
                A4Disclaimer(
                  receiptType: receiptType,
                  font: _unicodeFont,
                ),

                // SDC Information
                ReceiptSummaryWidget(
                  receiptType: receiptType,
                  receiptQrCode: receiptQrCode,
                  items: items,
                  totalPayable: totalPayable,
                  totalDiscount: totalDiscount,
                  totalTax: safeParseDouble(totalTax),
                  totalTaxB: totalTaxB,
                  totalTaxD: totalTaxD,
                  unicodeFont: _unicodeFont,
                  timeFromServer: timeFromServer,
                  sdcId: sdcId,
                  internalData: internalData,
                  receiptSignature: receiptSignature,
                  rcptNo: rcptNo,
                  totRcptNo: totRcptNo,
                  invoiceNum: invoiceNum,
                  whenCreated: whenCreated,
                  mrc: mrc,
                  transaction: transaction,
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
