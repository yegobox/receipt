import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:receipt/omni_printer.dart';

class PrintigExample extends StatefulWidget {
  const PrintigExample({Key? key}) : super(key: key);

  @override
  State<PrintigExample> createState() => _PrintigExampleState();
}

class _PrintigExampleState extends State<PrintigExample> {
  late OmniPrinter printer;

  @override
  void initState() {
    printer = OmniPrinter();
    // printer.generateDoc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<DataRow> dataRows = [
      const DataRow(
        cells: <DataCell>[
          DataCell(Text('1')),
          DataCell(Text('Coffee')),
          DataCell(Text('\$1,000')),
        ],
      ),
      const DataRow(
        cells: <DataCell>[
          DataCell(Text('1')),
          DataCell(Text('Coffee')),
          DataCell(Text('\$1,000')),
        ],
      ),
      const DataRow(
        cells: <DataCell>[
          DataCell(Text('1')),
          DataCell(Text('Coffee')),
          DataCell(Text('\$1,000')),
        ],
      ),
      const DataRow(
        cells: <DataCell>[
          DataCell(Text(
            'TOTAL',
            style:
                TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
          )),
          DataCell(SizedBox()),
          DataCell(
              Text('\$3,000', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    ];

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          title: const Text(
            'Create Receipt',
            style: TextStyle(color: Colors.black),
          ),
        ),
        backgroundColor: const Color(0xFFF3F5F9),
        bottomSheet: Material(
          elevation: 5,
          child: Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  elevation: 0, shape: const StadiumBorder()),
              child: const Text('PRINT NOW'),
              onPressed: () async {
                // ;
                // await printer.autoPrint();
              },
            ),
          ),
        ),
        body: SafeArea(
          minimum: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'March 02, 2022',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const Gap(8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'INFO',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Gap(8),
                            Text(
                              'Invoice#223393',
                            )
                          ],
                        ),
                        const Gap(40),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'TAX ID',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Gap(8),
                            Text(
                              'IKSZHZOZ234EDLE3A',
                            )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(15),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'TO',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        Gap(8),
                        Text(
                          'Always Good Apps, LLC',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Gap(8),
                        Text(
                          'martinosoyen@gmail.com',
                          style: TextStyle(fontSize: 12),
                        ),
                        Gap(8),
                        Text(
                          '+1(233)2304-1223',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(15),
              SizedBox(
                width: double.infinity,
                child: DataTable(
                  dividerThickness: 1,
                  headingRowHeight: 45,
                  headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  columns: const <DataColumn>[
                    DataColumn(
                      label: Text(
                        'DEC',
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'ATM',
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'PRICE',
                      ),
                    ),
                  ],
                  rows: dataRows,
                ),
              ),
            ],
          ),
        ));
  }
}
