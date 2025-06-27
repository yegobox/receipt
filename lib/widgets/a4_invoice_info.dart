import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class A4InvoiceInfo extends pw.StatelessWidget {
  final String? customerTin;
  final String customerName;
  final String? customerPhone;
  final int invoiceNum;
  final String? invoiceNumber;
  final DateTime whenCreated;
  final String receiptType;
  final pw.Font? font;

  A4InvoiceInfo({
    required this.customerTin,
    required this.customerName,
    required this.customerPhone,
    required this.invoiceNum,
    this.invoiceNumber,
    required this.whenCreated,
    required this.receiptType,
    required this.font,
  });

  @override
  pw.Widget build(pw.Context context) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'INVOICE TO:',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            font: font,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _buildInfoBox(
              children: [
                _buildInfoRow('TIN:', customerTin ?? " "),
                pw.SizedBox(height: 5),
                _buildInfoRow('Name:', customerName),
                pw.SizedBox(height: 5),

                /// since we save phone number without the 0 then add it here
                _buildInfoRow('TEL:', "0${customerPhone ?? " "}"),
              ],
            ),
            pw.SizedBox(width: 10),
            _buildInfoBox(
              children: [
                _buildInfoRow('INVOICE NO:', invoiceNum.toString()),
                if (receiptType == "NR" ||
                    receiptType == "TR" ||
                    receiptType == "CR")
                  pw.Text(
                    'REF.NORMAL RECEIPT:# $invoiceNumber',
                    style: pw.TextStyle(fontSize: 10, font: font),
                  ),
                pw.SizedBox(height: 5),
                _buildInfoRow(
                    'Date:', whenCreated.toIso8601String().split('.')[0]),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 15),
      ],
    );
  }

  pw.Widget _buildInfoBox({required List<pw.Widget> children}) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: PdfColors.black,
          width: 0.5,
        ),
      ),
      child: pw.Padding(
        padding: const pw.EdgeInsets.all(8),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Text(
      '$label $value',
      style: pw.TextStyle(fontSize: 10, font: font),
    );
  }
}
