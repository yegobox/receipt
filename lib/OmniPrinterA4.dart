import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:receipt/SaveFile.dart';
import 'package:receipt/printable.dart';
import 'package:flipper_models/realm_model_export.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart' as c;
import 'package:printing/printing.dart';

class OmniPrinterA4 with SaveFile implements Printable {
  Future<ImageProvider?> _loadLogoImage({required String position}) async {
    ImageProvider? image;
    switch (position) {
      case "left":
        const imageLogo =
            c.AssetImage('assets/logo_left.png', package: 'receipt');
        image = await flutterImageProvider(imageLogo,
            configuration: const c.ImageConfiguration(size: Size(600, 600)));
        break;
      case "middle":
        const imageLogo =
            c.AssetImage('assets/flipper_logo.png', package: 'receipt');
        image = await flutterImageProvider(imageLogo,
            configuration: const c.ImageConfiguration(size: Size(100, 100)));
        break;
      case "right":
        const imageLogo =
            c.AssetImage('assets/logo_right.png', package: 'receipt');
        image = await flutterImageProvider(imageLogo,
            configuration: const c.ImageConfiguration(size: Size(100, 100)));
        break;
      default:
        throw ArgumentError('Invalid position: $position');
    }
    return image;
  }

  @override
  Future<void> generatePdfAndPrint({
    required double taxA,
    required double taxB,
    required double taxC,
    required double taxD,
    required double totalDiscount,
    String brandName = "yegobox shop",
    String brandAddress = "CITY CENTER, Kigali Rwanda",
    String brandTel = "271311123",
    String brandTIN = "1211287390",
    String brandDescription = "We build app that server you!",
    String brandFooter = "yegobox shop",
    List<String>? emails,
    String? customerTin = "000000000",
    required List<TransactionItem> items,
    required String receiptType,
    required String totalTax,
    required double cash,
    required String cashierName,
    required double received,
    required String payMode,
    required String sdcId,
    required String internalData,
    required String receiptSignature,
    required String receiptQrCode,
    required int invoiceNum,
    required String mrc,
    required double totalPayable,
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
  }) async {
    final pdf = Document();
    final left = await _loadLogoImage(position: "left");
    final middle = await _loadLogoImage(position: "middle");
    final right = await _loadLogoImage(position: "right");
    pdf.addPage(
      Page(
        pageFormat: PdfPageFormat.a4,
        build: (Context context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (left != null) Image(left, width: 40, height: 40),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            brandName.substring(0,
                                brandName.length > 20 ? 20 : brandName.length),
                          ),
                          SizedBox(height: 4),
                          Text('TEL: $brandTel'),
                          SizedBox(height: 2),
                          Text('TIN: $brandTIN'),
                        ],
                      )
                    ],
                  ),
                  SizedBox(width: 100),
                  if (right != null)
                    Image(right, width: 40, height: 40)
                  else
                    SizedBox(width: 100),
                ],
              ),
              SizedBox(height: 20),

              // Invoice Information
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('INVOICE TO',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        // width: 250,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: PdfColors.black,
                            width: 0.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('TIN: $customerTin'),
                              SizedBox(height: 5),
                              Text('Name: $customerName'),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Container(
                        // width: 250,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: PdfColors.black,
                            width: 0.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('INVOICE NO: $rcptNo'),
                              SizedBox(height: 5),
                              Text('Date: ${whenCreated.shortDate}'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(height: 15),

              // Item Table Header
              TableHelper.fromTextArray(
                headers: [
                  'Item Code',
                  'Description',
                  'Qty',
                  'Tax',
                  'Unit Price',
                  'Total Price'
                ],
                data: [
                  ...items.map((item) => [
                        item.itemCd,
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name ?? ""),
                            if (item.dcRt != 0)
                              Text("Discount - ${item.dcRt}%"),
                          ],
                        ),
                        '${item.qty}',
                        '${item.taxTyCd}',
                        item.price.toNoCurrencyFormatted(),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text((item.qty * item.price)
                                .toNoCurrencyFormatted()),
                            if (item.dcRt != 0)
                              Text(
                                ((item.qty * item.price) -
                                        (item.qty *
                                            item.price *
                                            item.dcRt /
                                            100))
                                    .toNoCurrencyFormatted(),
                              ),
                          ],
                        ),
                      ]),
                  // Padding the table with empty rows to maintain a minimum of 10 rows
                  if (items.length < 10)
                    ...List.generate(
                      110 - items.length,
                      (_) => ['', '', '', '', '', ''],
                    ),
                ],
                headerStyle:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                cellStyle: const TextStyle(fontSize: 10),
                cellAlignment: Alignment.topLeft,
                headerHeight: 40,
                columnWidths: {
                  0: const FixedColumnWidth(60),
                  1: const FlexColumnWidth(),
                  2: const FixedColumnWidth(30),
                  3: const FixedColumnWidth(30),
                  4: const FixedColumnWidth(60),
                  5: const FixedColumnWidth(60),
                },
                headerDecoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(width: 0.5),
                    bottom: BorderSide(width: 0.5),
                    left: BorderSide(width: 0.5),
                    right: BorderSide(width: 0.5),
                  ),
                ),
                border: const TableBorder(
                  right: BorderSide(width: 0.5),
                  left: BorderSide(width: 0.5),
                  bottom: BorderSide(width: 0.5),
                  horizontalInside: BorderSide.none,
                  verticalInside: BorderSide(width: 0.5),
                ),
                cellPadding:
                    const EdgeInsets.symmetric(vertical: 1, horizontal: 5),
              ),

              SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // SDC Information
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SDC INFORMATION',
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.bold)),
                        dashWidget(),
                        SizedBox(height: 5),
                        Text('Date: ${whenCreated.isoDateTime}',
                            style: const TextStyle(fontSize: 10)),
                        Text('SDC ID: $sdcId',
                            style: const TextStyle(fontSize: 10)),
                        Text(
                          'Receipt Number: $rcptNo/$totRcptNo ($receiptType)',
                          style: const TextStyle(fontSize: 10),
                        ),
                        if (receiptType != "PS" && receiptType != "TS")
                          Text(
                            'Internal Data: ${internalData.toDashedStringInternalData()}',
                            style: const TextStyle(fontSize: 10),
                          ),
                        if (receiptType != "PS" && receiptType != "TS")
                          Text(
                            'Receipt Signature: ${receiptSignature.toDashedStringRcptSign()}',
                            style: const TextStyle(fontSize: 10),
                          ),
                        SizedBox(height: 5),
                        dashWidget(),
                        SizedBox(height: 5),
                        Text(
                          'Receipt Number: $invoiceNum',
                          style: const TextStyle(fontSize: 10),
                        ),
                        Text('Date: ${whenCreated.shortDate}',
                            style: const TextStyle(fontSize: 10)),
                        Text('MRC: $mrc', style: const TextStyle(fontSize: 10)),
                        dashWidget(),
                      ],
                    ),
                  ),
                  if (receiptType != "PS" && receiptType != "TS")
                    SizedBox(width: 20),
                  if (receiptType != "PS" && receiptType != "TS")
                    Center(
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: BarcodeWidget(
                          barcode: Barcode.qrCode(
                            errorCorrectLevel: BarcodeQRCorrectionLevel.high,
                          ),
                          data: receiptQrCode,
                        ),
                      ),
                    ),
                  SizedBox(width: 20), // Space between columns

                  // Summary Table
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(height: 5),
                        Table(
                          border: TableBorder.all(width: 0.5),
                          children: [
                            TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Text('Total Rwf'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Text((totalPayable - totalDiscount)
                                      .toNoCurrencyFormatted()),
                                ),
                              ],
                            ),
                            if (totalTaxA != 0)
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Text('Total A-EX Rwf'),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4),
                                    child:
                                        Text(totalTaxA.toNoCurrencyFormatted()),
                                  ),
                                ],
                              ),
                            TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Text('Total B-18% Rwf'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4),
                                  child:
                                      Text(totalTaxB.toNoCurrencyFormatted()),
                                ),
                              ],
                            ),
                            if (totalTaxD != 0)
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Text('Total D'),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4),
                                    child:
                                        Text(totalTaxD.toNoCurrencyFormatted()),
                                  ),
                                ],
                              ),
                            TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Text('Total Tax Rwf'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Text(double.parse(totalTax)
                                      .toNoCurrencyFormatted()),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30),
              // Footer
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('POWERED BY RRA VSDC EBM2.1',
                    style:
                        TextStyle(fontStyle: FontStyle.normal, fontSize: 10)),
                SizedBox(width: 30),
                if (middle != null) Image(middle, width: 20, height: 40),
              ])
            ],
          );
        },
      ),
    );

    Uint8List pdfData = await pdf.save();
    handlePdfData(
      pdfData: pdfData,
      emails: emails,
      autoPrint: autoPrint,
    );
    return printCallback(pdfData);
  }
}
