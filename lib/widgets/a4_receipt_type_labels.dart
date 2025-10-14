import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class A4ReceiptTypeLabels extends pw.StatelessWidget {
  final String receiptType;
  final String? invoiceNumber;
  final pw.Font? font;

  A4ReceiptTypeLabels({
    required this.receiptType,
    this.invoiceNumber,
    required this.font,
  });

  @override
  pw.Widget build(pw.Context context) {
    return pw.Column(
      children: [
        // Training Mode Label
        if (receiptType == "TS") _buildLabel("TRAINING MODE"),

        // Proforma Label
        if (receiptType == "PS") _buildLabel("PROFORMA"),

        // Copy Label
        if (receiptType == "CS" || receiptType == "CR" || receiptType == "CP")
          _buildCopyLabel(),

        // Refund Label
        if (receiptType == "NR" || receiptType == "TR" || receiptType == "CR")
          _buildRefundLabel(),

        pw.SizedBox(height: 4),
      ],
    );
  }

  pw.Widget _buildLabel(String text) {
    return pw.Center(
      child: pw.Column(
        children: [
          pw.Text(
            text,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              font: font,
            ),
          ),
          pw.SizedBox(height: 2),
        ],
      ),
    );
  }

  pw.Widget _buildCopyLabel() {
    return pw.Center(
      child: pw.Column(
        children: [
          pw.Text(
            'COPY',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              font: font,
            ),
          ),
          // _dashWidget(),
          pw.SizedBox(height: 5),
        ],
      ),
    );
  }

  pw.Widget _buildRefundLabel() {
    return pw.Center(
      child: pw.Column(
        children: [
          pw.Text(
            'Refund',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              font: font,
            ),
          ),
          if (invoiceNumber != null)
            pw.Text(
              'REF.NORMAL RECEIPT:# $invoiceNumber',
              style: pw.TextStyle(fontSize: 10, font: font),
            ),
          _dashWidget(),
          pw.Text(
            'REFUND IS APPROVED ONLY FOR ORIGINAL SALES RECEIPT',
            style: pw.TextStyle(fontSize: 10, font: font),
          ),
        ],
      ),
    );
  }

  pw.Widget _dashWidget() {
    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.symmetric(vertical: 4),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColors.black,
            width: 0.5,
            style: pw.BorderStyle.dashed,
          ),
        ),
      ),
    );
  }
}
