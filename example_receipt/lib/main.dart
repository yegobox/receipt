import 'package:flutter/material.dart';
import 'package:flipper_models/realm_model_export.dart';
import 'package:flutter/services.dart';
import 'package:receipt/OmniPrinterA4.dart';
import 'package:receipt/omni_printer.dart';
import 'package:receipt/printable.dart';

// import 'package:flipper_rw/dependencyInitializer.dart';

Future<void> main() async {
  // await initializeDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<void> print({
    required double grandTotal,
    required String currencySymbol,
    required String totalTax,
    required double cash,
    required double received,
    required String sdcId,
    required int invoiceNum,
    required double taxA,
    required double taxB,
    required double taxC,
    required double taxD,
    required String brandName,
    required String brandAddress,
    required String brandTel,
    required String brandTIN,
    required String brandDescription,
    required String brandFooter,
    required String cashierName,
    required String payMode,
    required String mrc,
    required String internalData,
    required String receiptSignature,
    required String receiptQrCode,
    required List<String> emails,
    required String? customerTin,
    required String receiptType,
    required List<TransactionItem> items,
    required ITransaction transaction,
    bool? autoPrint = false,
    required double totalTaxA,
    required double totalTaxB,
    required double totalTaxC,
    required double totalTaxD,
    required String customerName,
    required int rcptNo,
    required int totRcptNo,
    required DateTime whenCreated,
    required Function(Uint8List bytes) printCallback,
    required double totalDiscount,
  }) async {
    Printable printer = OmniPrinter();
    Printable printerA4 = OmniPrinterA4();

    return await printerA4.generatePdfAndPrint(
      taxB: taxB,
      totalDiscount: totalDiscount,
      taxA: taxA,
      taxC: taxC,
      whenCreated: whenCreated,
      taxD: taxD,
      brandName: brandName,
      customerName: customerName,
      brandAddress: brandAddress,
      brandDescription: brandDescription,
      brandTel: brandTel,
      brandTIN: brandTIN,
      autoPrint: autoPrint,
      brandFooter: brandFooter,
      emails: emails,
      customerTin: customerTin.toString(),
      receiptType: receiptType,
      items: items,
      totalTax: totalTax,
      cash: cash,
      rcptNo: rcptNo,
      totRcptNo: totRcptNo,
      cashierName: cashierName,
      received: received,
      payMode: payMode,
      sdcId: sdcId,
      internalData: internalData,
      receiptSignature: receiptSignature,
      receiptQrCode: receiptQrCode,
      invoiceNum: invoiceNum,
      mrc: mrc,
      totalPayable: transaction.subTotal!,
      totalTaxA: totalTaxA,
      transaction: transaction,
      totalTaxB: totalTaxB,
      totalTaxC: totalTaxC,
      totalTaxD: totalTaxD,
      printCallback: (Uint8List bytes) {
        printCallback(bytes);
      },
    );
  }

  void _incrementCounter() {
    print(
      totalDiscount: 10,
      whenCreated: DateTime.now(),
      transaction: ITransaction(
        id: 2,
        subTotal: 400,
        branchId: 1,
        status: "complete",
        transactionType: "sale",
        paymentType: "Cash",
        cashReceived: 100,
        customerChangeDue: 100,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        customerId: 1,
        isIncome: true,
        isExpense: false,
      ),
      currencySymbol: "RW",
      grandTotal: 100,
      taxA: 10,
      taxB: 20,
      taxC: 30,
      taxD: 40,
      brandName: 'MyBrand',
      customerName: 'Customer',
      brandAddress: 'Brand Address',
      brandDescription: 'Brand Description',
      brandTel: '0783054874',
      brandTIN: '82828838383838',
      autoPrint: false,
      brandFooter: 'Brand Footer',
      emails: ['email1', 'email2'],
      customerTin: 'Customer TIN',
      receiptType: 'Receipt Type',
      items: List.from(
        [
          TransactionItem(
            itemNm: "nama",
            discount: 10,
            remainingStock: 10,
            prc: 10,
            id: 1,
            itemCd: "002",
            name: 'Item 1',
            qty: 2,
            taxTyCd: "A",
            dcRt: 10,
            price: 10.0,
          ),
          TransactionItem(
            itemNm: "nama",
            discount: 10,
            remainingStock: 10,
            prc: 10,
            id: 1,
            itemCd: "002",
            name: 'Item 1',
            qty: 2,
            taxTyCd: "A",
            dcRt: 10,
            price: 10.0,
          ),
          TransactionItem(
            itemNm: "nama",
            discount: 10,
            remainingStock: 10,
            prc: 10,
            id: 1,
            itemCd: "002",
            name: 'Item 1',
            qty: 2,
            taxTyCd: "A",
            dcRt: 10,
            price: 10.0,
          ),
          // TransactionItem(
          //
          //   id: 1,
          //   itemCd: "002",
          //   name: 'Item 1',
          //   qty: 2,
          //   taxTyCd: "A",
          //   dcRt: 10,
          //   price: 10.0,
          // ),
          // TransactionItem(
          //
          //   id: 1,
          //   itemCd: "002",
          //   name: 'Item 1',
          //   qty: 2,
          //   taxTyCd: "A",
          //   dcRt: 10,
          //   price: 10.0,
          // ),
          // TransactionItem(
          //
          //   id: 1,
          //   itemCd: "002",
          //   name: 'Item 1',
          //   qty: 2,
          //   taxTyCd: "A",
          //   dcRt: 10,
          //   price: 10.0,
          // ),
          // TransactionItem(
          //
          //   id: 1,
          //   itemCd: "002",
          //   name: 'Item 1',
          //   qty: 2,
          //   taxTyCd: "A",
          //   dcRt: 10,
          //   price: 10.0,
          // ),
          // TransactionItem(
          //
          //   id: 1,
          //   itemCd: "002",
          //   name: 'Item 1',
          //   qty: 2,
          //   taxTyCd: "A",
          //   dcRt: 10,
          //   price: 10.0,
          // ),
          // TransactionItem(
          //
          //   id: 1,
          //   itemCd: "002",
          //   name: 'Item 1',
          //   qty: 2,
          //   taxTyCd: "A",
          //   dcRt: 10,
          //   price: 10.0,
          // ),
          // TransactionItem(
          //
          //   id: 1,
          //   itemCd: "002",
          //   name: 'Item 1',
          //   qty: 2,
          //   taxTyCd: "A",
          //   dcRt: 10,
          //   price: 10.0,
          // ),
          // TransactionItem(
          //
          //   id: 1,
          //   itemCd: "002",
          //   name: 'Item 1',
          //   qty: 2,
          //   taxTyCd: "A",
          //   dcRt: 10,
          //   price: 10.0,
          // ),
          // TransactionItem(
          //
          //   id: 1,
          //   itemCd: "002",
          //   name: 'Item 1',
          //   qty: 2,
          //   taxTyCd: "A",
          //   dcRt: 10,
          //   price: 10.0,
          // ),
          // TransactionItem(
          //
          //   id: 1,
          //   itemCd: "002",
          //   name: 'Item 1',
          //   qty: 2,
          //   taxTyCd: "A",
          //   dcRt: 10,
          //   price: 10.0,
          // ),
          // TransactionItem(
          //
          //   id: 1,
          //   itemCd: "002",
          //   name: 'Item 1',
          //   qty: 2,
          //   taxTyCd: "A",
          //   dcRt: 10,
          //   price: 10.0,
          // ),
          // TransactionItem(
          //
          //   id: 1,
          //   itemCd: "002",
          //   name: 'Item 1',
          //   qty: 2,
          //   taxTyCd: "A",
          //   dcRt: 10,
          //   price: 10.0,
          // ),
          // TransactionItem(
          //
          //   id: 1,
          //   itemCd: "002",
          //   name: 'Item 1',
          //   qty: 2,
          //   taxTyCd: "A",
          //   dcRt: 10,
          //   price: 10.0,
          // ),
          // TransactionItem(
          //
          //   id: 1,
          //   itemCd: "002",
          //   name: 'Item 1',
          //   qty: 2,
          //   taxTyCd: "A",
          //   dcRt: 10,
          //   price: 10.0,
          // ),
          // TransactionItem(
          //
          //   id: 1,
          //   itemCd: "002",
          //   name: 'Item 1',
          //   qty: 2,
          //   taxTyCd: "A",
          //   dcRt: 10,
          //   price: 10.0,
          // ),
          // TransactionItem(
          //
          //   id: 1,
          //   itemCd: "002",
          //   name: 'Item 1',
          //   qty: 2,
          //   taxTyCd: "A",
          //   dcRt: 10,
          //   price: 10.0,
          // ),
        ],
      ),
      totalTax: "100",
      cash: 200,
      rcptNo: 1,
      totRcptNo: 1,
      cashierName: 'Cashier Name',
      received: 300,
      payMode: 'Pay Mode',
      sdcId: 'SDC ID',
      internalData: 'Internal Data',
      receiptSignature: 'Receipt Signature',
      receiptQrCode: 'Receipt QR Code',
      invoiceNum: 10,
      mrc: 'MRC',
      totalTaxA: 500,
      totalTaxB: 600,
      totalTaxC: 700,
      totalTaxD: 800,
      printCallback: (Uint8List bytes) {
        // printCallback(bytes);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              'L',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
