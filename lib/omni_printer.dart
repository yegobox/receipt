import 'dart:io';
import 'package:flipper_models/realm_model_export.dart';
import 'package:flipper_models/view_models/mixins/riverpod_states.dart';
import 'package:flipper_services/proxy.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';

// import 'package:lecle_downloads_path_provider/lecle_downloads_path_provider.dart';
import 'package:flutter/material.dart' as c;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';
import 'package:receipt/printable.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;
import 'package:talker_flutter/talker_flutter.dart';

import 'package:sentry_flutter/sentry_flutter.dart';

final isDesktopOrWeb = UniversalPlatform.isDesktopOrWeb;

/// [generatePdfAndPrint] example
/// an extension on DateTime that return a string of date time separated by space

/// given a string E2P2VANEFD7PWY3COLUULSL3JU as a string, I want an extension that take
/// this string and apply dashed dashes come after 4 char

class OmniPrinter implements Printable {
  final doc = Document(version: PdfVersion.pdf_1_5, compress: true);
  List<Widget> rows = [];

  // Define a style for the receipt
  static final _receiptTextStyle =
      TextStyle(fontSize: 10, fontWeight: FontWeight.bold);

  _loadLogoImage({required String position}) async {
    ImageProvider? image;
    if (position == "left") {
      const imageLogo = c.AssetImage('assets/rra.jpg', package: 'receipt');
      image = await flutterImageProvider(imageLogo,
          configuration:
              const material.ImageConfiguration(size: Size(100, 100)));
      return image;
    } else {
      const imageLogo =
          c.AssetImage('assets/logo_right.png', package: 'receipt');
      image = await flutterImageProvider(imageLogo,
          configuration:
              const material.ImageConfiguration(size: Size(100, 100)));
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
    required String customerName,
    required String receiptNumber,
  }) async {
    List<Widget> receiptTypeWidgets(String receiptType) {
      switch (receiptType) {
        case "NR":
          return [
            Text('Refund',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('REF.NORMAL RECEIPT:# $receiptNumber',
                style: const TextStyle()),
            SizedBox(height: 4),
            Text('REFUND IS APPROVED FOR CLIENT ID:$customerTin',
                style: const TextStyle()),
          ];
        case "CS":
          return [
            Text('COPY',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('REF.NORMAL RECEIPT#:$receiptNumber',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('REFUND IS APPROVED FOR CLIENT ID:$customerTin',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ];
        case "TS":
          return [
            Text('TRAINING MODE',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))
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
      Text(brandName,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      SizedBox(height: 4),
      Text(brandAddress,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal)),
      SizedBox(height: 4),
      Text("Phone number: $brandTel",
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal)),
      SizedBox(height: 4),
      Text("TIN  : $brandTIN",
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal)),
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
                ..setColor(PdfColors.black)
                ..setLineWidth(1.0)
                ..strokePath();
              startX += dashWidth + dashSpace;
            }
          },
        )
      ]),
      SizedBox(height: 4),
      SizedBox(height: 4),
      if (receiptType != "NR")
        Text('Welcome to our shop',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
      if (receiptType != "NR")
        Text('Client ID: $customerTin',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      Text('Customer Tin: $customerTin',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      Text('Customer Name: $customerName',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      SizedBox(height: 8),
      ...receiptTypeWidgets(receiptType),
      SizedBox(height: 4),
    ]));
  }

  _buildTotalTax(
      {required String totalTax, required String receiptType}) async {
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
            style: _receiptTextStyle.copyWith(),
          ),
          Text(
            displayTotalTax,
            style: _receiptTextStyle.copyWith(),
          ),
        ],
      ),
    );
  }

  _buildTaxBB({required String totalTaxB, required String receiptType}) async {
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
              'TOTAL TAX B',
              style: _receiptTextStyle.copyWith(),
            ),
            Text(
              displayTotalTaxB,
              style: _receiptTextStyle.copyWith(),
            )
          ],
        ),
      );
    }
  }

  _buildTaxB({required String totalTaxB, required String receiptType}) async {
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
              'TOTAL B-18%',
              style: _receiptTextStyle.copyWith(),
            ),
            Text(
              displayTotalTaxB,
              style: _receiptTextStyle.copyWith(),
            )
          ],
        ),
      );
    }
  }

  _buildTaxC({required String totalTaxC, required String receiptType}) async {
    String displayTotalTaxC = totalTaxC;

    if (double.parse(displayTotalTaxC) != 0) {
      if (receiptType == "NR") {
        displayTotalTaxC = "-$totalTaxC";
      }

      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TOTAL C:',
              style: _receiptTextStyle.copyWith(),
            ),
            Text(
              displayTotalTaxC,
              style: _receiptTextStyle.copyWith(),
            )
          ],
        ),
      );
    }
  }

  _buildTaxD({required String totalTaxD, required String receiptType}) async {
    String displayTotalTaxD = totalTaxD;
    if (double.parse(displayTotalTaxD) != 0) {
      if (receiptType == "NR") {
        displayTotalTaxD = "-$totalTaxD";
      }

      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TOTAL D:',
              style: _receiptTextStyle.copyWith(),
            ),
            Text(
              displayTotalTaxD,
              style: _receiptTextStyle.copyWith(),
            )
          ],
        ),
      );
    }
  }

  _buildTotal(
      {required String totalPayable, required String receiptType}) async {
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
            style: _receiptTextStyle.copyWith(),
          ),
          Text(
            total,
            style: _receiptTextStyle.copyWith(),
          )
        ],
      ),
    );
  }

  _buildTaxA({required String totalAEx, required String receiptType}) async {
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
            style: _receiptTextStyle.copyWith(),
          ),
          Text(
            displayTotalAEx,
            style: _receiptTextStyle.copyWith(),
          )
        ],
      ),
    );
  }
//   TOTAL:                     410.0
// TOTAL A-EX                 400.0
// TOTAL B-18%               10.0
// TOTAL TAX-B                1.53
// TOTAL TAX              401.53

  _body({
    required List<TransactionItem> items,
    required String receiptType,
    required double taxA,
    required double taxB,
    required double taxC,
    required double taxD,
    required String totalPayable,
    required String totalTaxA,
    required String totalTaxB,
    required String totalTaxC,
    required String totalTaxD,
    required String totalTax,
    required double received,
    required String cashierName,
    required double cash,
  }) async {
    var bodyWidgets = <Widget>[];
    // Add the table headers
    List<List<String>> data = <List<String>>[];

    for (var item in items) {
      double total = item.price * item.qty;
      String taxLabel = item.taxTyCd != null ? "(${item.taxTyCd!})" : "(B)";

      // First row: Item name
      data.add(
        <String>[
          item.name!.length > 12 ? item.name!.substring(0, 12) : item.name!,
          '', // Empty spaces for the other columns
          '',
          '',
        ],
      );

      // Second row: Quantity x Price, total price with tax type
      data.add(
        <String>[
          '${item.qty.toStringAsFixed(1)}x', // Quantity with 1 decimal place
          item.price.toStringAsFixed(1), // Price with 1 decimal place
          '', // Empty space for alignment
          '${receiptType == "NR" ? '-' : ''}${total.toStringAsFixed(2)}$taxLabel', // Total price with tax label, // Total price with tax label
        ],
      );
    }

    // Add the table to bodyWidgets
    bodyWidgets.add(
      TableHelper.fromTextArray(
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
            style: _receiptTextStyle.copyWith(),
          ),
          SizedBox(height: 8),
        ],
      );
      rows.add(row);
    }

    await _buildTotal(totalPayable: totalPayable, receiptType: receiptType);
    await _buildTaxB(totalTaxB: totalTaxB, receiptType: receiptType);
    await _buildTaxA(totalAEx: taxA.toString(), receiptType: receiptType);

    await _buildTaxBB(totalTaxB: taxB.toString(), receiptType: receiptType);
    await _buildTaxC(totalTaxC: taxC.toString(), receiptType: receiptType);
    await _buildTaxD(totalTaxD: taxD.toString(), receiptType: receiptType);
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

    // Format for ITEMS NUMBER and CASH
    rows.add(
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('CASH:', style: _receiptTextStyle.copyWith()),
        Text(
            receiptType == "NR"
                ? "-${cash.toStringAsFixed(2)}"
                : cash.toStringAsFixed(2),
            style: _receiptTextStyle.copyWith()),
      ]),
    );

    rows.add(
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('ITEMS NUMBER:', style: _receiptTextStyle.copyWith()),
        Text(items.length.toString(), style: _receiptTextStyle.copyWith()),
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
            style: _receiptTextStyle.copyWith(),
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
            style: _receiptTextStyle.copyWith(),
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
    required String receiptType,
    required String receiptSignature,
    required String internalData,
    required String receiptQrCode,
    required String invoiceNum,
    required String mrc,
    required int rcptNo,
    required int totRcptNo,
  }) async {
    if (receiptType == "CS") {
      rows.add(
        Column(children: [
          Text(
            "COPY",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
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
          style: TextStyle(fontWeight: FontWeight.bold),
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
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ]),
    );
    rows.add(
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          'SDC ID:',
          style: const TextStyle(),
        ),
        Text(sdcId, style: TextStyle(fontWeight: FontWeight.bold)),
      ]),
    );
    rows.add(
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          'RECEIPT NUMBER:',
          style: const TextStyle(),
        ),
        Text(
          "$rcptNo  / $totRcptNo $receiptType",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ]),
    );
    rows.add(
      Column(children: [
        SizedBox(height: 12),
      ]),
    );
    rows.add(
      Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Text(
          "Internal Data",
        ),
        Text(
          internalData.toDashedString(),
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ]),
    );
    rows.add(
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          "Receipt Signature:",
        ),
        Text(
          receiptSignature.toDashedString(),
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ]),
    );

    rows.add(
      Column(children: [
        SizedBox(height: 1),
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
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          invoiceNum.toString(),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ]),
    );
    rows.add(
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          "DATE:${transaction.lastTouched?.formattedDate}",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          "TIME:${transaction.lastTouched?.formattedTime}",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ]),
    );
    rows.add(
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          'MRC',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          ProxyService.box.mrc() ?? mrc,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ]),
    );
    dashedLine();
    rows.add(
      Column(children: [
        SizedBox(height: 12),
        Text(
          'THANK YOU',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
        Text(
          'COME BACK AGAIN',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ]),
    );
    // rows.add(
    //   Column(children: [
    //     SizedBox(height: 12),
    //     Text(
    //       'EBM v2: v1.12',
    //       style: TextStyle(fontWeight: FontWeight.bold),
    //     ),
    //   ]),
    // );
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
    required double taxA,
    required double taxB,
    required double taxC,
    required double taxD,
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
    required Function(Uint8List bytes) printCallback,
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
        receiptNumber: rcptNo.toString(),
        customerName: customerName);
    dashedLine();
    await _body(
      items: items,
      totalTax: totalTax,
      taxB: taxB,
      taxA: taxA,
      taxC: taxC,
      taxD: taxD,
      totalTaxA: totalTaxA.toStringAsFixed(2),
      totalTaxB: totalTaxB.toStringAsFixed(2),
      totalTaxC: totalTaxC.toStringAsFixed(2),
      totalTaxD: totalTaxD.toStringAsFixed(2),
      cash: cash,
      cashierName: cashierName,
      received: received,
      // payMode: payMode,
      totalPayable: totalPayable.toStringAsFixed(2),
      receiptType: receiptType,
    );
    await _footer(
      transaction: transaction,
      sdcId: sdcId,
      receiptType: receiptType,
      receiptSignature: receiptSignature,
      internalData: internalData,
      receiptQrCode: receiptQrCode,
      invoiceNum: invoiceNum.toString(),
      rcptNo: rcptNo,
      totRcptNo: totRcptNo,
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
    handlePdfData(
      pdfData: pdfData,
      emails: emails,
      autoPrint: autoPrint,
    );
    return printCallback(pdfData);
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
                ..setColor(PdfColors.black)
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
  Future<void> printPdf(
    Uint8List pdfData,
  ) async {
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

  Future<void> sharePdf(
    Uint8List pdfData,
    List<String>? emails,
  ) async {
    try {
      // Fetch printer information
      String filePath = await savePdfToDocumentDirectory(pdfData);

      /// because we are testing with real customer
      /// we are taking a bet that if auto print does not work then we call
      ///  handlePrint(pdfData); to print manually
      /// but we are doing both now to see what is working or if it work both!

      final printingInfo = await Printing.info();
      const defaultPrinter = Printer(url: "", isAvailable: false);
      final talker = TalkerFlutter.init();
      talker.info(printingInfo);

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
          Sentry.captureMessage("PRINTER_AVAILABLE");
          // Print directly to the first available printer
          await Printing.directPrintPdf(
            printer: firstAvailablePrinter,
            format: PdfPageFormat.roll80,
            onLayout: (PdfPageFormat format) async => pdfData,
          );

          //  await Printing.pickPrinter(
          //   printer: firstAvailablePrinter,
          //   format: PdfPageFormat.roll80,
          //   onLayout: (PdfPageFormat format) async => pdfData,
          // );
        } else {
          // No available printer found, share the PDF via email
          if (Platform.isAndroid || Platform.isIOS) {
            await sharePdfViaEmail(pdfData, emails);
          } else {
            _openOrShareFile(filePath);
          }
        }
      } else {
        // Unable to list printers, share the PDF via email
        if (Platform.isAndroid || Platform.isIOS) {
          await sharePdfViaEmail(pdfData, emails);
        } else {
          _openOrShareFile(filePath);
        }
      }
      // return handlePrint(pdfData);
    } catch (e) {
      // In case of any errors, share the PDF via email
      // await sharePdfViaEmail(pdfData, emails);
      // return handlePrint(pdfData);
    }
  }

  Future<void> _openOrShareFile(String filePath) async {
    await OpenFilex.open(filePath);
  }

  Future<String> savePdfToDocumentDirectory(Uint8List pdfData) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = generateFileName();
    final filePath = '${directory.path}/$fileName.pdf';
    talker.warning("Files saved at: $filePath");

    final file = File(filePath);
    await file.writeAsBytes(pdfData);
    ProxyService.local.uploadPdfToS3(pdfData, fileName);

    return filePath;
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
    final now = DateTime.now();
    return '${now.year}${_pad(now.month)}${_pad(now.day)}_${_pad(now.hour)}${_pad(now.minute)}${_pad(now.second)}';
  }

  String _pad(int number) {
    return number.toString().padLeft(2, '0');
  }
}
