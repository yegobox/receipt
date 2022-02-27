import 'dart:io';

import 'package:flutter/material.dart';
import 'package:isar_demo/omni_printer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Directory dir = await getApplicationDocumentsDirectory();
  // await IsarAPI.getDir(dbName: dir.path);
  runApp(const MaterialApp(home: Print()));
}

class Print extends StatefulWidget {
  const Print({Key? key}) : super(key: key);

  @override
  State<Print> createState() => _PrintState();
}

class _PrintState extends State<Print> {
  late OmniPrinter printer;
  final headers = [
    pw.Text('K5 25 Ave', style: const pw.TextStyle(fontSize: 5)),
    pw.Text('+250 788 888 888', style: const pw.TextStyle(fontSize: 5)),
  ];
  final subHeader = [
    pw.Text('Cashier: John Doe', style: const pw.TextStyle(fontSize: 5)),
    pw.Container(width: 10),
    pw.Column(
      children: [
        pw.Text('June 19,2021', style: const pw.TextStyle(fontSize: 5)),
        pw.Text('11:20 am', style: const pw.TextStyle(fontSize: 5)),
      ],
    )
  ];
  final body = pw.Table(children: [
    pw.TableRow(children: [
      pw.Text('DESC', style: const pw.TextStyle(fontSize: 5)),
      pw.Text('AMT', style: const pw.TextStyle(fontSize: 5)),
    ]),
    pw.TableRow(children: [
      pw.Text('1', style: const pw.TextStyle(fontSize: 5)),
      pw.Text('Coffee', style: const pw.TextStyle(fontSize: 5)),
      pw.Text('\$1.00', style: const pw.TextStyle(fontSize: 5)),
    ]),
    pw.TableRow(children: [
      pw.Text('1', style: const pw.TextStyle(fontSize: 5)),
      pw.Text('Coffee', style: const pw.TextStyle(fontSize: 5)),
      pw.Text('\$1.00', style: const pw.TextStyle(fontSize: 5)),
    ]),
    pw.TableRow(children: [
      pw.Text('1', style: const pw.TextStyle(fontSize: 5)),
      pw.Text('Coffee', style: const pw.TextStyle(fontSize: 5)),
      pw.Text('\$1.00', style: const pw.TextStyle(fontSize: 5)),
    ]),

    /// show total
    pw.TableRow(children: [
      pw.Text(''),
      pw.Text('Total', style: const pw.TextStyle(fontSize: 6)),
      pw.Text('\$3.00', style: const pw.TextStyle(fontSize: 6)),
    ]),
  ]);

  @override
  void initState() {
    printer = OmniPrinter();
    printer.generateDoc(header: headers, subHeader: subHeader, body: body);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: const Text('Print'),
          onPressed: () async {
            await printer.shareDoc();
            // await printer.autoPrint();
          },
        ),
      ),
    );
  }
}
