import 'package:pdf/widgets.dart';
import 'package:pdf/pdf.dart';

class PwPage extends StatelessWidget {
  final String? date;
  final String? info;
  final String? taxID;
  final String? receiverName;
  final String? receiverMail;
  final String? receiverPhone;
  final List<TableRow> rows;
  final String? brandName;
  final String? brandAddress;
  final String? brandTel;
  final String? brandTIN;
  final String? brandDescription;
  final String? brandFooter;

  PwPage(
      {this.brandName,
      this.brandAddress,
      this.brandTel,
      this.brandTIN,
      this.brandDescription,
      this.brandFooter,
      this.date,
      this.info,
      this.taxID,
      this.receiverName,
      this.receiverMail,
      this.receiverPhone,
      required this.rows});

  @override
  Widget build(Context context) {
    final body = Table(children: [
      ...rows,
    ]);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      color: PdfColor.fromHex('#F3F5F9'),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
            decoration: BoxDecoration(
                color: PdfColor.fromHex('#FFF'),
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  brandName!,
                  style: TextStyle(
                      font: Font.helvetica(),
                      fontBold: Font.helveticaBold(),
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
                SizedBox(height: 3),
                Text(
                  brandAddress!,
                  style: TextStyle(
                      font: Font.helvetica(),
                      fontBold: Font.helveticaBold(),
                      fontSize: 16),
                ),
                SizedBox(height: 3),
                Text(
                  "Tel:" + brandTel!,
                  style: TextStyle(
                      font: Font.helvetica(),
                      fontBold: Font.helveticaBold(),
                      fontSize: 14),
                ),
                SizedBox(height: 3),
                Divider(height: 1),
                SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'TIN',
                      style: TextStyle(
                          fontBold: Font.helveticaBold(),
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                    SizedBox(width: 100),
                    Text(
                      brandTIN!,
                      style: TextStyle(
                        fontBold: Font.helveticaBold(),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      brandDescription!,
                      style: TextStyle(
                          fontBold: Font.helveticaBold(),
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 3),
          Divider(height: 1),
          SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
            decoration: BoxDecoration(
                color: PdfColor.fromHex('#FFF'),
                borderRadius: BorderRadius.circular(10)),
            child: body,
          ),
          SizedBox(height: 3),
          Divider(height: 1),
          SizedBox(height: 3),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 22),
            decoration: BoxDecoration(
                color: PdfColor.fromHex('#FFF'),
                borderRadius: BorderRadius.circular(10)),
            child: Text(
              'Thank you for visiting our store: ' + brandFooter!,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontBold: Font.helveticaBold()),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
