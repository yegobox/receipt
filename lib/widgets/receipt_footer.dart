import 'package:pdf/widgets.dart' as pw;
import 'package:receipt/receipt_pdf_assets.dart';

class ReceiptFooter extends pw.StatelessWidget {
  final pw.Font? font;
  final bool isFiscalReceipt;

  ReceiptFooter({
    this.font,
    this.isFiscalReceipt = true,
  });

  @override
  pw.Widget build(pw.Context context) {
    final resolvedFont = font;
    final textStyle = resolvedFont == null
        ? pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)
        : ReceiptPdfAssets.textStyle(
            resolvedFont,
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
          );

    return pw.Column(
      children: [
        pw.SizedBox(height: 12),
        pw.Text(
          'THANK YOU',
          style: textStyle,
        ),
        pw.Text(
          'COME BACK AGAIN',
          style: textStyle,
        ),
        if (isFiscalReceipt)
          pw.Text(
            'Flipper V2 Powered by RRA VSDC EBM 2.1',
            style: textStyle,
          ),
      ],
    );
  }
}
