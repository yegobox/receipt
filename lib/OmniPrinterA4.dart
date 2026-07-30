import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:receipt/receipt_pdf_assets.dart';
import 'package:receipt/widgets/receipt_summary_widget.dart'
    show ReceiptSummaryWidget;
import 'package:supabase_models/brick/models/transaction.model.dart';
import 'package:supabase_models/brick/models/transactionItem.model.dart';
import 'widgets/receipt_footer.dart';
import 'package:pdf/widgets.dart';
import 'package:receipt/SaveFile.dart';
import 'package:receipt/printable.dart';
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
    _unicodeFont ??= await ReceiptPdfAssets.unicodeFont();
  }

  Future<ImageProvider?> _loadLogoImage({required String position}) async {
    return ReceiptPdfAssets.logo(position: position);
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
    int? originalInvoiceNumber,
    required double taxC,
    required double taxD,
    required double taxTT,
    required double totalDiscount,
    String brandName = "yegobox shop",
    String brandAddress = "",
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
    bool skipPresentation = false,
    bool deferPresentation = false,
    required double totalTaxA,
    required double totalTaxB,
    required double totalTaxC,
    required double totalTaxD,
    required double totalTaxTT,
    required String customerName,
    required int rcptNo,
    required int totRcptNo,
    required DateTime whenCreated,
    required String transactionId,
    required Function(Uint8List bytes) printCallback,
    required DateTime timeFromServer,
    String? brandEmail,
    required bool vatEnabled,
    bool isFiscalReceipt = true,
  }) async {
    await loadUnicodeFont(); // Load font before generating PDF
    final font = ReceiptPdfAssets.requireUnicodeFont(_unicodeFont);
    final pdf = Document(
      compress: true,
      // Ensures all content fits on a single page (no multipage)
      pageMode: PdfPageMode.none,
      theme: ReceiptPdfAssets.unicodeTheme(font),
    );
    final logos = await Future.wait([
      _loadLogoImage(position: "left"),
      _loadLogoImage(position: "middle"),
      _loadLogoImage(position: "right"),
    ]);
    final left = logos[0];
    final middle = logos[1];
    final right = logos[2];
    pdf.addPage(
      MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const EdgeInsets.all(8),
        theme: ReceiptPdfAssets.unicodeTheme(font),
        build: (Context context) {
          return [
            // Header Section
            A4Header(
              // Left and right logos are RRA/EBM branding (Rwanda emblem and
              // the "RWANDA approved" stamp) — only show them on RRA-signed
              // fiscal receipts.
              leftLogo: isFiscalReceipt ? left : null,
              middleLogo: middle,
              rightLogo: isFiscalReceipt ? right : null,
              brandName: brandName,
              brandAddress: brandAddress,
              brandTel: brandTel,
              brandTIN: brandTIN,
              brandEmail: brandEmail,
              font: _unicodeFont,
            ),
            if (receiptType != "CR") SizedBox(height: 5),

            // Training and Proforma Labels
            if (receiptType == "TS" || receiptType == "TR")
              Center(
                child: Column(
                  children: [
                    Text(
                      "TRAINING MODE",
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          font: _unicodeFont),
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
                          font: _unicodeFont),
                    ),
                    SizedBox(height: 2),
                  ],
                ),
              ),
            if (receiptType != "CR") SizedBox(height: 4),

            // Copy Title
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
                            font: _unicodeFont)),
                    dashWidget(),
                    SizedBox(height: 5),
                  ],
                ),
              ),

            // Refund header
            A4RefundHeader(
              originalInvoiceNumber: originalInvoiceNumber,
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
              minRows: 1,
              vatEnabled: vatEnabled,
            ),
            if (receiptType != "CR") SizedBox(height: 1),

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
              totalTaxTT: totalTaxTT,
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
              vatEnabled: vatEnabled,
              isFiscalReceipt: isFiscalReceipt,
              nonFiscalReceiptRef: transaction.transactionNumber,
            ),
            Center(
              child: ReceiptFooter(
                font: _unicodeFont,
                isFiscalReceipt: isFiscalReceipt,
              ),
            ),
            // if (middle != null) ...[
            //   SizedBox(height: 1),
            //   Center(
            //     child: Image(
            //       middle,
            //       width: 20,
            //       height: 20,
            //     ),
            //   ),
            // ],
          ];
        },
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
      skipPresentation: skipPresentation,
      deferPresentation: deferPresentation,
      transactionId: transactionId,
    );
    return printCallback(pdfData);
  }
}
