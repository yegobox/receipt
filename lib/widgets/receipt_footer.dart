import 'package:pdf/widgets.dart' as pw;

class ReceiptFooter extends pw.StatelessWidget {
  final pw.Font? font;
  
  ReceiptFooter({
    this.font,
  });

  @override
  pw.Widget build(pw.Context context) {
    final textStyle = pw.TextStyle(
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
      font: font,
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
        pw.Text(
          'Flipper V2 Powered by RRA VSDC EBM 2.1',
          style: textStyle,
        ),
      ],
    );
  }
}
