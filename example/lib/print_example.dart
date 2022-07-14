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
      body: Center(
        child: TextButton(
          onPressed: () async {
            Print print = Print();
            print.feed(
              [
                OrderItem()
                  ..name = 'Beans'
                  ..price = 100
                  ..qty = 1
                  ..qty = 3
                  ..discount = 10
                  ..remainingStock = 10
                  ..createdAt = '2020-01-01'
                  ..updatedAt = '2020-01-01'
                  ..reported = false
                  ..isTaxExempted = false
                  ..orderId = 1
                  ..variantId = 1,
                OrderItem()
                  ..name = 'Beans'
                  ..price = 100
                  ..qty = 1
                  ..qty = 3
                  ..discount = 10
                  ..remainingStock = 10
                  ..createdAt = '2020-01-01'
                  ..updatedAt = '2020-01-01'
                  ..reported = false
                  ..isTaxExempted = false
                  ..orderId = 1
                  ..variantId = 1,
                OrderItem()
                  ..name = 'Weat'
                  ..price = 100
                  ..qty = 1
                  ..qty = 3
                  ..discount = 10
                  ..remainingStock = 10
                  ..createdAt = '2020-01-01'
                  ..updatedAt = '2020-01-01'
                  ..reported = false
                  ..isTaxExempted = false
                  ..orderId = 1
                  ..variantId = 1,
                OrderItem()
                  ..name = 'Ibirayi'
                  ..price = 100
                  ..qty = 1
                  ..qty = 3
                  ..discount = 10
                  ..remainingStock = 10
                  ..createdAt = '2020-01-01'
                  ..updatedAt = '2020-01-01'
                  ..reported = false
                  ..isTaxExempted = false
                  ..orderId = 1
                  ..variantId = 1,
                OrderItem()
                  ..name = 'PopCorn'
                  ..price = 100
                  ..qty = 1
                  ..qty = 3
                  ..discount = 10
                  ..remainingStock = 10
                  ..createdAt = '2020-01-01'
                  ..updatedAt = '2020-01-01'
                  ..reported = false
                  ..isTaxExempted = false
                  ..orderId = 1
                  ..variantId = 1,
                OrderItem()
                  ..name = 'Beans'
                  ..price = 100
                  ..qty = 1
                  ..qty = 3
                  ..discount = 10
                  ..remainingStock = 10
                  ..createdAt = '2020-01-01'
                  ..updatedAt = '2020-01-01'
                  ..reported = false
                  ..isTaxExempted = false
                  ..orderId = 1
                  ..variantId = 1,
                OrderItem()
                  ..name = 'Mango'
                  ..price = 100
                  ..qty = 1
                  ..qty = 2
                  ..isTaxExempted = false
                  ..discount = 10
                  ..remainingStock = 10
                  ..createdAt = '2020-01-01'
                  ..updatedAt = '2020-01-01'
                  ..reported = false
                  ..orderId = 1
                  ..variantId = 1,
                // OrderItem()
                //   ..name = 'Mango'
                //   ..price = 100
                //   ..qty = 1
                //   ..qty = 2
                //   ..isTaxExempted = false
                //   ..discount = 10
                //   ..remainingStock = 10
                //   ..createdAt = '2020-01-01'
                //   ..updatedAt = '2020-01-01'
                //   ..reported = false
                //   ..orderId = 1
                //   ..variantId = 1,
                // OrderItem()
                //   ..name = 'Mango'
                //   ..price = 100
                //   ..qty = 1
                //   ..qty = 2
                //   ..isTaxExempted = false
                //   ..discount = 10
                //   ..remainingStock = 10
                //   ..createdAt = '2020-01-01'
                //   ..updatedAt = '2020-01-01'
                //   ..reported = false
                //   ..orderId = 1
                //   ..variantId = 1,
                // OrderItem()
                //   ..name = 'Mango'
                //   ..price = 100
                //   ..qty = 1
                //   ..qty = 2
                //   ..isTaxExempted = false
                //   ..discount = 10
                //   ..remainingStock = 10
                //   ..createdAt = '2020-01-01'
                //   ..updatedAt = '2020-01-01'
                //   ..reported = false
                //   ..orderId = 1
                //   ..variantId = 1,
              ],
            );
            print.print(
                grandTotal: 500,
                currencySymbol: "RW",
                totalAEx: 0,
                totalB18: "800",
                totalB: 122.03,
                totalTax: "122.03",
                cash: 1000,
                received: 500,
                payMode: "Mobile Money",
                mrc: "SIMBASM0050",
                internalData: "IKGIP3LSQ3QSPS4QUI2DBS2OPQ",
                receiptQrCode: '000',
                receiptSignature: "SF5U44F2OHZFRTX3",
                cashierName: "ABC",
                sdcId: "SDC003001109",
                sdcReceiptNum: "8383/9280 NS",
                invoiceNum: 1884,
                brandName: "Simba",
                brandAddress: "OOOOO CITY CENTER, Kigali Rwanda",
                brandTel: "27131153",
                brandTIN: "101587390",
                brandDescription: "Simba Supermaket Stands for Quality Service",
                brandFooter: "SIMBA Supermaket and Coffee Shop",
                customerTin: "123456",
                receiptType: "PS",
                emails: ['info@yegobox.com']);
          },
          child: const Text('Print Now'),
        ),
      ),
    );
  }
}
