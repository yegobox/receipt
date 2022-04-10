import 'package:flutter/material.dart' as m;

import 'package:pdf/widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:receipt/omni_printer.dart';

class ExampleTwo extends m.StatefulWidget {
  const ExampleTwo({m.Key? key}) : super(key: key);

  @override
  m.State<ExampleTwo> createState() => _ExampleTwoState();
}

class _ExampleTwoState extends m.State<ExampleTwo> {
  late OmniPrinter printer;
  @override
  void initState() {
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
    super.initState();
  }

  @override
  m.Widget build(m.BuildContext context) {
    return m.Container(
      child: m.Center(child: m.Text("Printing example")),
    );
  }
}
