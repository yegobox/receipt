import 'dart:math';

import 'package:flipper_models/isar_models.dart';
import 'package:flutter/material.dart';
import 'package:receipt/print.dart';

TransactionItem generateDummyTransactionItem() {
  final random = Random();

  return TransactionItem(
    id: 'dummy_id_${random.nextInt(1000)}',
    action: 'dummy_action_${random.nextInt(3)}',
    name: 'dummy_name_${random.nextInt(1000)}',
    transactionId: 'dummy_transaction_id_${random.nextInt(1000)}',
    variantId: 'dummy_variant_id_${random.nextInt(1000)}',
    qty: random.nextDouble() * 10.0,
    price: random.nextDouble() * 50.0,
    branchId: random.nextInt(10),
    remainingStock: random.nextDouble() * 20.0,
    createdAt: DateTime.now().toIso8601String(),
    updatedAt: DateTime.now().toIso8601String(),
    isTaxExempted: random.nextBool(),
    prc: random.nextDouble() * 30.0,
    discount: random.nextDouble() * 10.0,
    type: 'dummy_type_${random.nextInt(2)}',
    isRefunded: random.nextBool(),
    doneWithTransaction: random.nextBool(),
    active: random.nextBool(),
    dcRt: random.nextDouble() * 5.0,
    dcAmt: random.nextDouble() * 10.0,
    taxblAmt: random.nextDouble() * 15.0,
    taxAmt: random.nextDouble() * 5.0,
    totAmt: random.nextDouble() * 50.0,
    itemSeq: 'dummy_item_seq_${random.nextInt(10)}',
    isrccCd: 'dummy_isrcc_cd_${random.nextInt(5)}',
    isrccNm: 'dummy_isrcc_nm_${random.nextInt(5)}',
    isrcRt: 'dummy_isrc_rt_${random.nextInt(3)}',
    isrcAmt: 'dummy_isrc_amt_${random.nextInt(3)}',
    taxTyCd: 'dummy_tax_ty_cd_${random.nextInt(3)}',
    bcd: 'dummy_bcd_${random.nextInt(5)}',
    itemClsCd: 'dummy_item_cls_cd_${random.nextInt(5)}',
    itemTyCd: 'dummy_item_ty_cd_${random.nextInt(5)}',
    itemStdNm: 'dummy_item_std_nm_${random.nextInt(5)}',
    orgnNatCd: 'dummy_orgn_nat_cd_${random.nextInt(3)}',
    pkg: 'dummy_pkg_${random.nextInt(5)}',
    itemCd: 'dummy_item_cd_${random.nextInt(5)}',
    pkgUnitCd: 'dummy_pkg_unit_cd_${random.nextInt(5)}',
    qtyUnitCd: 'dummy_qty_unit_cd_${random.nextInt(5)}',
    itemNm: 'dummy_item_nm_${random.nextInt(5)}',
    splyAmt: random.nextDouble() * 40.0,
    tin: random.nextInt(100000),
    bhfId: 'dummy_bhf_id_${random.nextInt(5)}',
    dftPrc: random.nextDouble() * 30.0,
    addInfo: 'dummy_add_info_${random.nextInt(5)}',
    isrcAplcbYn: 'dummy_isrc_aplcb_yn_${random.nextInt(2)}',
    useYn: 'dummy_use_yn_${random.nextInt(2)}',
    regrId: 'dummy_regr_id_${random.nextInt(5)}',
    regrNm: 'dummy_regr_nm_${random.nextInt(5)}',
    modrId: 'dummy_modr_id_${random.nextInt(5)}',
    modrNm: 'dummy_modr_nm_${random.nextInt(5)}',
    lastTouched: DateTime.now(),
    deletedAt: random.nextBool() ? DateTime.now() : null,
  );
}

ITransaction generateDummyTransaction() {
  final random = Random();

  return ITransaction(
    id: 'dummy_id_${random.nextInt(1000)}',
    reference: 'dummy_reference_${random.nextInt(1000)}',
    categoryId: 'dummy_category_${random.nextInt(5)}',
    transactionNumber: 'dummy_transaction_number_${random.nextInt(1000)}',
    branchId: random.nextInt(10),
    status: 'dummy_status_${random.nextInt(2)}',
    transactionType: 'dummy_transaction_type_${random.nextInt(2)}',
    subTotal: random.nextDouble() * 100.0,
    paymentType: 'dummy_payment_type_${random.nextInt(2)}',
    cashReceived: random.nextDouble() * 50.0,
    customerChangeDue: random.nextDouble() * 20.0,
    createdAt: DateTime.now().toIso8601String(),
    receiptType: 'dummy_receipt_type_${random.nextInt(3)}',
    updatedAt: DateTime.now().toIso8601String(),
    customerId: 'dummy_customer_id_${random.nextInt(100)}',
    note: 'dummy_note_${random.nextInt(100)}',
    lastTouched: DateTime.now(),
    action: 'dummy_action_${random.nextInt(3)}',
    ticketName: 'dummy_ticket_${random.nextInt(100)}',
    deletedAt: random.nextBool() ? DateTime.now() : null,
    supplierId: random.nextBool() ? random.nextInt(50) : null,
    ebmSynced: random.nextBool(),
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
  int _counter = 0;

  void _incrementCounter() {
    ITransaction transaction = generateDummyTransaction();
    Print print = Print();
    print.print(
      grandTotal: 500,
      currencySymbol: "RW",
      transaction: transaction,
      totalAEx: 0,
      items: [generateDummyTransactionItem()],
      totalB18: (500 * 18 / 118).toStringAsFixed(2),
      totalB: 500,
      totalTax: (500 * 18 / 118).toStringAsFixed(2),
      cash: 500,
      received: 100,
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
              '$_counter',
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
