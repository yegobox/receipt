import 'dart:io';
import 'package:flipper_models/realm_model_export.dart';
import 'package:flutter/services.dart';

// import 'package:lecle_downloads_path_provider/lecle_downloads_path_provider.dart';
import 'package:flutter/material.dart' as c;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';
import 'package:receipt/printable.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'package:sentry_flutter/sentry_flutter.dart';

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
    final dashesInternalData = {2, 3, 4, 12, 6, 7};
    final replacedInternalData = splitMapJoin(RegExp('....'),
        onNonMatch: (s) => dashesInternalData.contains(x++) ? '-' : '');
    return replacedInternalData;
  }
}

class OmniPrinter implements Printable {
  final doc = Document(version: PdfVersion.pdf_1_5, compress: true);
  List<Widget> rows = [];

  // Define a style for the receipt
  static const _receiptTextStyle = TextStyle(
    fontSize: 10,
  );

  _loadLogoImage({required String position}) async {
    ImageProvider? image;
    if (position == "left") {
      const imageLogo = c.AssetImage('assets/rra.jpg', package: 'receipt');
      image = await flutterImageProvider(imageLogo);
      return image;
    } else {
      const imageLogo =
          c.AssetImage('assets/logo_right.png', package: 'receipt');
      image = await flutterImageProvider(imageLogo);
      return image;
    }
  }

  Future<void> _header({
    required ImageProvider leftImage,
    required ImageProvider rightImage,
    required String brandAddress,
    required String brandTel,
    required String brandTIN,
    required String brandName,
    required String customerTin,
    required String receiptType,
    required String sdcReceiptNum,
    required String customerName,
  }) async {
    final font =
        Font.ttf(await rootBundle.load("google_fonts/Poppins-Thin.ttf"));
    List<Widget> receiptTypeWidgets(String receiptType) {
      switch (receiptType) {
        case "NR":
          return [
            Text('Refund', style: TextStyle(font: font, fontSize: 14)),
            SizedBox(height: 4),
            Text('REF.NORMAL RECEIPT:# $sdcReceiptNum',
                style: TextStyle(font: font)),
            SizedBox(height: 4),
            Text('REFUND IS APPROVED FOR CLIENT ID:$customerTin',
                style: TextStyle(font: font)),
          ];
        case "CS":
          return [
            Text('COPY', style: TextStyle(font: font, fontSize: 14)),
            SizedBox(height: 4),
            Text('REF.NORMAL RECEIPT#:$sdcReceiptNum',
                style: TextStyle(font: font, fontSize: 14)),
            SizedBox(height: 4),
            Text('REFUND IS APPROVED FOR CLIENT ID:$customerTin',
                style: TextStyle(font: font, fontSize: 12)),
          ];
        case "TS":
          return [
            Text('TRAINING MODE', style: TextStyle(font: font, fontSize: 14))
          ];
        default:
          return [];
      }
    }

    rows.add(Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      SizedBox(height: 12),
      Row(children: [
        Image(leftImage, width: 25, height: 25),
        Spacer(),
        Image(rightImage, width: 25, height: 25),
      ]),
      SizedBox(height: 8),
      Text(brandName, style: TextStyle(font: font, fontSize: 16)),
      SizedBox(height: 4),
      Text(brandAddress, style: TextStyle(font: font, fontSize: 10)),
      SizedBox(height: 4),
      Text("Phone number: $brandTel",
          style: TextStyle(font: font, fontSize: 10)),
      SizedBox(height: 4),
      Text("TIN  : $brandTIN", style: TextStyle(font: font, fontSize: 10)),
      SizedBox(height: 4),
      Column(children: [
        CustomPaint(
          size: const PdfPoint(double.infinity, 10),
          painter: (PdfGraphics canvas, PdfPoint size) {
            const double dashWidth = 2.0, dashSpace = 2.0;
            double startX = 0.0;
            while (startX < size.x) {
              canvas
                ..moveTo(startX, 0)
                ..lineTo(startX + dashWidth, 0)
                ..setColor(PdfColors.lightBlueAccent)
                ..setLineWidth(1.0)
                ..strokePath();
              startX += dashWidth + dashSpace;
            }
          },
        )
      ]),
      SizedBox(height: 4),
      SizedBox(height: 4),
      Text('Customer Tin: $customerTin',
          style: TextStyle(font: font, fontSize: 12)),
      Text('Customer Name: $customerName',
          style: TextStyle(font: font, fontSize: 12)),
      SizedBox(height: 8),
      ...receiptTypeWidgets(receiptType),
      SizedBox(height: 4),
    ]));
  }

  _buildTotalTax(
      {required String totalTax, required String receiptType}) async {
    final font =
        Font.ttf(await rootBundle.load("google_fonts/Poppins-Thin.ttf"));

    String displayTotalTax = totalTax;

    if (receiptType == "NR") {
      displayTotalTax = "-$totalTax";
    }

    rows.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'TOTAL TAX:',
            style: _receiptTextStyle.copyWith(font: font),
          ),
          Text(
            displayTotalTax,
            style: _receiptTextStyle.copyWith(font: font),
          ),
        ],
      ),
    );
  }

  _buildTaxB({required String totalTaxB, required String receiptType}) async {
    final font =
        Font.ttf(await rootBundle.load("google_fonts/Poppins-Thin.ttf"));

    if (double.parse(totalTaxB) != 0) {
      String displayTotalTaxB = totalTaxB;

      if (receiptType == "NR") {
        displayTotalTaxB = "-$totalTaxB";
      }

      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TOTAL B-18%:',
              style: _receiptTextStyle.copyWith(font: font),
            ),
            Text(
              displayTotalTaxB,
              style: _receiptTextStyle.copyWith(font: font),
            )
          ],
        ),
      );
    }
  }

  _buildTaxC({required String totalTaxC, required String receiptType}) async {
    final font =
        Font.ttf(await rootBundle.load("google_fonts/Poppins-Thin.ttf"));

    if (double.parse(totalTaxC) != 0) {
      String displayTotalTaxC = totalTaxC;

      if (receiptType == "NR") {
        displayTotalTaxC = "-$totalTaxC";
      }

      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TOTAL C:',
              style: _receiptTextStyle.copyWith(font: font),
            ),
            Text(
              displayTotalTaxC,
              style: _receiptTextStyle.copyWith(font: font),
            )
          ],
        ),
      );
    }
  }

  _buildTaxD({required String totalTaxD, required String receiptType}) async {
    final font =
        Font.ttf(await rootBundle.load("google_fonts/Poppins-Thin.ttf"));

    if (double.parse(totalTaxD) != 0) {
      String displayTotalTaxD = totalTaxD;

      if (receiptType == "NR") {
        displayTotalTaxD = "-$totalTaxD";
      }

      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TOTAL D:',
              style: _receiptTextStyle.copyWith(font: font),
            ),
            Text(
              displayTotalTaxD,
              style: _receiptTextStyle.copyWith(font: font),
            )
          ],
        ),
      );
    }
  }

  _buildTotal(
      {required String totalPayable, required String receiptType}) async {
    final font =
        Font.ttf(await rootBundle.load("google_fonts/Poppins-Thin.ttf"));

    String total = totalPayable;

    if (receiptType == "NR") {
      total = "-$totalPayable";
    }

    rows.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'TOTAL:',
            style: _receiptTextStyle.copyWith(font: font),
          ),
          Text(
            total,
            style: _receiptTextStyle.copyWith(font: font),
          )
        ],
      ),
    );
  }

  _buildTaxA({required String totalAEx, required String receiptType}) async {
    final font =
        Font.ttf(await rootBundle.load("google_fonts/Poppins-Thin.ttf"));

    if (double.parse(totalAEx) != 0) {
      String displayTotalAEx = totalAEx;

      if (receiptType == "NR") {
        displayTotalAEx = "-$totalAEx";
      }

      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TOTAL A-EX:',
              style: _receiptTextStyle.copyWith(font: font),
            ),
            Text(
              displayTotalAEx,
              style: _receiptTextStyle.copyWith(font: font),
            )
          ],
        ),
      );
    }
  }

  _body({
    required List<TransactionItem> items,
    required String receiptType,
    required String totalPayable,
    required String totalTaxA,
    required String totalTaxB,
    required String totalTaxC,
    required String totalTaxD,
    required String totalTax,
    required double received,
    required String cashierName,
    required double cash,
    required String payMode,
  }) async {
    final font =
        Font.ttf(await rootBundle.load("google_fonts/Poppins-Thin.ttf"));
    var bodyWidgets = <Widget>[];
    // Add the table headers
    List<List<String>> data = <List<String>>[];
    // Add the table headers
    data.add(<String>['Items', 'Price', 'Qty', 'Total']);
    // Iterate over the items
    for (var item in items) {
      double total = item.price * item.qty;
      // log(item.name, name: "in the loop");
      String taxLabel = item.taxTyCd != null ? "(${item.taxTyCd!})" : "(B)";
      // Add a row for each item
      data.add(
        <String>[
          item.name!.length > 12 ? item.name!.substring(0, 12) : item.name!,
          item.price.toString(),
          item.qty.toString(),
          '$total $taxLabel',
        ],
      );
    }
    // Add the table to bodyWidgets
    bodyWidgets.add(
      TableHelper.fromTextArray(
        cellStyle: _receiptTextStyle.copyWith(font: font),
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
        Column(children: [SizedBox(height: 12)]),
      );
    }
    dashedLine();
    if (receiptType == "TS" ||
        receiptType == "PS" ||
        receiptType == "NR" ||
        receiptType == "CS") {
      row = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 8),
          Text(
            'THIS IS NOT AN OFFICIAL RECEIPT',
            style: _receiptTextStyle.copyWith(font: font),
          ),
          SizedBox(height: 8),
        ],
      );
      rows.add(row);
    }

    await _buildTotal(totalPayable: totalPayable, receiptType: receiptType);
    await _buildTaxA(totalAEx: totalTaxA, receiptType: receiptType);
    await _buildTaxB(totalTaxB: totalTaxB, receiptType: receiptType);
    await _buildTaxC(totalTaxC: totalTaxC, receiptType: receiptType);
    await _buildTaxD(totalTaxD: totalTaxD, receiptType: receiptType);
    await _buildTotalTax(totalTax: totalTax, receiptType: receiptType);
    rows.add(
      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        SizedBox(height: 1),
      ]),
    );
    dashedLine();

    String total = received.toString();
    if (receiptType == "NR") {
      total = "-$total";
    }
    // rows.add(Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    //   Text(
    //     'CASH:',
    //     style: _receiptTextStyle.copyWith(font: font),
    //   ),
    //   Text(totalPayable.toString(),
    //       style: _receiptTextStyle.copyWith(font: font))
    // ]));
    rows.add(Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(
        'ITEMS NUMBER:',
        style: _receiptTextStyle.copyWith(font: font),
      ),
      Text(items.length.toString(),
          style: _receiptTextStyle.copyWith(font: font))
    ]));
    rows.add(Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(
        'Cashier Name:',
        style: _receiptTextStyle.copyWith(font: font),
      ),
      Text(cashierName.toString(),
          style: _receiptTextStyle.copyWith(font: font))
    ]));
    rows.add(
      Column(children: [
        SizedBox(height: 1),
      ]),
    );

    // Improve display of payment info
    rows.add(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Received Amount: $received',
                style: _receiptTextStyle.copyWith(font: font)),
            Text("Change: ${cash - received}",
                style: _receiptTextStyle.copyWith(font: font))
          ],
        ),
      ),
    );

    rows.add(
      Column(children: [
        SizedBox(height: 1),
      ]),
    );
    rows.add(
      Column(children: [
        SizedBox(height: 12),
      ]),
    );
    rows.add(
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Pay Mode:', style: _receiptTextStyle.copyWith(font: font)),
        Text(
          payMode,
          style: _receiptTextStyle.copyWith(font: font),
        ),
      ]),
    );
    dashedLine();
    rows.add(
      Column(children: [
        SizedBox(height: 12),
      ]),
    );
    if (receiptType == "TS") {
      row = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 8),
          Text(
            'TRAINING MODE',
            style: _receiptTextStyle.copyWith(font: font),
          ),
          SizedBox(height: 8),
        ],
      );
      rows.add(row);
    }
    if (receiptType == "PS") {
      row = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 8),
          Text(
            'PROFORMA',
            style: _receiptTextStyle.copyWith(font: font),
          ),
          SizedBox(height: 8),
        ],
      );
      rows.add(row);
    }
  }

  _footer({
    required ITransaction transaction,
    required String sdcId,
    required String sdcReceiptNum,
    required String receiptType,
    required String receiptSignature,
    required String internalData,
    required String receiptQrCode,
    required String invoiceNum,
    required String mrc,
  }) async {
    final font =
        Font.ttf(await rootBundle.load("google_fonts/Poppins-Thin.ttf"));
    if (receiptType == "CS") {
      rows.add(
        Column(children: [
          Text(
            "COPY",
            textAlign: TextAlign.center,
            style: TextStyle(
              font: font,
            ),
          ),
        ]),
      );
      dashedLine();
    }
    rows.add(
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(height: 8),
        Text(
          "SDC INFORMATION",
          textAlign: TextAlign.center,
          style: TextStyle(
            font: font,
          ),
        ),
        SizedBox(height: 8),
      ]),
    );
    rows.add(
      Column(children: [
        SizedBox(height: 1),
      ]),
    );
    rows.add(
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        SizedBox(
          width: 1120,
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
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          'SDC ID:',
          style: TextStyle(
            font: font,
          ),
        ),
        Text(sdcId,
            style: TextStyle(
              font: font,
            )),
      ]),
    );
    rows.add(
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          'RECEIPT NUMBER:',
          style: TextStyle(
            font: font,
          ),
        ),
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
        SizedBox(height: 12),
      ]),
    );
    rows.add(
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          "Receipt Signature:",
          style: TextStyle(font: font, fontBold: Font.courierBold()),
        ),
        Text(
          receiptSignature.toDashedString(),
          style: TextStyle(font: font, fontSize: 10),
        ),
      ]),
    );
    rows.add(
      Column(children: [
        SizedBox(height: 1),
      ]),
    );
    rows.add(
      Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Text(
          "Internal Data",
          style:
              TextStyle(font: font, fontSize: 10, fontBold: Font.courierBold()),
        ),
        Text(
          internalData.toDashedString(),
          style: TextStyle(font: font, fontSize: 10),
        ),
      ]),
    );
    rows.add(
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          internalData.toDashedString(),
          style: TextStyle(font: font, fontSize: 10),
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
            width: 40,
            height: 40,
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
    dashedLine();

    rows.add(
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          'RECEIPT NUMBER:',
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
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
    dashedLine();
    rows.add(
      Column(children: [
        SizedBox(height: 12),
        Text(
          'Thank you!',
          style: TextStyle(
            font: font,
            fontSize: 10,
          ),
        ),
      ]),
    );
    rows.add(
      Column(children: [
        SizedBox(height: 12),
        Text(
          'EBM v2: v1.12',
          style: TextStyle(
            font: font,
          ),
        ),
      ]),
    );
    // end of footer
  }

  /// Generates a PDF receipt and prints it.
  ///
  /// Parameters:
  /// - brandName: The brand name to display on the receipt.
  /// - brandAddress: The brand address to display on the receipt.
  /// - brandTel: The brand phone number to display on the receipt.
  /// - brandTIN: The brand tax ID to display on the receipt.
  /// - brandDescription: A description of the brand to display on the receipt.
  /// - brandFooter: The footer text to display on the receipt.
  /// - emails: Optional list of emails to send the PDF to.
  /// - customerTin: The customer's tax ID.
  /// - items: The list of transaction items to display on the receipt.
  /// - receiptType: The type of receipt.
  /// - sdcReceiptNum: The receipt number from SDC.
  /// - totalTax: The total tax amount.
  /// - totalB: The total before tax.
  /// - totalB18: The total before 18% tax.
  /// - totalAEx: The total after tax.
  /// - cash: The amount paid in cash.
  /// - cashierName: The name of the cashier.
  /// - received: The total amount received.
  /// - payMode: The payment mode.
  /// - sdcId: The SDC ID.
  /// - internalData: Internal data to display on the receipt.
  /// - receiptSignature: The signature to display on the receipt.
  /// - receiptQrCode: The QR code to display on the receipt.
  /// - invoiceNum: The invoice number.
  /// - mrc: The MRC number to display.
  /// - totalPrice: The total price.
  /// - transaction: The transaction details.
  /// - autoPrint: Whether to automatically print the receipt.
  ///
  /// Returns a Future that completes when the PDF is generated and handled.
  @override
  Future<void> generatePdfAndPrint({
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
    required String sdcReceiptNum,
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
  }) async {
    final left = await _loadLogoImage(position: "left");
    final right = await _loadLogoImage(position: "right");
    await _header(
        leftImage: left,
        rightImage: right,
        brandAddress: brandAddress,
        brandTel: brandTel,
        brandTIN: brandTIN,
        brandName: brandName,
        customerTin: customerTin!,
        receiptType: receiptType,
        sdcReceiptNum: sdcReceiptNum,
        customerName: customerName);
    dashedLine();
    await _body(
      items: items,
      totalTax: totalTax,
      totalTaxA: totalTaxA.toStringAsFixed(2),
      totalTaxB: totalTaxB.toStringAsFixed(2),
      totalTaxC: totalTaxC.toStringAsFixed(2),
      totalTaxD: totalTaxD.toStringAsFixed(2),
      cash: cash,
      cashierName: cashierName,
      received: received,
      payMode: payMode,
      totalPayable: totalPayable.toStringAsFixed(2),
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

    // Add a page to the document
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
    // FYI: https://stackoverflow.com/questions/68871880/do-not-use-buildcontexts-across-async-gaps
    handlePdfData(pdfData: pdfData, emails: emails, autoPrint: autoPrint);
  }

  /// Draws a dashed line separator on the PDF document.
  ///
  /// This function adds a Column with a CustomPaint widget to the rows list,
  /// which draws a dashed line 10 units high across the full width of the page.
  /// It is used to draw separator lines between sections of the receipt.
  void dashedLine({double dashThickness = 1.0}) {
    rows.add(
      Column(children: [
        CustomPaint(
          size: const PdfPoint(double.infinity, 10),
          painter: (PdfGraphics canvas, PdfPoint size) {
            const double dashWidth = 2.0, dashSpace = 2.0;
            double startX = 0.0;
            while (startX < size.x) {
              canvas
                ..moveTo(startX, 0)
                ..lineTo(startX + dashWidth, 0)
                ..setColor(PdfColors.lightBlueAccent)
                ..setLineWidth(dashThickness)
                ..strokePath();
              startX += dashWidth + dashSpace;
            }
          },
        )
      ]),
    );
  }

  /// Handles saving and printing/sharing the generated PDF data.
  ///
  /// If autoPrint is true, it will attempt to directly print the PDF
  /// on desktop/web, or save individual PNG pages on mobile.
  ///
  /// If autoPrint is false, it will instead share the PDF data as an
  /// attachment via the provided email addresses.
  ///
  /// The pdfData is the Uint8List containing the actual PDF data.
  /// emails is an optional list of email addresses to share to.
  /// autoPrint defaults to false if not provided.
  Future<void> handlePdfData({
    required Uint8List pdfData,
    required List<String>? emails,
    bool? autoPrint = false,
  }) async {
    if (autoPrint!) {
      if (isDesktopOrWeb) {
        await printPdf(pdfData);
      } else {
        await savePdfAsImage(pdfData);
      }
    } else {
      await sharePdf(pdfData, emails);
    }
  }

  /// Prints the provided PDF data by sending it to the system printing dialog.
  ///
  /// The `pdfData` parameter contains the raw bytes of the PDF file to print.
  ///
  /// The `name` parameter provides a suggested filename to use in the printing
  /// dialog.
  Future<void> printPdf(Uint8List pdfData) async {
    await Printing.layoutPdf(
      name: generateFileName(),
      onLayout: (PdfPageFormat format) async => pdfData,
    );
  }

  /// Saves the provided PDF data as a series of PNG image files,
  /// by rasterizing each page and writing to the downloads directory.
  ///
  /// The `pdfData` parameter contains the raw bytes of the PDF to save.
  ///
  /// This handles requesting permissions, finding the downloads directory,
  /// rasterizing each page, generating a filename, writing the PNG data,
  /// and incrementing the page count.
  Future<void> savePdfAsImage(Uint8List pdfData) async {
    Map<Permission, PermissionStatus> statuses =
        await [Permission.storage, Permission.manageExternalStorage].request();
    if (statuses[Permission.storage]?.isGranted ?? false) {
      Directory? dir = await getApplicationDocumentsDirectory();
      final path = dir.path;
      var i = 0;
      await for (final page in Printing.raster(pdfData, dpi: 1120)) {
        final png = await page.toPng();
        final file = File(p.normalize(
            '$path/page-${i.toString().padLeft(3, generateFileName())}.png'));
        await file.writeAsBytes(png);
        i++;
      }
    }
  }

  /// Shares the provided PDF data by opening the system share sheet.
  ///
  /// The `pdfData` parameter contains the raw bytes of the PDF to share.
  ///
  /// The `filename` parameter provides a suggested filename for the PDF.
  ///
  /// The `subject` and `body` parameters populate the share sheet with
  /// prefilled content.
  ///
  /// The `emails` parameter optionally specifies email addresses to prefill
  /// in the share sheet.

  Future<void> sharePdf(Uint8List pdfData, List<String>? emails) async {
    try {
      // Fetch printer information
      final printingInfo = await Printing.info();
      const defaultPrinter = Printer(url: "", isAvailable: false);
      final talker = TalkerFlutter.init();
      talker.info(printingInfo);
      Sentry.captureMessage("available printers listing");
      if (printingInfo.canListPrinters) {
        final printers = await Printing.listPrinters();

        // Pick the first available printer
        final firstAvailablePrinter = printers.firstWhere(
          (printer) => printer.isAvailable,
          orElse: () => defaultPrinter,
        );
        talker.info('first available printer');
        talker.info(firstAvailablePrinter);
        if (firstAvailablePrinter.isAvailable) {
          // Print directly to the first available printer
          await Printing.directPrintPdf(
            printer: firstAvailablePrinter,
            onLayout: (PdfPageFormat format) async => pdfData,
          );
        } else {
          // No available printer found, share the PDF via email
          await sharePdfViaEmail(pdfData, emails);
        }
      } else {
        // Unable to list printers, share the PDF via email
        await sharePdfViaEmail(pdfData, emails);
      }
    } catch (e) {
      // In case of any errors, share the PDF via email
      await sharePdfViaEmail(pdfData, emails);
    }
  }

  Future<void> sharePdfViaEmail(Uint8List pdfData, List<String>? emails) async {
    final fileName = generateFileName();
    await Printing.sharePdf(
      bytes: pdfData,
      filename: "$fileName.pdf",
      subject: "$fileName-receipt",
      body: "Thank you for visiting our shop",
      emails: emails,
    );
  }

  /// Generates a filename string based on the current date and time,
  /// with hypens, colons, and periods removed.
  ///
  /// This is useful for generating unique filenames for things like
  /// saved files, that include a timestamp.
  String generateFileName() {
    return DateTime.now()
        .toIso8601String()
        .replaceAll('-', '')
        .replaceAll('.', '')
        .replaceAll(':', '');
  }
}
