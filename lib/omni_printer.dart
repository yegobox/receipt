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
      displayTotalTax =
          "-${double.parse(totalTax.replaceAll(",", "")).toFormattedPercentage()}";
    } else {
      displayTotalTax =
          double.parse(totalTax.replaceAll(",", "")).toFormattedPercentage();
    }

    rows.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'TOTAL TAX:',
            style: _receiptTextStyle.copyWith(fontWeight: FontWeight.normal),
          ),
          Text(
            displayTotalTax.replaceAll("%", ""),
            style: _receiptTextStyle.copyWith(fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }

  _buildTotalTaxB(
      {required String totalTaxB, required String receiptType}) async {
    double value = double.parse(totalTaxB.replaceAll(',', ''));
    if (value != 0) {
      String displayTotalTaxB = totalTaxB;

      if (receiptType == "NR" || receiptType == "CR" || receiptType == "TR") {
        displayTotalTaxB = "-${value.toNoCurrencyFormatted()}";
      } else {
        displayTotalTaxB = "${value.toNoCurrencyFormatted()}";
      }

      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TOTAL TAX B',
              style: _receiptTextStyle.copyWith(fontWeight: FontWeight.normal),
            ),
            Text(
              displayTotalTaxB,
              style: _receiptTextStyle.copyWith(fontWeight: FontWeight.normal),
            )
          ],
        ),
      );
    }
  }

  _buildTaxB18({required String totalTaxB, required String receiptType}) async {
    double value = double.parse(totalTaxB.replaceAll(',', ''));
    if (value != 0) {
      String displayTotalTaxB = totalTaxB;

      if (receiptType == "NR" || receiptType == "CR" || receiptType == "TR") {
        displayTotalTaxB =
            "-${double.parse(totalTaxB.replaceAll(",", "")).toNoCurrencyFormatted()}";
      } else {
        displayTotalTaxB =
            double.parse(totalTaxB.replaceAll(",", "")).toNoCurrencyFormatted();
      }

      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TOTAL B-18%',
              style: _receiptTextStyle.copyWith(fontWeight: FontWeight.normal),
            ),
            Text(
              displayTotalTaxB,
              style: _receiptTextStyle.copyWith(fontWeight: FontWeight.normal),
            )
          ],
        ),
      );
    }
  }

  _buildTaxC({required String totalTaxC, required String receiptType}) async {
    String displayTotalTaxC = totalTaxC;

    double value = double.parse(totalTaxC.replaceAll(',', ''));
    if (value != 0) {
      if (receiptType == "NR" || receiptType == "CR" || receiptType == "TR") {
        displayTotalTaxC =
            "-${double.parse(totalTaxC.replaceAll(",", "")).toNoCurrencyFormatted()}";
      } else {
        displayTotalTaxC =
            double.parse(totalTaxC.replaceAll(",", "")).toNoCurrencyFormatted();
      }

      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TOTAL C:',
              style: _receiptTextStyle.copyWith(fontWeight: FontWeight.normal),
            ),
            Text(
              displayTotalTaxC,
              style: _receiptTextStyle.copyWith(fontWeight: FontWeight.normal),
            )
          ],
        ),
      );
    }
  }

  _buildTaxD({required String totalTaxD, required String receiptType}) async {
    String displayTotalTaxD = totalTaxD;
    double value = double.parse(displayTotalTaxD.replaceAll(',', ''));
    if (value != 0) {
      if (receiptType == "NR" || receiptType == "CR" || receiptType == "TR") {
        displayTotalTaxD =
            "-${double.parse(totalTaxD.replaceAll(",", "")).toNoCurrencyFormatted()}";
      } else {
        displayTotalTaxD =
            double.parse(totalTaxD.replaceAll(",", "")).toNoCurrencyFormatted();
      }

      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TOTAL D:',
              style: _receiptTextStyle.copyWith(fontWeight: FontWeight.normal),
            ),
            Text(
              displayTotalTaxD,
              style: _receiptTextStyle.copyWith(fontWeight: FontWeight.normal),
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
      total =
          "-${double.parse(totalPayable.replaceAll(",", "")).toFormattedPercentage()}";
    } else {
      total = double.parse(totalPayable.replaceAll(",", ""))
          .toFormattedPercentage();
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
            total.replaceAll("%", ""),
            style: _receiptTextStyle.copyWith(),
          )
        ],
      ),
    );
  }

  _buildTaxA({required String totalAEx, required String receiptType}) async {
    String displayTotalAEx = totalAEx;

    if (receiptType == "NR" || receiptType == "CR" || receiptType == "TR") {
      displayTotalAEx =
          "-${double.parse(totalAEx.replaceAll(",", "")).toNoCurrencyFormatted()}";
    } else {
      displayTotalAEx =
          double.parse(totalAEx.replaceAll(",", "")).toNoCurrencyFormatted();
    }

    rows.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'TOTAL A-EX:',
            style: _receiptTextStyle.copyWith(fontWeight: FontWeight.normal),
          ),
          Text(
            displayTotalAEx,
            style: _receiptTextStyle.copyWith(fontWeight: FontWeight.normal),
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

    // Define consistent styles
    const TextStyle smallTextStyle = TextStyle(fontSize: 10);
    final TextStyle boldStyle =
        TextStyle(fontSize: 10, fontWeight: FontWeight.bold);

    // Process items
    for (var item in items) {
      double total = item.price * item.qty;
      String taxLabel = item.taxTyCd != null ? "(${item.taxTyCd!})" : "(B)";
      String totalPrefix =
          receiptType == "NR" || receiptType == "CR" || receiptType == "TR"
              ? '-'
              : '';

      talker.warning("item.Price: ${item.price}");
      // Add vertical space before each new block, except the first one
      if (rows.isNotEmpty) {
        rows.add(SizedBox(height: 8)); // Add spacing
      }
      // Item row
      rows.add(
        Row(
          children: [
            Text(item.name ?? '', style: smallTextStyle), // Item name
          ],
        ),
      );

      // Add price, qty, and total on the second row
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${item.price.toStringAsFixed(2)}x ",
              style: smallTextStyle,
            ),
            Text(
              "  ${item.qty}  ",
              style: smallTextStyle,
            ),
            Text(
              '$totalPrefix${total.toNoCurrencyFormatted()}$taxLabel',
              style: smallTextStyle,
              textAlign: TextAlign.right,
            ),
          ],
        ),
      );

      // Discount row if applicable
      if (item.dcRt != 0) {
        double discountedAmount = total - ((total * item.dcRt) / 100);
        data.add([
          Expanded(
            flex: 4,
            child: Text(
              'Discount - ${item.dcRt} %',
              style: smallTextStyle,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text('', style: smallTextStyle),
          ),
          Expanded(
            flex: 1,
            child: Text('', style: smallTextStyle),
          ),
          Expanded(
            flex: 3,
            child: Text(
              discountedAmount.toStringAsFixed(2),
              style: smallTextStyle,
              textAlign: TextAlign.right,
            ),
          ),
        ]);
      }
    }

    // Add items table
    bodyWidgets.add(
      Table(
        border: null,
        columnWidths: {
          0: const FlexColumnWidth(6), // Item name
          1: const FlexColumnWidth(4), // Price
          2: const FlexColumnWidth(1), // Quantity
          3: const FlexColumnWidth(4), // Total
        },
        children: data.map((row) => TableRow(children: row)).toList(),
      ),
    );

    rows.add(Column(children: bodyWidgets));

    // Add spacing for non-CS receipts
    if (receiptType != "CS") {
      rows.add(Column(children: [SizedBox(height: 12)]));
    }

    dashedLine();

    // Special receipt header
    if (["TS", "PS", "CS", "CR", "TR"].contains(receiptType)) {
      rows.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 8),
            Text('THIS IS NOT AN OFFICIAL RECEIPT', style: _receiptTextStyle),
            dashWidget(),
            SizedBox(height: 8),
          ],
        ),
      );
    }

    // Calculate and build totals
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

    rows.add(Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [SizedBox(height: 1)],
    ));

    dashedLine();

    // Format cash and items number
    String formattedCash =
        receiptType == "NR" || receiptType == "CR" || receiptType == "TR"
            ? "-${cash.toNoCurrencyFormatted()}"
            : cash.toNoCurrencyFormatted();

    rows.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('CASH:',
              style: _receiptTextStyle.copyWith(fontWeight: FontWeight.normal)),
          Text(formattedCash,
              style: _receiptTextStyle.copyWith(fontWeight: FontWeight.normal)),
        ],
      ),
    );

    rows.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('ITEMS NUMBER:',
              style: _receiptTextStyle.copyWith(fontWeight: FontWeight.normal)),
          Text(items.length.toString(),
              style: _receiptTextStyle.copyWith(fontWeight: FontWeight.normal)),
        ],
      ),
    );

    // Handle copy receipts
    if (receiptType == "CS" || receiptType == "CR") {
      rows.add(dashWidget());
      rows.add(Text('COPY',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal)));
    }

    dashedLine();
    rows.add(Column(children: [SizedBox(height: 12)]));

    // Handle special receipt footers
    if (receiptType == "TS") {
      rows.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('TRAINING MODE', style: boldStyle),
            dashWidget(),
            SizedBox(height: 8),
          ],
        ),
      );
    }

    if (receiptType == "PS") {
      rows.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('PROFORMA', style: boldStyle),
            dashWidget(),
            SizedBox(height: 8),
          ],
        ),
      );
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
          style: TextStyle(fontWeight: FontWeight.normal),
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
            style: TextStyle(fontWeight: FontWeight.normal),
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
        Text(sdcId, style: TextStyle(fontWeight: FontWeight.normal)),
      ]),
    );
    rows.add(
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          'RECEIPT NUMBER:',
          style: TextStyle(fontWeight: FontWeight.normal),
        ),
        Text(
          "$rcptNo  / $totRcptNo $receiptType",
          style: TextStyle(fontWeight: FontWeight.normal),
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
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal),
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
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal),
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
          style: TextStyle(fontWeight: FontWeight.normal),
        ),
        Text(
          invoiceNum.toString(),
          style: TextStyle(fontWeight: FontWeight.normal),
        ),
      ]),
    );
    rows.add(
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          "DATE:${transaction.lastTouched?.formattedDate}",
          style: TextStyle(fontWeight: FontWeight.normal),
        ),
        Text(
          "TIME:${transaction.lastTouched?.formattedTime}",
          style: TextStyle(fontWeight: FontWeight.normal),
        ),
      ]),
    );
    rows.add(
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          'MRC',
          style: TextStyle(fontWeight: FontWeight.normal),
        ),
        Text(
          ProxyService.box.mrc() ?? mrc,
          style: TextStyle(fontWeight: FontWeight.normal),
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
      totalTaxA: totalTaxA.toNoCurrencyFormatted(),
      totalTaxB: totalTaxB.toNoCurrencyFormatted(),
      totalTaxC: totalTaxC.toNoCurrencyFormatted(),
      totalTaxD: totalTaxD.toNoCurrencyFormatted(),
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
