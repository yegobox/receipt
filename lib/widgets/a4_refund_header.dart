import 'package:pdf/widgets.dart' as pw;

class A4RefundHeader extends pw.StatelessWidget {
  final String receiptType;
  final String? invoiceNumber;
  final pw.Font? font;
  final Function() dashWidget;

  A4RefundHeader({
    required this.receiptType,
    this.invoiceNumber,
    required this.font,
    required this.dashWidget,
  });

  @override
  pw.Widget build(pw.Context context) {
    if (receiptType != "NR" && receiptType != "TR" && receiptType != "CR") {
      return pw.SizedBox.shrink();
    }

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
          if (receiptType == "NR" || receiptType == "TR" || receiptType == "CR")
            pw.Text(
              'REF.NORMAL RECEIPT:# $invoiceNumber',
              style: pw.TextStyle(
                fontSize: 10,
                font: font,
              ),
            ),
          dashWidget(),
          pw.Text(
            'REFUND IS APPROVED ONLY FOR ORIGINAL SALES RECEIPT',
            style: pw.TextStyle(
              fontSize: 10,
              font: font,
            ),
          ),
        ],
      ),
    );
  }
}
