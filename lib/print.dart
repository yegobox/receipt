import 'package:pdf/widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:receipt/omni_printer.dart';

class Print {
  static List<TableRow> feed(List<Map<String, String>> list) {
    List<TableRow> rows = [];
    for (var element in list) {
      rows.add(TableRow(children: [
        Text(element['quantity']!, style: const TextStyle(fontSize: 5)),
      ]));
    }
    return <TableRow>[
      TableRow(children: [
        Text('1'),
        Text('Coffee'),
        Text('\$1.00'),
      ]),
    ];
  }

  static print() {
    OmniPrinter printer;
    printer = OmniPrinter();
    printer.generateDoc(rows: <TableRow>[
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
      ])
    ]);
  }
}
