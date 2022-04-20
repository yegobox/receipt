library receipt;

import 'package:flipper_models/isar_models.dart';
import 'package:pdf/widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:receipt/omni_printer.dart';
// import 'package:receipt/order_item.dart';

class Print {
  List<TableRow> rows = [];
  List<TableRow> feed(List<OrderItem> items) {
    for (var item in items) {
      rows.add(TableRow(children: [
        Text(item.qty.toString()),
        Text(item.name),
        Text(item.price.toString()),
      ]));
      rows.add(TableRow(children: [
        SizedBox(height: 10),
      ]));
    }
    return rows;
  }

  print({
    required double grandTotal,
    required String currencySymbol,
    required String info,
    required String taxId,
    required String receiverName,
    required String receiverMail,
    required String receiverPhone,
    required String email,
  }) {
    OmniPrinter printer;
    printer = OmniPrinter();
    printer.generateDoc(
      info: info,
      taxId: taxId,
      receiverName: receiverName,
      receiverMail: receiverMail,
      receiverPhone: receiverPhone,
      email: email,
      rows: <TableRow>[
        TableRow(children: [
          Text('Qty', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(
            'Product',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text('PRICE', style: TextStyle(fontWeight: FontWeight.bold)),
        ]),
        TableRow(children: [
          SizedBox(height: 10),
        ]),
        ...rows,
        TableRow(children: [
          Text(
            'TOTAL',
            style: TextStyle(
                color: PdfColor.fromHex('#F90006'),
                fontWeight: FontWeight.bold),
          ),
          SizedBox(),
          Text(currencySymbol + " " + grandTotal.toString(),
              style: TextStyle(fontWeight: FontWeight.bold))
        ])
      ],
    );
  }
}
