library receipt;

import 'dart:developer';
import 'dart:io';
import 'package:flipper_models/isar_models.dart' as isar;
import 'package:lecle_downloads_path_provider/lecle_downloads_path_provider.dart';
import 'package:flutter/foundation.dart';
// import 'package:flipper_services/proxy.dart';
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
    final dashesInternalData = {2, 3, 4, 12, 6, 7};
    final replacedInternalData = splitMapJoin(RegExp('....'),
        onNonMatch: (s) => dashesInternalData.contains(x++) ? '-' : '');
    return replacedInternalData;
  }
}

class OmniPrinter {
  final doc = Document(version: PdfVersion.pdf_1_5, compress: true);

  List<Widget> rows = [];

  _loadLogoImage() async {
    ImageProvider? image;
    const imageLogo = c.AssetImage('assets/rra.jpg', package: 'receipt');
    image = await flutterImageProvider(imageLogo);
    return image;
  }

  Future<void> _header({
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

    List<Widget> receiptTypeWidgets(String receiptType) {
      switch (receiptType) {
        case "NR":
          return [
            Text('Refund', style: TextStyle(font: font, fontSize: 14)),
            Text('REF.NORMAL RECEIPT:# $sdcReceiptNum',
                style: TextStyle(font: font)),
            Text('REFUND IS APPROVED FOR CLIENT ID:$customerTin',
                style: TextStyle(font: font)),
          ];
        case "CS":
          return [
            Text('COPY', style: TextStyle(font: font, fontSize: 14)),
            SizedBox(height: 1),
            Text('REF.NORMAL RECEIPT#:$sdcReceiptNum',
                style: TextStyle(font: font, fontSize: 14)),
            SizedBox(height: 1),
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

    rows.add(Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      SizedBox(width: 12),
      Row(children: [
        Image(image, width: 25, height: 25),
        Spacer(),
        Image(image, width: 25, height: 25),
      ]),
      Align(alignment: Alignment.center, child: Text(brandAddress)),
      SizedBox(height: 1),
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Email: $brandTel", style: TextStyle(font: font, fontSize: 12)),
          Text("TIN  : $brandTIN", style: TextStyle(font: font, fontSize: 12))
        ],
      ),
      SizedBox(height: 1),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Welcome to $brandName',
            style: TextStyle(font: font, fontSize: 12)),
        Text('Client ID: $customerTin',
            style: TextStyle(font: font, fontSize: 12)),
      ]),
      ...receiptTypeWidgets(receiptType),
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

  _buildTotal({required String totalPayable}) async {
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
            totalPayable,
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
    required String totalPayable,
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
          item.name.length > 12 ? item.name.substring(0, 12) : item.name,
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
        Column(children: [SizedBox(height: 12)]),
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
    dashedLine();
    await _buildTotal(totalPayable: totalPayable);
    await _buildAEx(totalAEx: totalAEx);
    await _buildTaxB(totalTaxB: totalB18);
    await _buildTotalTax(totalTax: totalTax);

    rows.add(
      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        SizedBox(height: 1),
      ]),
    );

    dashedLine();
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
        SizedBox(height: 12),
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
    dashedLine();
    rows.add(
      Column(children: [
        SizedBox(height: 12),
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
        SizedBox(height: 12),
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
            width: 120,
            height: 120,
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
        SizedBox(height: 12),
        Text('Thank you!'),
      ]),
    );
    rows.add(
      Column(children: [
        SizedBox(height: 12),
        Text('EBM v2: v1.12'),
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
  Future<void> generatePdfAndPrint({
    String brandName = "yegobox shop",
    String brandAddress = "CITY CENTER, Kigali Rwanda",
    String brandTel = "271311123",
    String brandTIN = "1211287390",
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
    required double totalPayable,
    required isar.ITransaction transaction,
    bool? autoPrint = false,
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

    dashedLine();
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
      totalPayable: totalPayable.toString(),
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
      Directory? dir = await DownloadsPath.downloadsDirectory();
      final path = dir?.path;
      if (path != null) {
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
  ///
  Future<void> sharePdf(Uint8List pdfData, List<String>? emails) async {
    await Printing.sharePdf(
      bytes: pdfData,
      filename: "${generateFileName()}.pdf",
      subject: "receipt",
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
