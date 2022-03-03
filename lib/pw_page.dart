import 'package:pdf/widgets.dart';
import 'package:pdf/pdf.dart';

class PwPage extends StatelessWidget {
  final String? date;
  final String? info;
  final String? taxID;
  final String? receiverName;
  final String? receiverMail;
  final String? receiverPhone;

  PwPage(
      {this.date,
      this.info,
      this.taxID,
      this.receiverName,
      this.receiverMail,
      this.receiverPhone});

  @override
  Widget build(Context context) {
    final body = Table(children: [
      ///Table Header
      TableRow(children: [
        Text('DEC', style: TextStyle(fontWeight: FontWeight.bold)),
        Text(
          'ATM',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text('PRICE', style: TextStyle(fontWeight: FontWeight.bold)),
      ]),

      TableRow(children: [
        SizedBox(height: 10),
      ]),

      TableRow(children: [
        Text('1'),
        Text('Coffee'),
        Text('\$1.00'),
      ]),

      TableRow(children: [
        SizedBox(height: 8),
      ]),

      TableRow(children: [
        Text('1'),
        Text('Coffee'),
        Text('\$1.00'),
      ]),

      TableRow(children: [
        SizedBox(height: 8),
      ]),

      TableRow(children: [
        Text('1'),
        Text('Coffee'),
        Text('\$1.00'),
      ]),

      TableRow(children: [
        SizedBox(height: 12),
      ]),

      /// show total
      TableRow(children: [
        Text(
          'TOTAL',
          style: TextStyle(
              color: PdfColor.fromHex('#F90006'), fontWeight: FontWeight.bold),
        ),
        SizedBox(),
        Text('\$3,000', style: TextStyle(fontWeight: FontWeight.bold))
      ]),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date!,
                  style: TextStyle(
                      font: Font.helvetica(),
                      fontBold: Font.helveticaBold(),
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'INFO',
                          style: TextStyle(
                              fontBold: Font.helveticaBold(),
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                        SizedBox(height: 10),
                        Text(info!)
                      ],
                    ),
                    SizedBox(width: 100),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TAX ID',
                          style: TextStyle(
                              fontBold: Font.helveticaBold(),
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                        SizedBox(height: 10),
                        Text(
                          taxID!,
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
            decoration: BoxDecoration(
                color: PdfColor.fromHex('#FFF'),
                borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TO',
                      style: TextStyle(
                          fontBold: Font.helveticaBold(),
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                    SizedBox(height: 10),
                    Text(
                      receiverName!,
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                    SizedBox(height: 8),
                    Text(
                      receiverMail!,
                      style: const TextStyle(fontSize: 12),
                    ),
                    SizedBox(height: 8),
                    Text(
                      receiverPhone!,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 15),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
              decoration: BoxDecoration(
                  color: PdfColor.fromHex('#FFF'),
                  borderRadius: BorderRadius.circular(10)),
              child: body),
          SizedBox(height: 25),
          Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 22),
              decoration: BoxDecoration(
                  color: PdfColor.fromHex('#129F4B'),
                  borderRadius: BorderRadius.circular(10)),
              child: Text(
                'Thanks for visiting us',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: PdfColor.fromHex('#FFF'),
                    fontBold: Font.helveticaBold()),
                textAlign: TextAlign.center,
              )),
        ],
      ),
    );
  }
}
