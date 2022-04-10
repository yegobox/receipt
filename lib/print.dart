import 'package:pdf/widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:receipt/omni_printer.dart';
import 'package:flipper_models/isar_models.dart';

class Print {
  List<TableRow> rows = [];
  List<TableRow> feed(List<OrderItem> items) {
    for (var item in items) {
      rows.add(TableRow(children: [
        Text(item.count.toString()),
        Text(item.name),
        Text(item.price.toString()),
      ]));
    }
    return rows;
  }

  print() {
    OmniPrinter printer;
    printer = OmniPrinter();
    printer.generateDoc(
        info: "Aurora",
        taxId: "12331",
        receiverName: "Richie",
        receiverMail: "info@yegobox.com",
        receiverPhone: "+250783054874",
        email: "another email",
        rows: <TableRow>[
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

          ...rows,
          // TableRow(children: [
          //   Text('1'),
          //   Text('Coffee'),
          //   Text('\$1.00'),
          // ]),

          // TableRow(children: [
          //   SizedBox(height: 8),
          // ]),

          // TableRow(children: [
          //   Text('1'),
          //   Text('Coffee'),
          //   Text('\$1.00'),
          // ]),

          // TableRow(children: [
          //   SizedBox(height: 8),
          // ]),

          // TableRow(children: [
          //   Text('1'),
          //   Text('Coffee'),
          //   Text('\$1.00'),
          // ]),

          // TableRow(children: [
          //   SizedBox(height: 12),
          // ]),

          /// show total
          TableRow(children: [
            Text(
              'TOTAL',
              style: TextStyle(
                  color: PdfColor.fromHex('#F90006'),
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(),
            Text('\$3,000', style: TextStyle(fontWeight: FontWeight.bold))
          ])
        ]);
  }
}
