import 'package:flipper_models/helperModels/talker.dart';
import 'package:flipper_models/realm_model_export.dart';
import 'package:flipper_services/proxy.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart' as c;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';
import 'package:receipt/SaveFile.dart';
import 'package:receipt/printable.dart';
import 'package:universal_platform/universal_platform.dart';

final isDesktopOrWeb = UniversalPlatform.isDesktopOrWeb;

/// [generatePdfAndPrint] example
/// an extension on DateTime that return a string of date time separated by space

/// given a string E2P2VANEFD7PWY3COLUULSL3JU as a string, I want an extension that take
/// this string and apply dashed dashes come after 4 char

class OmniPrinter with SaveFile implements Printable {
  final doc = Document(version: PdfVersion.pdf_1_5, compress: true);
  List<Widget> rows = [];

  // Define a style for the receipt
  static final _receiptTextStyle =
      TextStyle(fontSize: 10, fontWeight: FontWeight.bold);

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

  Future<void> _header({
    required ImageProvider leftImage,
    required ImageProvider rightImage,
    required ImageProvider middleImage,
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

            /// here we take the existing receipt number -1 to get the receipt number of the refund
            /// maybe in future we can have a better way to do this maybe saving them both in the same table or something
            Text('REF.NORMAL RECEIPT:# ${int.parse(receiptNumber) - 1}',
                style: const TextStyle()),
            dashWidget(),
            Text(
                'REFUND IS APPROVED ONLY FOR ORIGINAL SALES RECEIPT CLIENT ID:$customerTin',
                style: const TextStyle()),
          ];
        case "TR":
          return [
            Text('Refund',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),

            /// here we take the existing receipt number -1 to get the receipt number of the refund
            /// maybe in future we can have a better way to do this maybe saving them both in the same table or something
            Text('REF.NORMAL RECEIPT:# ${int.parse(receiptNumber) - 1}',
                style: const TextStyle()),
            dashWidget(),
            Text(
                'REFUND IS APPROVED ONLY FOR ORIGINAL SALES RECEIPT CLIENT ID:$customerTin',
                style: const TextStyle()),
          ];
        case "CR":
          return [
            if (receiptType == "CR" || receiptType == "CS")
              Text('COPY',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text('Refund',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            dashWidget(),

            /// here we take the existing receipt number -1 to get the receipt number of the refund
            /// maybe in future we can have a better way to do this maybe saving them both in the same table or something
            Text('REF.NORMAL RECEIPT:# ${int.parse(receiptNumber) - 1}',
                style: const TextStyle()),
            dashWidget(),
            Text(
                'REFUND IS APPROVED ONLY FOR ORIGINAL SALES RECEIPT CLIENT ID:$customerTin',
                style: const TextStyle()),
          ];
        case "CS":
          return [
            Text('COPY',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ];

        default:
          return [];
      }
    }

    rows.add(Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Image(leftImage, width: 25, height: 25),
        Image(middleImage, width: 25, height: 25),
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

      if (receiptType == "TS") SizedBox(height: 4),
      if (receiptType == "TS")
        Text("TRAINING MODE",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            )),
      if (receiptType == "PS") SizedBox(height: 4),
      if (receiptType == "PS")
        Text("PROFORMA",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            )),

      Column(children: [dashWidget()]),
      SizedBox(height: 4),
      if (receiptType != "NR")
        Text('Welcome to our shop',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
      ...receiptTypeWidgets(receiptType),

      if (receiptType != "NR")
        Text('Client ID: $customerTin',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      // Text('Customer Tin: $customerTin',
      //     style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      if (receiptType != "NR")
        Text('Customer Name: $customerName',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    ]));
  }

  _buildTotalTax(
      {required String totalTax, required String receiptType}) async {
    String displayTotalTax = totalTax;

    if (receiptType == "NR" || receiptType == "CR" || receiptType == "TR") {
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

  _buildTotalTaxB(
      {required String totalTaxB, required String receiptType}) async {
    if (double.parse(totalTaxB) != 0) {
      String displayTotalTaxB = totalTaxB;

      if (receiptType == "NR" || receiptType == "CR" || receiptType == "TR") {
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

  _buildTaxB18({required String totalTaxB, required String receiptType}) async {
    if (double.parse(totalTaxB) != 0) {
      String displayTotalTaxB = totalTaxB;

      if (receiptType == "NR" || receiptType == "CR" || receiptType == "TR") {
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
      if (receiptType == "NR" || receiptType == "CR" || receiptType == "TR") {
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
      if (receiptType == "NR" || receiptType == "CR" || receiptType == "TR") {
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

    if (receiptType == "NR" || receiptType == "CR" || receiptType == "TR") {
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

    if (receiptType == "NR" || receiptType == "CR" || receiptType == "TR") {
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
    required double totalDiscount,
  }) async {
    var bodyWidgets = <Widget>[];

    List<List<Widget>> data = <List<Widget>>[];
    const TextStyle smallTextStyle = TextStyle(fontSize: 10);
    for (var item in items) {
      double total = item.price * item.qty;
      String taxLabel = item.taxTyCd != null ? "(${item.taxTyCd!})" : "(B)";

      talker.warning("item.Price: ${item.price}");

      // First row: Item name, quantity, price, and total
      data.add(
        <Widget>[
          Text(
            item.name!.length > 12 ? item.name!.substring(0, 12) : item.name!,
            style: smallTextStyle,
          ),
          Text(
            '${item.qty.toStringAsFixed(0)}x',
            style: smallTextStyle,
          ),
          Text(
            item.price.toNoCurrency(),
            style: smallTextStyle,
          ),
          Text(
            '${receiptType == "NR" || receiptType == "CR" || receiptType == "TR" ? '-' : ''}${total.toNoCurrencyFormatted()}$taxLabel',
            style: smallTextStyle,
          ),
        ],
      );

      if (item.dcRt != 0) {
        data.add(
          <Widget>[
            Text(
              'Discount - ${item.dcRt} %',
              style: smallTextStyle,
            ),
            Text(
              '',
              style: smallTextStyle,
            ),
            Text(
              '',
              style: smallTextStyle,
            ),
            Text(
              (total - ((total * item.dcRt) / 100)).toStringAsFixed(2),
              style: smallTextStyle,
            ),
          ],
        );
      }
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

    // Rest of the code remains the same...
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
        receiptType == "CS" ||
        receiptType == "CR" ||
        receiptType == "TR") {
      row = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 8),
          Text(
            'THIS IS NOT AN OFFICIAL RECEIPT',
            style: _receiptTextStyle.copyWith(),
          ),
          // dashLine(),
          dashWidget(),
          SizedBox(height: 8),
        ],
      );
      rows.add(row);
    }
    final totalWithDiscount =
        (double.tryParse(totalPayable) ?? 0.0) - totalDiscount;
    await _buildTotal(
        totalPayable: totalWithDiscount.toString(), receiptType: receiptType);
    await _buildTaxB18(totalTaxB: totalTaxB, receiptType: receiptType);
    await _buildTaxA(
        totalAEx: taxA.toStringAsFixed(2), receiptType: receiptType);

    await _buildTotalTaxB(
        totalTaxB: taxB.toStringAsFixed(2), receiptType: receiptType);
    await _buildTaxC(
        totalTaxC: taxC.toStringAsFixed(2), receiptType: receiptType);
    await _buildTaxD(
        totalTaxD: taxD.toStringAsFixed(2), receiptType: receiptType);
    await _buildTotalTax(totalTax: totalTax, receiptType: receiptType);

    rows.add(
      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        SizedBox(height: 1),
      ]),
    );

    dashedLine();

    String total = received.toString();
    if (receiptType == "NR" || receiptType == "TR") {
      total = "-$total";
    }

    // Format for ITEMS NUMBER and CASH
    rows.add(
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('CASH:', style: _receiptTextStyle.copyWith()),
        Text(
            receiptType == "NR" || receiptType == "CR" || receiptType == "TR"
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
    if (receiptType == "CS" || receiptType == "CR") {
      rows.add(
        dashWidget(),
      );

      rows.add(Text('COPY',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)));
    }

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
          Text(
            'TRAINING MODE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          dashWidget(),
          SizedBox(height: 8),
        ],
      );
      rows.add(row);
    }

    if (receiptType == "PS") {
      row = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'PROFORMA',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          dashWidget(),
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
    required DateTime whenCreated,
  }) async {
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
            whenCreated.toDateTimeString(),
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
        SizedBox(height: 4),
      ]),
    );
    if (receiptType != "PS" && receiptType != "TS") {
      rows.add(
        Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Text(
            "Internal Data",
          ),
          Text(
            internalData.toDashedStringInternalData(),
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
            receiptSignature.toDashedStringRcptSign(),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ]),
      );
    }

    rows.add(
      Column(children: [
        SizedBox(height: 1),
      ]),
    );
    if (receiptType != "PS" && receiptType != "TS") {
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
    }
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
        Text(
          'POWERED BY RRA VSDC EBM2.1',
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
    required double totalDiscount,
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
    required DateTime whenCreated,
    required Function(Uint8List bytes) printCallback,
  }) async {
    talker.warning("ReceiptNo: $rcptNo: totRcptNo: $totRcptNo");
    final left = await _loadLogoImage(position: "left");
    final right = await _loadLogoImage(position: "right");
    final middle = await _loadLogoImage(position: "middle");
    await _header(
        middleImage: middle!,
        leftImage: left!,
        rightImage: right!,
        brandAddress: brandAddress,
        brandTel: brandTel,
        brandTIN: brandTIN,
        brandName: brandName,
        customerTin: customerTin!,
        receiptType: receiptType,
        receiptNumber: invoiceNum.toString(),
        customerName: customerName);
    dashedLine();
    final cash =
        items.map((e) => e.price * e.qty).reduce((sum, value) => sum + value) -
            totalDiscount;
    await _body(
      items: items,
      totalTax: totalTax,
      totalDiscount: totalDiscount,
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
      totalPayable: items
          .map((e) => e.price * e.qty)
          .reduce((sum, value) => sum + value)
          .toString(),
      receiptType: receiptType,
    );
    await _footer(
      transaction: transaction,
      sdcId: sdcId,
      receiptType: receiptType,
      receiptSignature: receiptSignature,
      internalData: internalData,
      whenCreated: whenCreated,
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
        dashWidget(),
      ]),
    );
  }
}
