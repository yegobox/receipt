import 'package:pdf/widgets.dart' as pw;

class A4Header extends pw.StatelessWidget {
  final pw.ImageProvider? leftLogo;
  final pw.ImageProvider? rightLogo;
  final String brandAddress;
  final String brandTel;
  final String brandTIN;
  final pw.Font? font;
  final String brandName;
  final String? brandEmail;

  A4Header({
    required this.leftLogo,
    required this.rightLogo,
    required this.brandAddress,
    required this.brandTel,
    required this.brandTIN,
    required this.font,
    required this.brandName,
    this.brandEmail,
  });

  @override
  pw.Widget build(pw.Context context) {
    return pw.Row(
      crossAxisAlignment:
          pw.CrossAxisAlignment.start, // align everything at the top
      children: [
        // Left Logo
        pw.Expanded(
          flex: 2,
          child: leftLogo != null
              ? pw.Align(
                  alignment: pw.Alignment.topLeft,
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 8, top: 4),
                    child: pw.Image(leftLogo!, width: 60, height: 60),
                  ),
                )
              : pw.SizedBox(),
        ),

        // Center: Company Info
        pw.Expanded(
          flex: 3,
          child: pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                brandName,
                style: pw.TextStyle(fontSize: 12, font: font),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                brandAddress,
                style: pw.TextStyle(fontSize: 10, font: font),
                textAlign: pw.TextAlign.center,
              ),
              pw.Text(
                'TEL: $brandTel',
                style: pw.TextStyle(fontSize: 10, font: font),
                textAlign: pw.TextAlign.center,
              ),
              pw.Text(
                'EMAIL: ${brandEmail ?? " "}',
                style: pw.TextStyle(fontSize: 10, font: font),
                textAlign: pw.TextAlign.center,
              ),
              pw.Text(
                'TIN: $brandTIN',
                style: pw.TextStyle(fontSize: 10, font: font),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'WELCOME TO OUR SHOP',
                style: pw.TextStyle(fontSize: 10, font: font),
              ),
            ],
          ),
        ),

        // Right Logo
        pw.Expanded(
          flex: 2,
          child: rightLogo != null
              ? pw.Align(
                  alignment: pw.Alignment.topRight,
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.only(right: 8, top: 4),
                    child: pw.Image(rightLogo!, width: 60, height: 60),
                  ),
                )
              : pw.SizedBox(),
        ),
      ],
    );
  }
}
