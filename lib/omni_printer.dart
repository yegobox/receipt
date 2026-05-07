import 'dart:async';
import 'dart:typed_data';

import 'package:flipper_models/helperModels/talker.dart';
import 'package:receipt/receipt_pdf_assets.dart';
import 'package:receipt/widgets/receipt_footer.dart';
import 'package:supabase_models/brick/models/all_models.dart';
import 'package:flipper_models/helperModels/extensions.dart';
import 'package:flipper_services/proxy.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';
import 'package:receipt/SaveFile.dart';
import 'package:receipt/printable.dart';
import 'package:universal_platform/universal_platform.dart';

import 'print_extensions.dart';

final isDesktopOrWeb = UniversalPlatform.isDesktopOrWeb;

/// [generatePdfAndPrint] example

class OmniPrinter with SaveFile implements Printable {
  final doc = Document(version: PdfVersion.pdf_1_5, compress: true);
  List<Widget> rows = [];

  // Define a style for the receipt
  static TextStyle _receiptTextStyle =
      TextStyle(fontSize: 10, fontWeight: FontWeight.bold);
  static Font? _unicodeFont;

  static Future<void> loadUnicodeFont() async {
    _unicodeFont ??= await ReceiptPdfAssets.unicodeFont();
    _receiptTextStyle = TextStyle(
        fontSize: 10, fontWeight: FontWeight.bold, font: _unicodeFont);
  }

  Future<ImageProvider?> _loadLogoImage({required String position}) async {
    return ReceiptPdfAssets.logo(position: position);
  }

  double safeParseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) {
      if (value.isNaN || value.isInfinite) return 0.0;
      return value;
    }
    if (value is int) return value.toDouble();
    if (value is String) {
      final cleaned = value.replaceAll(',', '').trim();
      final parsed = double.tryParse(cleaned);
      if (parsed == null || parsed.isNaN || parsed.isInfinite) return 0.0;
      return parsed;
    }
    return 0.0;
  }

  Future<void> _header({
    required ImageProvider leftImage,
    required ImageProvider rightImage,
    ImageProvider? middleImage,
    required String brandAddress,
    required String brandTel,
    required ITransaction transaction,
    required String brandTIN,
    required String brandName,
    String? customerTin,
    required String receiptType,
    required String customerName,
    String? customerPhone,
    required String receiptNumber,
    String? brandEmail,
    int? originalInvoiceNumber,
  }) async {
    List<Widget> receiptTypeWidgets(String receiptType) {
      switch (receiptType) {
        case "NR":
          return [
            Center(
              child: Text('Refund',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      font: _unicodeFont)),
            ),

            /// here we take the existing receipt number -1 to get the receipt number of the refund
            /// maybe in future we can have a better way to do this maybe saving them both in the same table or something
            Center(
              child: Text('REF.NORMAL RECEIPT:# $originalInvoiceNumber',
                  style: TextStyle(fontSize: 10, font: _unicodeFont)),
            ),
            dashWidget(),
            Center(
                child: Text(
              'REFUND IS APPROVED ONLY FOR ORIGINAL SALES RECEIPT',
              style: TextStyle(fontSize: 10, font: _unicodeFont),
            )),
            dashWidget(),
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("TIN: ${customerTin ?? ""}",
                          style: TextStyle(fontSize: 10, font: _unicodeFont))
                      .hideIf(customerTin == null),
                  Text("Name: $customerName",
                      style: TextStyle(fontSize: 10, font: _unicodeFont)),
                  Text("TEL: ${customerPhone?.normalizePhoneNumber() ?? ""}",
                          style: TextStyle(fontSize: 10, font: _unicodeFont))
                      .hideIf(customerPhone == null),
                ]),
            dashWidget(),
          ];
        case "TR":
          return [
            Center(
              child: Text('Refund',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      font: _unicodeFont)),
            ),
            dashWidget(),

            /// here we take the existing receipt number -1 to get the receipt number of the refund
            /// maybe in future we can have a better way to do this maybe saving them both in the same table or something
            Center(
              child: Text('REF.NORMAL RECEIPT:# $originalInvoiceNumber',
                  style: TextStyle(fontSize: 10, font: _unicodeFont)),
            ),
            dashWidget(),
            Center(
                child: Text(
              'REFUND IS APPROVED ONLY FOR ORIGINAL SALES RECEIPT',
              style: TextStyle(fontSize: 10, font: _unicodeFont),
            )),
            dashWidget(),
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("TIN: ${customerTin ?? ""}",
                          style: TextStyle(fontSize: 10, font: _unicodeFont))
                      .hideIf(customerTin == null),
                  Text("Name: $customerName",
                      style: TextStyle(fontSize: 10, font: _unicodeFont)),
                  Text("TEL: ${customerPhone?.normalizePhoneNumber() ?? ""}",
                          style: TextStyle(fontSize: 10, font: _unicodeFont))
                      .hideIf(customerPhone == null),
                ]),
            dashWidget(),
          ];
        case "CR":
          return [
            if (receiptType == "CR" || receiptType == "CS")
              Center(
                child: Text('COPY',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        font: _unicodeFont)),
              ),
            Center(
              child: Text('Refund',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      font: _unicodeFont)),
            ),
            dashWidget(),

            /// here we take the existing receipt number -1 to get the receipt number of the refund
            /// maybe in future we can have a better way to do this maybe saving them both in the same table or something
            Center(
              child: Text('REF.NORMAL RECEIPT:# $originalInvoiceNumber',
                  style: TextStyle(fontSize: 10, font: _unicodeFont)),
            ),
            dashWidget(),
            Center(
                child: Text(
              'REFUND IS APPROVED ONLY FOR ORIGINAL SALES RECEIPT',
              style: TextStyle(fontSize: 10, font: _unicodeFont),
            )),
            dashWidget(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("TIN: ${customerTin ?? ""}",
                        style: TextStyle(fontSize: 10, font: _unicodeFont))
                    .hideIf(customerTin == null),
                Text("Name: $customerName",
                    style: TextStyle(fontSize: 10, font: _unicodeFont)),
                Text("TEL: ${customerPhone?.normalizePhoneNumber() ?? ""}",
                        style: TextStyle(fontSize: 10, font: _unicodeFont))
                    .hideIf(customerPhone == null),
              ],
            ),
          ];
        case "CS":
          return [
            Center(
              child: Text('COPY',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      font: _unicodeFont)),
            ),
          ];

        default:
          return [];
      }
    }

    rows.add(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Image(leftImage, width: 25, height: 25),
            middleImage != null
                ? Image(middleImage, width: 25, height: 25)
                : Container(width: 25, height: 25),
            Image(rightImage, width: 25, height: 25),
          ]),
          SizedBox(height: 8),
          Text(brandName,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  font: _unicodeFont)),
          SizedBox(height: 4),
          Text(brandAddress,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.normal,
                  font: _unicodeFont)),
          Text("TEL: ${brandTel.normalizePhoneNumber()}",
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.normal,
                  font: _unicodeFont)),
          Text("EMAIL: ${brandEmail ?? " "}",
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.normal,
                  font: _unicodeFont)),
          Text("TIN: $brandTIN",
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.normal,
                  font: _unicodeFont)),
          SizedBox(height: 4),
          Center(
            child: Text(
              'Welcome to our shop'.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                font: _unicodeFont,
              ),
            ),
          ),
          dashWidget(),
          if (receiptType == "TS") SizedBox(height: 4),
          if (receiptType == "TS" || receiptType == "TR")
            Center(
              child: Text(
                "TRAINING MODE",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  font: _unicodeFont,
                ),
              ),
            ),
          if (receiptType == "TS") dashWidget(),
          if (receiptType == "PS") SizedBox(height: 4),
          if (receiptType == "PS")
            Center(
              child: Text(
                "PROFORMA",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  font: _unicodeFont,
                ),
              ),
            ),
          if (receiptType == "PS") dashWidget(),
          ...receiptTypeWidgets(receiptType),
          if (receiptType != "NR" && receiptType != "TR" && receiptType != "CR")
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TIN: ${customerTin ?? " "}',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            font: _unicodeFont))
                    .hideIf(customerTin == null),
                Text('Name: $customerName',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        font: _unicodeFont)),

                /// since we save phone number without the 0 then add it here
                Text('TEL: ${customerPhone?.normalizePhoneNumber() ?? " "}',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            font: _unicodeFont))
                    .hideIf(customerPhone == null),
              ],
            ),
          // Ensure there's a dashed separator between customer info and the items list
          if (receiptType != "NR" && receiptType != "TR") dashWidget(),
        ],
      ),
    );
  }

  _buildTotalTax(
      {required String totalTax,
      required String receiptType,
      required bool vatEnabled,
      required bool hasTTItem}) async {
    // Parse the tax value from the string
    double taxValue = safeParseDouble(totalTax);

    // Format with exactly 2 decimal places without rounding
    String formattedTax = taxValue.toStringAsFixed(2);

    // Add negative sign for returns and credits
    String displayTotalTax =
        (receiptType == "NR" || receiptType == "CR" || receiptType == "TR")
            ? "-$formattedTax"
            : formattedTax;
    if (!vatEnabled && hasTTItem) {
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TOTAL TT:',
              style: _receiptTextStyle.copyWith(fontWeight: FontWeight.normal),
            ),
            Text(
              displayTotalTax,
              style: _receiptTextStyle.copyWith(fontWeight: FontWeight.normal),
            ),
          ],
        ),
      );
    }

    if (vatEnabled || (!vatEnabled && !hasTTItem)) {
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TOTAL TAX:',
              style: _receiptTextStyle.copyWith(fontWeight: FontWeight.normal),
            ),
            Text(
              displayTotalTax,
              style: _receiptTextStyle.copyWith(fontWeight: FontWeight.normal),
            ),
          ],
        ),
      );
    }
  }

  _buildTotalTaxB(
      {required List<TransactionItem> items,
      required String receiptType}) async {
    double totalTaxB = items
        .where((item) => item.taxTyCd == "B")
        .fold<double>(0.0, (sum, item) {
      final itemTotal = safeParseDouble(item.price) * safeParseDouble(item.qty);
      final discounted = itemTotal * (1 - (safeParseDouble(item.dcRt) / 100));
      return sum + (discounted * 18 / 118);
    });

    if (totalTaxB != 0) {
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TOTAL TAX B:',
              style: _receiptTextStyle.copyWith(fontWeight: FontWeight.normal),
            ),
            Text(
              (receiptType == "NR" ||
                      receiptType == "CR" ||
                      receiptType == "TR")
                  ? "-${totalTaxB.toNoCurrencyFormatted()}"
                  : totalTaxB.toNoCurrencyFormatted(),
              style: _receiptTextStyle.copyWith(fontWeight: FontWeight.normal),
            )
          ],
        ),
      );
    }
  }

  // Compute TOTAL B-18% from items after applying per-item discounts.
  _buildTaxB18FromItems(
      {required List<TransactionItem> items,
      required String receiptType}) async {
    // Sum item totals for tax type B after per-item discount
    double totalB = items.where((item) => item.taxTyCd == "B").fold<double>(0.0,
        (sum, item) {
      final itemTotal = safeParseDouble(item.price) * safeParseDouble(item.qty);
      final discounted = itemTotal * (1 - (safeParseDouble(item.dcRt) / 100));
      return sum + discounted;
    });

    if (totalB == 0) return;

    final display =
        (receiptType == "NR" || receiptType == "CR" || receiptType == "TR")
            ? "-${totalB.toNoCurrencyFormatted()}"
            : totalB.toNoCurrencyFormatted();

    rows.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'TOTAL B-18%:',
            style: _receiptTextStyle.copyWith(fontWeight: FontWeight.normal),
          ),
          Text(
            display,
            style: _receiptTextStyle.copyWith(fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }

  // Display the total value of items with tax type C
  _buildTotalC(
      {required List<TransactionItem> items,
      required String receiptType}) async {
    // Only show if there are items with tax type C
    if (items.any((item) => item.taxTyCd == "C")) {
      // Calculate total for C items
      double totalCValue = items
          .where((item) => item.taxTyCd == "C")
          .fold<double>(0.0, (sum, item) => sum + (item.price * item.qty));

      String displayTotalC;
      if (receiptType == "NR" || receiptType == "CR" || receiptType == "TR") {
        displayTotalC = "-${totalCValue.toNoCurrencyFormatted()}";
      } else {
        displayTotalC = totalCValue.toNoCurrencyFormatted();
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
              displayTotalC,
              style: _receiptTextStyle.copyWith(fontWeight: FontWeight.normal),
            )
          ],
        ),
      );
    }
  }

  // Display the tax amount for tax type C (always 0.00)
  _buildTaxC(
      {required String totalTaxC,
      required String receiptType,
      List<TransactionItem>? items}) async {
    // Only show if all items in the receipt have tax type C and no other tax types
    if (items != null &&
        items.any((item) => item.taxTyCd == "C") &&
        items.every((item) => item.taxTyCd == "C" || item.taxTyCd == null)) {
      // Always display 0.00 for tax C amount
      String displayTotalTaxC =
          (receiptType == "NR" || receiptType == "CR" || receiptType == "TR")
              ? "-0.00"
              : "0.00";

      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TOTAL TAX:',
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

  _buildTaxD(
      {required List<TransactionItem> items,
      required String receiptType,
      required bool vatEnabled}) async {
    // Sum item totals for tax type D after per-item discount
    // When VAT is disabled, include TT items in TOTAL D
    double totalD = items
        .where((item) =>
            item.taxTyCd == "D" && (vatEnabled ? item.ttCatCd != 'TT' : true))
        .fold<double>(0.0, (sum, item) {
      final itemTotal = safeParseDouble(item.price) * safeParseDouble(item.qty);
      final discounted = itemTotal * (1 - (safeParseDouble(item.dcRt) / 100));
      return sum + discounted;
    });

    if (totalD == 0) return;

    final display =
        (receiptType == "NR" || receiptType == "CR" || receiptType == "TR")
            ? "-${totalD.toNoCurrencyFormatted()}"
            : totalD.toNoCurrencyFormatted();

    rows.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'TOTAL D:',
            style: _receiptTextStyle.copyWith(fontWeight: FontWeight.normal),
          ),
          Text(
            display,
            style: _receiptTextStyle.copyWith(fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }

  _buildTaxTT(
      {required String totalTaxTT,
      required String receiptType,
      List<TransactionItem>? items}) async {
    // Check if there are any TT items and calculate TT tax amount
    if (items != null && items.any((item) => item.ttCatCd == 'TT')) {
      double ttTaxAmount = 0.0;

      for (var item in items.where((item) => item.ttCatCd == 'TT')) {
        talker.debug("TOTAL OF TT BASE 1: ${{item.price * item.qty}}");
        talker.debug("TOTAL OF TT BASE 2: ${{1 - (item.dcRt ?? 0) / 100}}");
        double totalAfterDiscount =
            (item.price * item.qty) * (1 - (item.dcRt ?? 0) / 100);

        talker.debug("TOTAL OF TT BASE: $totalAfterDiscount");
        // Use configuration-based tax percentage calculation
        // Assuming TT tax percentage is 3% from configuration
        ttTaxAmount +=
            totalAfterDiscount * 3 / (100 + 3); // Using configuration formula
      }

      if (ttTaxAmount != 0) {
        String displayTotalTaxTT;
        if (receiptType == "NR" || receiptType == "CR" || receiptType == "TR") {
          displayTotalTaxTT = "-${ttTaxAmount.toNoCurrencyFormatted()}";
        } else {
          displayTotalTaxTT = ttTaxAmount.toNoCurrencyFormatted();
        }

        rows.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL TT:',
                style:
                    _receiptTextStyle.copyWith(fontWeight: FontWeight.normal),
              ),
              Text(
                displayTotalTaxTT,
                style:
                    _receiptTextStyle.copyWith(fontWeight: FontWeight.normal),
              )
            ],
          ),
        );
      }
    }
  }

  _buildTotal(
      {required String totalPayable, required String receiptType}) async {
    double total = safeParseDouble(totalPayable);

    if (receiptType == "NR" || receiptType == "CR" || receiptType == "TR") {
      total = -total;
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
            total.toNoCurrencyFormatted(),
            style: _receiptTextStyle.copyWith(),
          )
        ],
      ),
    );
  }

  _buildTaxA({required String totalAEx, required String receiptType}) async {
    // Skip adding the row if the value is zero
    double taxAValue = safeParseDouble(totalAEx);
    if (taxAValue == 0) {
      return; // Don't add anything to rows if there's no value
    }

    String displayTotalAEx;
    if (receiptType == "NR" || receiptType == "CR" || receiptType == "TR") {
      displayTotalAEx = "-${taxAValue.toNoCurrencyFormatted()}";
    } else {
      displayTotalAEx = taxAValue.toNoCurrencyFormatted();
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
    required double taxTT,
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
    required bool vatEnabled,
  }) async {
    var bodyWidgets = <Widget>[];
    List<List<Widget>> data = <List<Widget>>[];

    // Define consistent styles
    TextStyle smallTextStyle = TextStyle(fontSize: 10, font: _unicodeFont);
    final TextStyle boldStyle = TextStyle(
        fontSize: 10, fontWeight: FontWeight.bold, font: _unicodeFont);

    // Process items
    for (var item in items) {
      double total = safeParseDouble(item.price) * safeParseDouble(item.qty);
      // Construct tax label. For TT items: when VAT enabled we show primary as the actual tax type
      // and render a secondary (taxType&TT) total row. When not VAT, show (TT) on the
      // single line. For non-TT items keep their taxTyCd or default to (B).
      String taxLabel;
      if (item.ttCatCd == 'TT') {
        if (vatEnabled) {
          // Primary line should show actual tax type (TT will be shown on the secondary line)
          taxLabel = item.taxTyCd != null ? '(${item.taxTyCd!}&TT)' : '(B)';
        } else {
          // Not VAT: show TT on the single-line representation
          taxLabel = '(D&TT)';
        }
      } else {
        taxLabel = item.taxTyCd != null ? "(${item.taxTyCd!})" : "(B)";
      }
      String totalPrefix =
          receiptType == "NR" || receiptType == "CR" || receiptType == "TR"
              ? '-'
              : '';

      //talker.warning("item.Price: ${item.price}");
      // Add vertical space before each new block, except the first one
      if (rows.isNotEmpty) {
        rows.add(SizedBox(height: 8)); // Add spacing
      }
      // Item name row
      rows.add(
        Row(
          children: [
            Text(item.name, style: smallTextStyle), // Item name on its own line
          ],
        ),
      );

      // For TT items we have two different behaviors depending on VAT setting:
      // - VAT enabled: two lines (primary name with tax type, secondary shows base total with (taxType&TT))
      // - VAT disabled: single line with (TT) shown on the amount
      if (item.ttCatCd == 'TT' && ProxyService.box.vatEnabled()) {
        String baseTotal = total.toNoCurrencyFormatted();
        // Use the item's actual tax type instead of hardcoding "B"
        String itemTaxType = item.taxTyCd ?? "B";
        rows.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${safeParseDouble(item.price).toStringAsFixed(2)}x ",
              style: smallTextStyle,
            ),
            Text('  ${safeParseDouble(item.qty)}  ', style: smallTextStyle),
            Text(
              '$totalPrefix$baseTotal ($itemTaxType&TT)',
              style: smallTextStyle,
              textAlign: TextAlign.right,
            ),
          ],
        ));
      } else {
        // Default behavior: show unit price x qty and the total with tax label
        rows.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${safeParseDouble(item.price).toStringAsFixed(2)}x ",
                style: smallTextStyle,
              ),
              Text(
                "  ${safeParseDouble(item.qty)}  ",
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
      }

      // Discount row if applicable
      if (safeParseDouble(item.dcRt) != 0) {
        double discountedAmount =
            total - ((total * safeParseDouble(item.dcRt)) / 100);
        rows.add(Row(children: [
          Expanded(
            flex: 4,
            child: Text(
              'Discount - ${safeParseDouble(item.dcRt)} %',
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
        ]));
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
        safeParseDouble(totalPayable) - safeParseDouble(totalDiscount);

    await _buildTotal(
        totalPayable: totalWithDiscount.toString(), receiptType: receiptType);
    // Compute TOTAL B-18% from items after discounts so discounts are considered
    await _buildTaxB18FromItems(items: items, receiptType: receiptType);

    // Add TT VAT contribution to displayed totalTaxB
    // double displayedTotalTaxB = safeParseDouble(totalTaxB);
    // double displayedTotalTaxB = safeParseDouble(totalTaxB) + extraTtToTaxB;
    await _buildTotalTaxB(items: items, receiptType: receiptType);

    await _buildTaxA(
        totalAEx: safeParseDouble(taxA).toStringAsFixed(2),
        receiptType: receiptType);

    // Display total C (sum of items with tax type C)
    await _buildTotalC(items: items, receiptType: receiptType);

    // Display tax C amount (always 0.00)
    await _buildTaxC(
        totalTaxC: safeParseDouble(taxC).toStringAsFixed(2),
        receiptType: receiptType,
        items: items);
    await _buildTaxD(
        items: items, receiptType: receiptType, vatEnabled: vatEnabled);
    if (vatEnabled) {
      await _buildTaxTT(
          totalTaxTT: safeParseDouble(taxTT).toStringAsFixed(2),
          receiptType: receiptType,
          items: items);
    }
    // Only show TOTAL TAX: if not all items are tax type C (to avoid duplicate row)
    if (!(items.isNotEmpty &&
        items.every((item) => item.taxTyCd == "C" || item.taxTyCd == null))) {
      // Calculate actual total tax including TT tax
      // double actualTotalTax = safeParseDouble(totalTax);
      // Ensure TT tax is included in TOTAL TAX as well
      if (items.any((item) => item.ttCatCd == 'TT')) {
        double ttTaxAmount = 0.0;
        for (var item in items.where((item) => item.ttCatCd == 'TT')) {
          double totalAfterDiscount =
              (item.price * item.qty) * (1 - (item.dcRt ?? 0) / 100);

          ttTaxAmount += totalAfterDiscount * 3 / (100 + 3);
        }
        // Add TT tax since it's not included in the original totalTax parameter
        // actualTotalTax += ttTaxAmount;

        final total =
            ((double.tryParse(totalTax) ?? 0) + ttTaxAmount).toStringAsFixed(2);

        await _buildTotalTax(
            totalTax: total,
            receiptType: receiptType,
            vatEnabled: vatEnabled,
            hasTTItem: items.any((item) => item.ttCatCd == 'TT'));
      } else {
        await _buildTotalTax(
            totalTax: safeParseDouble(totalTax).toStringAsFixed(2),
            receiptType: receiptType,
            vatEnabled: vatEnabled,
            hasTTItem: items.any((item) => item.ttCatCd == 'TT'));
      }
    }

    rows.add(Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [SizedBox(height: 1)],
    ));

    dashedLine();

    // Format cash and items number
    String formattedCash =
        receiptType == "NR" || receiptType == "CR" || receiptType == "TR"
            ? "-${safeParseDouble(cash).toNoCurrencyFormatted()}"
            : safeParseDouble(cash).toNoCurrencyFormatted();

    rows.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("${_getPaymentType(ProxyService.box.pmtTyCd())}:",
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

    // Add dashed line below ITEMS NUMBER for CS receipts

    dashedLine();

    // Handle copy receipts
    if (receiptType == "CS" || receiptType == "CR") {
      rows.add(Text('COPY',
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              font: _unicodeFont)));
      rows.add(dashWidget());
    }

    rows.add(Column(children: [SizedBox(height: 12)]));

    // Handle special receipt footers
    if (receiptType == "TS" || receiptType == "TR") {
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

  String _getPaymentType(String paymentCode) {
    switch (paymentCode) {
      case '01':
        return 'CASH';
      case '02':
        return 'CREDIT CARD';
      case '03':
        return 'CASH/CREDIT CARD';
      case '04':
        return 'BANK CHECK';
      case '05':
        return 'DEBIT&CREDIT CARD';
      case '06':
        return 'MOBILE MONEY';
      case '07':
      default:
        return 'OTHER';
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
    required DateTime timeFromServer,
  }) async {
    rows.add(
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(height: 8),
        Text(
          "SDC INFORMATION",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.normal, font: _unicodeFont),
        ),
        SizedBox(height: 8),
      ]),
    );

    // Add dashed line below SDC INFORMATION for CS receipts

    dashedLine();

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
            "Date: ${timeFromServer.isoDateTime}",
            style: TextStyle(fontWeight: FontWeight.normal, font: _unicodeFont),
          ),
        ),
      ]),
    );
    rows.add(
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          'SDC ID:',
          style: TextStyle(font: _unicodeFont),
        ),
        Text(sdcId,
            style:
                TextStyle(fontWeight: FontWeight.normal, font: _unicodeFont)),
      ]),
    );
    rows.add(
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          'RECEIPT NUMBER:',
          style: TextStyle(fontWeight: FontWeight.normal, font: _unicodeFont),
        ),
        Text(
          "$rcptNo  / $totRcptNo $receiptType",
          style: TextStyle(fontWeight: FontWeight.normal, font: _unicodeFont),
        ),
      ]),
    );
    rows.add(
      Column(children: [
        SizedBox(height: 4),
      ]),
    );
    if (receiptType != "PS" && receiptType != "TS" && receiptType != "TR") {
      rows.add(
        Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Text(
            "Internal Data",
            style: TextStyle(font: _unicodeFont),
          ),
          Text(
            internalData.toDashedStringInternalData(),
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.normal,
                font: _unicodeFont),
          ),
        ]),
      );

      // Add dashed line below Internal Data for CS receipts
      // this was commented as requested during review that there is no dash-line bellow internal data
      // dashedLine();

      rows.add(
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            "Receipt Signature:",
            style: TextStyle(font: _unicodeFont),
          ),
          Text(
            receiptSignature.toDashedStringRcptSign(),
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.normal,
                font: _unicodeFont),
          ),
        ]),
      );
    }

    rows.add(
      Column(children: [
        SizedBox(height: 1),
      ]),
    );
    if (receiptType != "PS" &&
        receiptType != "TS" &&
        receiptType != "CR" &&
        receiptType != "TR") {
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
          style: TextStyle(fontWeight: FontWeight.normal, font: _unicodeFont),
        ),
        Text(
          invoiceNum.toString(),
          style: TextStyle(fontWeight: FontWeight.normal, font: _unicodeFont),
        ),
      ]),
    );
    rows.add(
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          "DATE:${transaction.lastTouched?.formattedDate}",
          style: TextStyle(fontWeight: FontWeight.normal, font: _unicodeFont),
        ),
        Text(
          "TIME:${whenCreated.formattedTime}",
          style: TextStyle(fontWeight: FontWeight.normal, font: _unicodeFont),
        ),
      ]),
    );
    rows.add(
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          'MRC:',
          style: TextStyle(fontWeight: FontWeight.normal, font: _unicodeFont),
        ),
        Text(
          (() {
            final boxMrc = ProxyService.box.mrc();
            if (boxMrc != null && boxMrc.isNotEmpty && boxMrc.length == 11) {
              return boxMrc;
            }
            return mrc;
          })(),
          style: TextStyle(fontWeight: FontWeight.normal, font: _unicodeFont),
        ),
      ]),
    );
    dashedLine();
    rows.add(
      ReceiptFooter(font: _unicodeFont),
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
    required double taxTT,
    String? customerPhone,
    int? originalInvoiceNumber,
    String brandName = "yegobox shop",
    String brandAddress = "",
    String brandTel = "271311123",
    String brandTIN = "1211287390",
    String brandDescription = "We build app that server you!",
    String brandFooter = "yegobox shop",
    List<String>? emails,
    String? customerTin,
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
    required double totalTaxTT,
    required String customerName,
    required int rcptNo,
    required int totRcptNo,
    required DateTime whenCreated,
    required Function(Uint8List bytes) printCallback,
    required String transactionId,
    required DateTime timeFromServer,
    String? brandEmail,
    required bool vatEnabled,
  }) async {
    await loadUnicodeFont();

    final logos = await Future.wait([
      _loadLogoImage(position: "left"),
      _loadLogoImage(position: "middle"),
      _loadLogoImage(position: "right"),
    ]);
    final left = logos[0];
    final middle = logos[1];
    final right = logos[2];
    await _header(
        transaction: transaction,
        middleImage: middle,
        originalInvoiceNumber: originalInvoiceNumber,
        leftImage: left!,
        rightImage: right!,
        brandEmail: brandEmail,
        brandAddress: brandAddress,
        brandTel: brandTel,
        brandTIN: brandTIN,
        customerPhone: customerPhone,
        brandName: brandName,
        customerTin: customerTin,
        receiptType: receiptType,
        receiptNumber: invoiceNum.toString(),
        customerName: customerName);
    // header already contains its own dash separators where appropriate.
    // avoid adding an extra dashed line here to prevent double separators
    // between customer info and item details.
    final cash = items
            .map((e) => safeParseDouble(e.price) * safeParseDouble(e.qty))
            .reduce((sum, value) => sum + value) -
        safeParseDouble(totalDiscount);
    await _body(
      vatEnabled: vatEnabled,
      items: items,
      totalTax: totalTax,
      totalDiscount: totalDiscount,
      taxB: taxB,
      taxA: taxA,
      taxC: taxC,
      taxD: taxD,
      taxTT: taxTT,
      totalTaxA: totalTaxA.toNoCurrencyFormatted(),
      totalTaxB: totalTaxB.toNoCurrencyFormatted(),
      totalTaxC: totalTaxC.toNoCurrencyFormatted(),
      totalTaxD: totalTaxD.toNoCurrencyFormatted(),
      cash: cash,
      cashierName: cashierName,
      received: received,
      // payMode: payMode,
      totalPayable: items
          .map((e) => safeParseDouble(e.price) * safeParseDouble(e.qty))
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
      timeFromServer: timeFromServer,
    );

    /// Add a page to the document
    /// we do not need multiPage in rolling paper mode.
    /// as in it it has a way to have infinite height
    doc.addPage(
      Page(
        pageFormat: PdfPageFormat.roll80,
        orientation: PageOrientation.portrait,
        build: (Context context) {
          return Column(
            children: rows,
          );
        },
      ),
    );

    // Convert the first page of the PDF to an image using the printing package
    Uint8List pdfData = await doc.save();
    Uint8List? image;

    final page = await Printing.raster(pdfData, pages: [0], dpi: 150).first;
    image = await page.toPng();

// Handle data (pass clones if needed)
    handlePdfData(
      pdfData: pdfData,
      image: image,
      emails: emails,
      autoPrint: autoPrint,
      transactionId: transactionId,
    );

// Free memory
    final result = printCallback(pdfData);
    pdfData = Uint8List(0); // Free original
    image = null;
    return result;
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
