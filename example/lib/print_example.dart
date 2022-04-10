import 'package:flutter/material.dart';
import 'package:receipt/print.dart';
import 'package:flipper_models/isar_models.dart';

class PrintExample extends StatefulWidget {
  const PrintExample({Key? key}) : super(key: key);

  @override
  State<PrintExample> createState() => _PrintExampleState();
}

class _PrintExampleState extends State<PrintExample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Center(
            child: TextButton(
              onPressed: () async {
                Print print = Print();
                print.feed(
                  [
                    OrderItem()
                      ..name = 'Test'
                      ..price = 100
                      ..count = 1
                      ..discount = 10
                      ..remainingStock = 10
                      ..createdAt = '2020-01-01'
                      ..updatedAt = '2020-01-01'
                      ..reported = false
                      ..orderId = 1
                      ..variantId = 1,
                    OrderItem()
                      ..name = 'Test'
                      ..price = 100
                      ..count = 1
                      ..discount = 10
                      ..remainingStock = 10
                      ..createdAt = '2020-01-01'
                      ..updatedAt = '2020-01-01'
                      ..reported = false
                      ..orderId = 1
                      ..variantId = 1,
                  ],
                );
                print.print(
                  grandTotal: 500,
                  currencySymbol: "RW",
                  info: "Richie",
                  taxId: "342",
                  receiverName: "Richie",
                  receiverMail: "info@yegobox.com",
                  receiverPhone: "+250783054874",
                  email: "info@yegobox.com",
                );
              },
              child: const Text('Print Example'),
            ),
          )
        ],
      ),
    );
  }
}
