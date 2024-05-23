import 'dart:math';

import 'package:flipper_models/realm_model_export.dart';
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';
import 'package:receipt/omni_printer.dart';
import 'package:receipt/printable.dart';


List<TransactionItem> generateDummyTransactionItems() {
  final random = Random();

  // Helper function to generate a single TransactionItem
  TransactionItem _generateSingleDummyTransactionItem() {
    // Generate a random product name
    final productAdjectives = [
      'Delicious',
      'Fresh',
      'Premium',
      'Organic',
      'Gourmet',
      'Artisanal',
      'Homemade',
      'Handcrafted',
      'Authentic',
      'Healthy'
    ];
    final productTypes = [
      'Coffee',
      'Tea',
      'Smoothie',
      'Salad',
      'Sandwich',
      'Pastry',
      'Cake',
      'Muffin',
      'Cookie',
      'Bread'
    ];
    final productDescriptors = [
      'with Caramel',
      'with Chocolate Chips',
      'with Blueberries',
      'with Almonds',
      'with Honey',
      'with Cheese',
      'with Bacon',
      'with Spinach',
      'with Tomatoes',
      'with Avocado'
    ];

    final adjective =
        productAdjectives[random.nextInt(productAdjectives.length)];
    final type = productTypes[random.nextInt(productTypes.length)];
    final descriptor = random.nextBool()
        ? productDescriptors[random.nextInt(productDescriptors.length)]
        : '';

    final productName = '$adjective $type $descriptor';

    return TransactionItem(
      ObjectId(),
      id: random.nextInt(1000),
      action: '${random.nextInt(3)}',
      name: productName,
      transactionId: random.nextInt(1000),
      variantId: random.nextInt(1000),
      qty: random.nextDouble() * 10.0,
      price: random.nextDouble() * 50.0,
      branchId: random.nextInt(10),
      remainingStock: random.nextDouble() * 20.0,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      isTaxExempted: random.nextBool(),
      prc: random.nextDouble() * 30.0,
      discount: random.nextDouble() * 10.0,
      type: '${random.nextInt(2)}',
      isRefunded: random.nextBool(),
      doneWithTransaction: random.nextBool(),
      active: random.nextBool(),
      dcRt: random.nextDouble() * 5.0,
      dcAmt: random.nextDouble() * 10.0,
      taxblAmt: random.nextDouble() * 15.0,
      taxAmt: random.nextDouble() * 5.0,
      totAmt: random.nextDouble() * 50.0,
      itemSeq: random.nextInt(10),
      isrccCd: '${random.nextInt(5)}',
      isrccNm: '${random.nextInt(5)}',
      isrcRt: random.nextInt(3),
      isrcAmt: random.nextInt(3),
      taxTyCd: '${random.nextInt(3)}',
      bcd: '${random.nextInt(5)}',
      itemClsCd: '${random.nextInt(5)}',
      itemTyCd: '${random.nextInt(5)}',
      itemStdNm: '${random.nextInt(5)}',
      orgnNatCd: '${random.nextInt(3)}',
      pkg: '${random.nextInt(5)}',
      itemCd: '${random.nextInt(5)}',
      pkgUnitCd: '${random.nextInt(5)}',
      qtyUnitCd: '${random.nextInt(5)}',
      itemNm: '${random.nextInt(5)}',
      splyAmt: random.nextDouble() * 40.0,
      tin: random.nextInt(100000),
      bhfId: '${random.nextInt(5)}',
      dftPrc: random.nextDouble() * 30.0,
      addInfo: '${random.nextInt(5)}',
      isrcAplcbYn: '${random.nextInt(2)}',
      useYn: '${random.nextInt(2)}',
      regrId: '${random.nextInt(5)}',
      regrNm: '${random.nextInt(5)}',
      modrId: '${random.nextInt(5)}',
      modrNm: '${random.nextInt(5)}',
      lastTouched: DateTime.now(),
      deletedAt: random.nextBool() ? DateTime.now() : null,
    );
  }

  // Return a list with a specified number of generated items
  const numItems = 20;
  return List.generate(numItems, (_) => _generateSingleDummyTransactionItem());
}

ITransaction generateDummyTransaction() {
  final random = Random();

  return ITransaction(
    ObjectId(),
    id: random.nextInt(1000),
    reference: '${random.nextInt(1000)}',
    categoryId: '${random.nextInt(5)}',
    transactionNumber: '${random.nextInt(1000)}',
    branchId: random.nextInt(10),
    status: '${random.nextInt(2)}',
    transactionType: '${random.nextInt(2)}',
    subTotal: 15000.0,
    paymentType: '${random.nextInt(2)}',
    cashReceived: 20000.0,
    customerChangeDue: 5000,
    createdAt: DateTime.now().toIso8601String(),
    receiptType: '${random.nextInt(3)}',
    updatedAt: DateTime.now().toIso8601String(),
    customerId: random.nextInt(1000),
    note: '${random.nextInt(100)}',
    lastTouched: DateTime.now(),
    action: '${random.nextInt(3)}',
    ticketName: '${random.nextInt(100)}',
    deletedAt: random.nextBool() ? DateTime.now() : null,
    supplierId: random.nextBool() ? random.nextInt(50) : null,
    // ebmSynced: random.nextBool(),
  );
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _incrementCounter() {
    // ZReport().printZReport(
    //   totalNumberSalesNS: 26,
    //   totalAmountSalesNS: 191921000,
    //   totalNumberCopySalesNS: 0,
    //   totalAmountCopySalesNS: 0.0,
    //   totalNumberRefundNR: 0,
    //   totalAmountRefundNR: 0.00,
    //   totalTaxableAEX: 0.0,
    //   totalTaxableB: 191921000,
    //   totalTaxableC: 0.00,
    //   totalTaxableD: 0.00,
    //   totalTaxeAEX: 0.00,
    //   totalTaxeB: 29276084.75,
    //   totalTaxeC: 0.00,
    //   totalTaxeD: 0.00,
    //   refundTaxableAEX: 0.00,
    //   refundTaxableB: 0.00,
    //   refundTaxableC: 0.00,
    //   refundTaxableD: 0.00,
    //   refundTaxeAEX: 0.00,
    //   refundTaxeB: 0.00,
    //   refundTaxeC: 0.00,
    //   refundTaxeD: 0.00,
    // );
    ITransaction transaction = generateDummyTransaction();
    Printable print = OmniPrinter();
    print.generatePdfAndPrint(
      // grandTotal: transaction.subTotal,
      // currencySymbol: "RW",
      totalPayable: 3000,
      // totalPayable: 3000,
      transaction: transaction,
      totalAEx: 0,
      items: generateDummyTransactionItems(),
      totalB18: (transaction.subTotal * 18 / 118).toStringAsFixed(2),
      totalB: transaction.subTotal,
      totalTax: (transaction.subTotal * 18 / 118).toStringAsFixed(2),
      cash: transaction.subTotal,
      received: transaction.cashReceived,
      payMode: "Cash",
      mrc: "MRCNO",
      internalData: "receiptintrlData",
      receiptQrCode: "receiptqrCode",
      receiptSignature: "receiptrcptSign",
      cashierName: "YEGOBOX",
      sdcId: "SDCID",
      sdcReceiptNum: "30",
      invoiceNum: 30,
      brandName: "YEGOBOX",
      brandAddress: "Kigali,Rwanda",
      brandTel: "0783054874",
      brandTIN: "00000000",
      brandDescription: "Description",
      brandFooter: "Thank you",
      emails: ['info@yegobox.com'],
      customerTin: "0000000000",
      receiptType: "NS",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '0',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
