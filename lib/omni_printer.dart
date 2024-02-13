library receipt;

import 'dart:developer';
import 'dart:io';
import 'package:flipper_models/isar_models.dart' as isar;
import 'package:lecle_downloads_path_provider/lecle_downloads_path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flipper_services/proxy.dart';
import 'package:flutter/material.dart' as c;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';

final isDesktopOrWeb = UniversalPlatform.isDesktopOrWeb;

/// [generatePdfAndPrint] example
/// an extension on DateTime that return a string of date time separated by space

extension DateTimeToDateTimeString on DateTime {
  String toDateTimeString() {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm:ss');
    final dateString = dateFormat.format(this);
    final timeString = timeFormat.format(this);
    return '$dateString $timeString';
  }
}

/// given a string E2P2VANEFD7PWY3COLUULSL3JU as a string, I want an extension that take
/// this string and apply dashed dashes come after 4 char
extension StringToDashedString on String {
  String toDashedString() {
    if (isEmpty) {
      return '';
    }

    var x = 0;
    final dashesInternalData = {2, 3, 4, 5, 6, 7};
    final replacedInternalData = splitMapJoin(RegExp('....'),
        onNonMatch: (s) => dashesInternalData.contains(x++) ? '-' : '');
    return replacedInternalData;
  }
}

class OmniPrinter {
  final doc = Document(version: PdfVersion.pdf_1_5, compress: true);
  // List<TableRow> rows = [];
  // DateTime dateTime = DateTime.now();
  // String date = "";
  // String time = "";
  // double totalPrice = 0;
  // double totalItems = 0;
  // Future<List<TableRow>> feed(
  //   List<isar.TransactionItem> items,
  // ) async {
  //   date = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  //   time = "${dateTime.hour}:${dateTime.minute}:${dateTime.second}";

  //   for (var item in items) {
  //     // if the isRefunded is null i.e the item has not been refunded so we add it to the total price
  //     if (item.isRefunded == null) {
  //       totalItems = totalItems + 1;
  //       double total = item.price * item.qty;
  //       totalPrice = total + totalPrice;
  //       String taxLabel = item.isTaxExempted ? "-EX" : "-B";
  //       rows.add(TableRow(children: [
  //         Text(item.name, style: TextStyle(font: font,)),
  //       ]));
  //       rows.add(TableRow(children: [
  //         Text((item.price).toString()),
  //         Text(item.qty.toString()),
  //         Text(
  //           "$total $taxLabel",
  //           style: TextStyle(
  //             font: font,,
  //           ),
  //         ),
  //       ]));
  //       rows.add(TableRow(children: [
  //         SizedBox(height: 1),
  //       ]));
  //     }
  //   }
  //   return rows;
  // }

  List<Widget> rows = [];

  _loadLogoImage() async {
    ImageProvider? image;
    const imageLogo = c.AssetImage('assets/rra.jpg', package: 'receipt');
    image = await flutterImageProvider(imageLogo);
    return image;
  }

  _header({
    required ImageProvider image,
    required String brandAddress,
    required String brandTel,
    required String brandTIN,
    required String brandName,
    required String customerTin,
    required String receiptType,
    required String sdcReceiptNum,
  }) async {
    final font = await PdfGoogleFonts.nunitoExtraLight();
    rows.add(Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      SizedBox(width: 10),

      Row(children: [
        Image(image, width: 50, height: 50),
        // add space so one image is on left and another is on right
        Spacer(),
        Image(image, width: 50, height: 50),
      ]),
      Text(
        brandAddress,
      ),
      SizedBox(height: 1),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          "Tel:$brandTel",
          style: TextStyle(font: font, fontSize: 14),
        ),
      ]),

      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'TIN:',
            style: TextStyle(
              font: font,
              fontSize: 14,
            ),
          ),
          Text(
            brandTIN,
            style: TextStyle(
              font: font,
              fontSize: 12,
            ),
          ),
        ],
      ),
      SizedBox(height: 1),
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          'Welcome to $brandName',
          style: TextStyle(
            font: font,
            fontSize: 14,
          ),
        ),
        Text(
          'Client ID: $customerTin',
          style: TextStyle(
            font: font,
            fontSize: 14,
          ),
        ),
      ]),

      // add wording
      if (receiptType == "NR")
        Text(
          'Refund',
          style: TextStyle(
            font: font,
            fontSize: 14,
          ),
        ),
      if (receiptType == "NR")
        Text(
          'REF.NORMAL RECEIPT:# $sdcReceiptNum',
          style: TextStyle(
            font: font,
          ),
        ),
      if (receiptType == "NR")
        Text(
          'REFUND IS APPROVED FOR CLIENT ID:$customerTin',
          style: TextStyle(
            font: font,
          ),
        ),
      if (receiptType == "CS")
        Text(
          'COPY',
          style: TextStyle(
            font: font,
            fontSize: 14,
          ),
        ),
      if (receiptType == "CS") SizedBox(height: 1),
      if (receiptType == "CS")
        Text(
          'REF.NORMAL RECEIPT#:$sdcReceiptNum',
          style: TextStyle(
            font: font,
            fontSize: 14,
          ),
        ),
      if (receiptType != "CS") SizedBox(height: 1),
      if (receiptType == "CS")
        Text(
          'REFUND IS APPROVED FOR CLIENT ID:$customerTin',
          style: TextStyle(
            font: font,
            fontSize: 10,
          ),
        ),
      if (receiptType == "TS")
        Text(
          'TRAINING MODE',
          style: TextStyle(
            font: font,
            fontSize: 14,
          ),
        ),
    ]));
  }

  _buildTotalTax({required String totalTax}) async {
    final font = await PdfGoogleFonts.nunitoExtraLight();
    rows.add(
      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Text(
          'TOTAL TAX:',
          style: TextStyle(
            font: font,
          ),
        ),
        SizedBox(),
        Text(totalTax,
            style: TextStyle(
              font: font,
            ))
      ]),
    );
  }

  _buildTaxB({required String totalTaxB}) async {
    final font = await PdfGoogleFonts.nunitoExtraLight();
    rows.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'TOTAL B-18%:',
            style: TextStyle(
              font: font,
            ),
          ),
          SizedBox(),
          Text(
            totalTaxB,
            style: TextStyle(
              font: font,
            ),
          )
        ],
      ),
    );
  }

  _buildTotal({required String totalPrice}) async {
    final font = await PdfGoogleFonts.nunitoExtraLight();
    rows.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'TOTAL:',
            style: TextStyle(
              font: font,
            ),
          ),
          SizedBox(),
          Text(
            totalPrice,
            style: TextStyle(
              font: font,
            ),
          )
        ],
      ),
    );
  }

  _buildAEx({required String totalAEx}) async {
    final font = await PdfGoogleFonts.nunitoExtraLight();
    rows.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'TOTAL A-EX:',
            style: TextStyle(
              font: font,
            ),
          ),
          SizedBox(),
          Text(
            "{$totalAEx}",
            style: TextStyle(
              font: font,
            ),
          )
        ],
      ),
    );
  }

  _body({
    required List<isar.TransactionItem> items,
    required String receiptType,
    required String totalPrice,
    required String totalAEx,
    required String totalB18,
    required String totalB,
    required String totalTax,
    required double received,
    required String cashierName,
    required double cash,
    required String payMode,
  }) async {
    final font = await PdfGoogleFonts.nunitoExtraLight();
    var bodyWidgets = <Widget>[];

    // Add the table headers
    List<List<String>> data = <List<String>>[];

    // Add the table headers
    data.add(<String>['Items', 'Price', 'Qty', 'Total']);

    // Iterate over the items
    for (var item in items) {
      double total = item.price * item.qty;
      log(item.name, name: "in the loop");
      String taxLabel = item.isTaxExempted ? "(EX)" : "(B)";

      // Add a row for each item
      data.add(
        <String>[
          item.name.length > 5 ? item.name.substring(0, 5) : item.name,
          item.price.toString(),
          item.qty.toString(),
          '$total $taxLabel',
        ],
      );
    }

    // Add the table to bodyWidgets
    bodyWidgets.add(
      TableHelper.fromTextArray(
        cellStyle: TextStyle(font: font),
        headerStyle: TextStyle(font: font, color: PdfColors.grey),
        border: null,
        cellPadding: EdgeInsets.zero,
        cellAlignments: {
          0: Alignment.centerLeft,
          1: Alignment.centerRight,
          2: Alignment.centerRight,
          3: Alignment.centerRight,
        },
        data: data,
      ),
    );

    rows.add(
      Column(
        children: bodyWidgets,
      ),
    );

    Column row = Column(
      children: [],
    );
    if (receiptType != "CS") {
      rows.add(
        Column(children: [SizedBox(height: 10)]),
      );
    }
    if (receiptType == "TS" || receiptType == "PS") {
      row = Column(children: [
        SizedBox(),
        Text(
          'THIS IS NOT AN OFFICIAL RECEIPT',
          textAlign: TextAlign.center,
          style: TextStyle(font: font),
        ),
        SizedBox(),
      ]);
      rows.add(row);
    }
    rows.add(
      Column(children: [
        Divider(thickness: 0.1, color: PdfColors.black),
      ]),
    );
    await _buildTotal(totalPrice: totalPrice);
    await _buildAEx(totalAEx: totalAEx);
    await _buildTaxB(totalTaxB: totalB18);
    await _buildTotalTax(totalTax: totalTax);

    rows.add(
      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        SizedBox(height: 1),
      ]),
    );

    rows.add(
      Column(children: [
        SizedBox(height: 1),
      ]),
    );
    rows.add(Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      Text(
        'CASH:',
        style: TextStyle(
          font: font,
        ),
      ),
      SizedBox(),
      Text(received.toString(),
          style: TextStyle(
            font: font,
          ))
    ]));
    rows.add(Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      Text(
        'ITEMS NUMBER:',
        style: TextStyle(
          font: font,
        ),
      ),
      SizedBox(),
      Text(items.length.toString(),
          style: TextStyle(
            font: font,
          ))
    ]));
    rows.add(Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      Text(
        'Cashier Name:',
        style: TextStyle(
          font: font,
        ),
      ),
      SizedBox(),
      Text(cashierName.toString(),
          style: TextStyle(
            font: font,
          ))
    ]));

    rows.add(
      Column(children: [
        SizedBox(height: 1),
      ]),
    );
    rows.add(
      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Text(
          'Received Amount: $received',
          style: TextStyle(
            font: font,
          ),
        ),
      ]),
    );
    rows.add(
      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Text("Change: ${cash - received}",
            style: TextStyle(
              font: font,
            ))
      ]),
    );
    rows.add(
      Column(children: [
        SizedBox(height: 1),
      ]),
    );
    rows.add(
      Column(children: [
        SizedBox(height: 10),
      ]),
    );
    rows.add(
      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Text('Pay Mode:',
            style: TextStyle(
              font: font,
            )),
        Spacer(),
        Text(
          payMode,
          style: TextStyle(
            font: font,
          ),
        ),
      ]),
    );
    rows.add(
      Column(children: [
        Divider(height: 1),
      ]),
    );
    rows.add(
      Column(children: [
        SizedBox(height: 10),
      ]),
    );
    if (receiptType == "TS") {
      row = Column(children: [
        SizedBox(),
        Text(
          'TRAINING MODE',
          textAlign: TextAlign.center,
          style: TextStyle(
            font: font,
          ),
        ),
        SizedBox(),
      ]);
      rows.add(row);
    }

    if (receiptType == "PS") {
      row = Column(children: [
        SizedBox(),
        Text(
          'PROFORMA',
          textAlign: TextAlign.center,
          style: TextStyle(
            font: font,
          ),
        ),
        SizedBox(),
      ]);
      rows.add(row);
    }
  }

  _footer({
    required isar.ITransaction transaction,
    required String sdcId,
    required String sdcReceiptNum,
    required String receiptType,
    required String receiptSignature,
    required String internalData,
    required String receiptQrCode,
    required String invoiceNum,
    required String mrc,
  }) async {
    final font = await PdfGoogleFonts.nunitoExtraLight();
    rows.add(
      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        SizedBox(),
        Text(
          "SDC INFORMATION",
          textAlign: TextAlign.center,
          style: TextStyle(
            font: font,
          ),
        ),
        SizedBox(),
      ]),
    );
    rows.add(
      Column(children: [
        SizedBox(height: 1),
      ]),
    );
    rows.add(
      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        SizedBox(
          width: 150,
          child: Text(
            transaction.lastTouched?.toDateTimeString() ?? "",
            style: TextStyle(
              font: font,
            ),
          ),
        ),
      ]),
    );
    rows.add(
      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Text(
          'SDC ID:',
          style: TextStyle(
            font: font,
          ),
        ),
        Spacer(),
        Text(sdcId,
            style: TextStyle(
              font: font,
            )),
      ]),
    );
    rows.add(
      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Text(
          'RECEIPT NUMBER:',
          style: TextStyle(
            font: font,
          ),
        ),
        Spacer(),
        Text(
          "$sdcReceiptNum $receiptType",
          style: TextStyle(
            font: font,
          ),
        ),
      ]),
    );
    rows.add(
      Column(children: [
        SizedBox(height: 10),
      ]),
    );

    rows.add(
      Column(children: [
        Text(
          "Receipt Signature:",
          style: TextStyle(
            font: font,
          ),
        ),
        Text(
          receiptSignature.toDashedString(),
          style: TextStyle(font: font),
        ),
      ]),
    );
    rows.add(
      Column(children: [
        SizedBox(height: 1),
      ]),
    );
    rows.add(
      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Text(
          "Internal Data:",
          style: TextStyle(
            font: font,
          ),
        ),
      ]),
    );
    rows.add(
      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Text(
          internalData.toDashedString(),
          style: TextStyle(font: font),
        ),
      ]),
    );

    rows.add(
      Column(children: [
        SizedBox(height: 4),
      ]),
    );

    rows.add(
      Column(children: [
        SizedBox(),
        Center(
          child: SizedBox(
            width: 100,
            height: 100,
            child: BarcodeWidget(
              barcode: Barcode.qrCode(
                errorCorrectLevel: BarcodeQRCorrectionLevel.high,
              ),
              data: receiptQrCode,
            ),
          ),
        ),
        SizedBox(),
      ]),
    );
    rows.add(
      Column(children: [
        SizedBox(height: 4),
      ]),
    );
    rows.add(
      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Text(
          'INVOICE NUMBER:',
          style: TextStyle(
            font: font,
          ),
        ),
        Text(
          invoiceNum.toString(),
          style: TextStyle(
            font: font,
          ),
        ),
      ]),
    );
    rows.add(
      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        SizedBox(
          child: Text(
            transaction.lastTouched?.toDateTimeString() ?? "",
            style: TextStyle(
              font: font,
            ),
          ),
        ),
      ]),
    );

    rows.add(
      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Text(
          'MRC',
          style: TextStyle(
            font: font,
          ),
        ),
        Text(
          mrc,
          style: TextStyle(
            font: font,
          ),
        ),
      ]),
    );
    rows.add(
      Column(children: [
        SizedBox(height: 10),
        Text('Thank you!'),
      ]),
    );
    rows.add(
      Column(children: [
        SizedBox(height: 10),
        Text('EBM v2: v1.5'),
      ]),
    );
    // end of footer
  }

  Future<void> generatePdfAndPrint({
    String brandName = "yegobox shop",
    String brandAddress = "CITY CENTER, Kigali Rwanda",
    String brandTel = "27131153",
    String brandTIN = "101587390",
    String brandDescription = "We build app that server you!",
    String brandFooter = "yegobox shop",
    List<String>? emails,
    String? customerTin = "000000000",
    required List<isar.TransactionItem> items,
    required String receiptType,
    required String sdcReceiptNum,
    required String totalTax,
    required double totalB,
    required String totalB18,
    required double totalAEx,
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
    required double totalPrice,
    required isar.ITransaction transaction,
  }) async {
    final image = await _loadLogoImage();

    await _header(
      image: image,
      brandAddress: brandAddress,
      brandTel: brandTel,
      brandTIN: brandTIN,
      brandName: brandName,
      customerTin: customerTin!,
      receiptType: receiptType,
      sdcReceiptNum: sdcReceiptNum,
    );

    rows.add(
      Column(children: [
        Divider(height: 1),
      ]),
    );
    await _body(
      items: items,
      totalTax: totalTax,
      totalB: totalB.toString(),
      totalB18: totalB18,
      totalAEx: totalAEx.toString(),
      cash: cash,
      cashierName: cashierName,
      received: received,
      payMode: payMode,
      totalPrice: totalPrice.toString(),
      receiptType: receiptType,
    );

    await _footer(
      transaction: transaction,
      sdcId: sdcId,
      sdcReceiptNum: sdcReceiptNum,
      receiptType: receiptType,
      receiptSignature: receiptSignature,
      internalData: internalData,
      receiptQrCode: receiptQrCode,
      invoiceNum: invoiceNum.toString(),
      mrc: mrc,
    );

    doc.addPage(
      Page(
        pageFormat: PdfPageFormat.roll80,
        orientation: PageOrientation.portrait,
        build: (context) => Column(
          children: rows,
        ),
      ),
    );
    // experiment layout the pdf file
    Uint8List pdfData = await doc.save();
    handlePdfData(pdfData, emails);
  }

  Future<void> handlePdfData(
    Uint8List pdfData,
    List<String>? emails,
  ) async {
    if (ProxyService.box.isAutoPrintEnabled()) {
      if (isDesktopOrWeb) {
        // log("Share PDF", name: "PDF Generation");
        await Printing.layoutPdf(
            name: DateTime.now()
                .toIso8601String()
                .replaceAll('-', '')
                .replaceAll('.', '')
                .replaceAll(':', ''),
            onLayout: (PdfPageFormat format) async => pdfData);
      } else {
        Map<Permission, PermissionStatus> statuses = await [
          Permission.storage,
          Permission.manageExternalStorage
        ].request();
        if (statuses[Permission.storage]!.isGranted) {
          Directory? dir = await DownloadsPath.downloadsDirectory();
          var i = 0;
          final path = dir?.path;
          await for (final page in Printing.raster(pdfData, dpi: 150)) {
            final png = await page.toPng();
            final file = File(p.normalize(
                '$path/page-${i.toString().padLeft(3, DateTime.now().toIso8601String().replaceAll('-', '').replaceAll('.', '').replaceAll(':', ''))}.png'));
            await file.writeAsBytes(png);
            // log('Saved to ${file.absolute.path}');
            i++;
          }
        } else {
          // log('no permission granted');
        }
      }
    } else {
      // log("About sharing Pdf", name: "PDF Generation");
      await Printing.sharePdf(
        bytes: pdfData,
        filename:
            "${DateTime.now().toIso8601String().replaceAll('-', '').replaceAll('.', '').replaceAll(':', '')}.pdf",
        subject: "receipt",
        body: "Thank you for visiting us",
        emails: emails,
      );
    }
  }
}
