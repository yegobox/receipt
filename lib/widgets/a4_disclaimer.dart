import 'package:pdf/widgets.dart' as pw;

class A4Disclaimer extends pw.StatelessWidget {
  final String receiptType;
  final pw.Font? font;

  A4Disclaimer({
    required this.receiptType,
    required this.font,
  });

  @override
  pw.Widget build(pw.Context context) {
    // Show disclaimer for specific receipt types
    if (!["TS", "PS", "CS", "CR", "NR", "TR", "CP"].contains(receiptType)) {
      return pw.SizedBox.shrink();
    }

    return pw.Column(
      children: [
        pw.SizedBox(height: 1),
        pw.Center(
          child: pw.Text(
            "THIS IS NOT AN OFFICIAL RECEIPT",
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              font: font,
            ),
          ),
        ),
        pw.SizedBox(height: 1),
      ],
    );
  }
}
