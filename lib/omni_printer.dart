library receipt;

import 'dart:math';
import 'dart:typed_data';

import 'package:flipper_models/isar/order_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flipper_services/proxy.dart';
import 'package:flutter/material.dart' as c;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';

/// [generateDoc] example
/// generateDoc(
///   header: [
///     Text('K5 25 Ave', style: const TextStyle(fontSize: 5)),
///     Text('+250 788 888 888',
///         style: const TextStyle(fontSize: 5)),
///   ],
///   subHeader: [
///     Text('Cashier: John Doe',
///         style: const TextStyle(fontSize: 5)),
///     Container(width: 10),
///     Column(
///       children: [
///         Text('June 19,2021',
///             style: const TextStyle(fontSize: 5)),
///         Text('11:20 am', style: const TextStyle(fontSize: 5)),
///       ],
///     )
///   ],
///   body: Table(children: [
///     TableRow(children: [
///       Text('Qty', style: const TextStyle(fontSize: 5)),
///       Text('DESC', style: const TextStyle(fontSize: 5)),
///       Text('AMT', style: const TextStyle(fontSize: 5)),
///     ]),
///     TableRow(children: [
///       Text('1', style: const TextStyle(fontSize: 5)),
///       Text('Coffee', style: const TextStyle(fontSize: 5)),
///       Text('\$1.00', style: const TextStyle(fontSize: 5)),
///     ]),
///     TableRow(children: [
///       Text('1', style: const TextStyle(fontSize: 5)),
///       Text('Coffee', style: const TextStyle(fontSize: 5)),
///       Text('\$1.00', style: const TextStyle(fontSize: 5)),
///     ]),
///     TableRow(children: [
///       Text('1', style: const TextStyle(fontSize: 5)),
///       Text('Coffee', style: const TextStyle(fontSize: 5)),
///       Text('\$1.00', style: const TextStyle(fontSize: 5)),
///     ]),
///     /// show total
///     TableRow(children: [
///       Text(''),
///       Text('Total', style: const TextStyle(fontSize: 6)),
///       Text('\$3.00', style: const TextStyle(fontSize: 6)),
///     ]),
///   ]),
/// );
class OmniPrinter {
  final doc = Document(version: PdfVersion.pdf_1_5, compress: true);

  Future<bool> autoPrint() async {
    Printing.layoutPdf(
      format: PdfPageFormat.roll80,
      // format: PdfPageFormat.a4,
      onLayout: (PdfPageFormat format) async {
        return doc.save();
      },
      // this will use a default printer if it is set.
      usePrinterSettings: true,
    );
    return Future.value(false);
  }

  Future<void> generateDocv2({
    String brandName = "yegobox shop",
    String brandAddress = "CITY CENTER, Kigali Rwanda",
    String brandTel = "27131153",
    String brandTIN = "101587390",
    String brandDescription = "We build app that server you!",
    String brandFooter = "yegobox shop",
    List<String>? emails,
    String? customerTin = "000000000",
    required List<OrderItem> items,
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
    required String date,
    required String time,
    required String sdcId,
    required String internalData,
    required String receiptSignature,
    required String receiptQrCode,
    required int invoiceNum,
    required String mrc,
    required double totalPrice,
  }) async {
    ImageProvider? image;
    // https://github.com/flutter/flutter/issues/103803 web is broken.
    if (!kIsWeb) {
      const imageLogo = c.AssetImage(
        'assets/rralogo.jpg',
      );
      image = await flutterImageProvider(imageLogo);
    }
    final font = await PdfGoogleFonts.cairoRegular();

    List<TableRow> rows = [];
    rows.add(TableRow(
      children: [
        SizedBox(width: 10),
        Center(
            child: Column(children: [
          image != null ? Image(image) : Text(""),
          Text(
            brandName,
            style: TextStyle(
              font: Font.helvetica(),
              fontBold: Font.helveticaBold(),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 3),
          Text(
            brandAddress,
            style: TextStyle(
              font: Font.helvetica(),
              fontBold: Font.helveticaBold(),
              fontSize: 16,
            ),
          ),
          SizedBox(height: 3),
          Text(
            "Tel:$brandTel",
            style: TextStyle(
                font: Font.helvetica(),
                fontBold: Font.helveticaBold(),
                fontSize: 14),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'TIN:',
                style: TextStyle(
                  fontBold: Font.helveticaBold(),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              SizedBox(width: 100),
              Text(
                brandTIN,
                style: TextStyle(
                  fontBold: Font.helveticaBold(),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 1),
          Divider(height: 1),
          Divider(height: 1),
          Divider(height: 1),
          Text(
            'Welcome to $brandName',
            style: TextStyle(
              fontBold: Font.helveticaBold(),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            'Client ID: $customerTin',
            style: TextStyle(
              fontBold: Font.helveticaBold(),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Divider(height: 1),
          Divider(height: 1),
          Divider(height: 1),
          // add wording
          if (receiptType == "NR")
            Text(
              'Refund',
              style: TextStyle(
                fontBold: Font.helveticaBold(),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          if (receiptType == "NR") SizedBox(height: 3),
          if (receiptType == "NR")
            Text(
              'REF.NORMAL RECEIPT#:$sdcReceiptNum',
              style: TextStyle(
                fontBold: Font.helveticaBold(),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          if (receiptType == "NR") SizedBox(height: 3),
          if (receiptType == "NR")
            Text(
              'REFUND IS APPROVED ONLY FOR ORIGINAL SALES RECEIPT\n Client ID:$customerTin',
              style: TextStyle(
                fontBold: Font.helveticaBold(),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          if (receiptType == "CS")
            Text(
              'COPY',
              style: TextStyle(
                fontBold: Font.helveticaBold(),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          if (receiptType == "CS") SizedBox(height: 3),
          if (receiptType == "CS")
            Text(
              'REF.NORMAL RECEIPT#:$sdcReceiptNum',
              style: TextStyle(
                fontBold: Font.helveticaBold(),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          if (receiptType == "CS") SizedBox(height: 3),
          if (receiptType == "CS")
            Text(
              'REFUND IS APPROVED ONLY FOR ORIGINAL SALES RECEIPT\n Client ID:$customerTin',
              style: TextStyle(
                fontBold: Font.helveticaBold(),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          if (receiptType == "TS")
            Text(
              'TRAINING MODE',
              style: TextStyle(
                fontBold: Font.helveticaBold(),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
        ])),
      ],
    ));
    rows.add(
      TableRow(children: [
        Divider(height: 1),
        Divider(height: 1),
        Divider(height: 1)
      ]),
    );
    // end of heading
    for (OrderItem item in items) {
      double total = item.price * item.qty;

      String taxLabel = item.isTaxExempted ? "-EX" : "-B";
      rows.add(TableRow(children: [
        Text(item.name.length > 5 ? item.name.substring(0, 5) : item.name,
            style: TextStyle(fontWeight: FontWeight.bold)),
        Text("${item.price} X ${item.qty}"),
        Text(
          "$total $taxLabel",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ]));
    }

    TableRow row = const TableRow(
      children: [],
    );
    rows.add(
      TableRow(children: [
        Divider(height: 1),
        Divider(height: 1),
        Divider(height: 1)
      ]),
    );
    if (receiptType == "TS" || receiptType == "PS") {
      row = TableRow(children: [
        SizedBox(),
        Text(
          'THIS IS NOT AN OFFICIAL RECEIPT',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(),
      ]);
      rows.add(row);
    }

    rows.add(TableRow(children: [
      Text(
        'TOTAL:',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      SizedBox(),
      Text((receiptType == "NR") ? "-$totalPrice" : "$totalPrice",
          style: TextStyle(fontWeight: FontWeight.bold))
    ]));
    rows.add(TableRow(children: [
      Text(
        'TOTAL A-EX:',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      SizedBox(),
      Text((receiptType == "NR") ? "-$totalAEx" : totalAEx.toString(),
          style: TextStyle(fontWeight: FontWeight.bold))
    ]));
    rows.add(TableRow(children: [
      Text(
        'TOTAL B-18%:',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      SizedBox(),
      Text((receiptType == "NR") ? "-$totalB18" : totalB18,
          style: TextStyle(fontWeight: FontWeight.bold))
    ]));
    rows.add(
      TableRow(children: [
        Text(
          'TOTAL TAX B:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(),
        Text((receiptType == "NR") ? "-$totalB" : totalB.toString(),
            style: TextStyle(fontWeight: FontWeight.bold))
      ]),
    );
    rows.add(
      TableRow(children: [
        Text(
          'TOTAL TAX:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(),
        Text((receiptType == "NR") ? "-$totalTax" : totalTax,
            style: TextStyle(fontWeight: FontWeight.bold))
      ]),
    );
    rows.add(
      TableRow(children: [
        SizedBox(height: 1),
      ]),
    );

    rows.add(
      TableRow(children: [
        SizedBox(height: 1),
      ]),
    );
    rows.add(TableRow(children: [
      Text(
        'CASH:',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      SizedBox(),
      Text(cash.toString(), style: TextStyle(fontWeight: FontWeight.bold))
    ]));
    rows.add(TableRow(children: [
      Text(
        'ITEMS NUMBER:',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      SizedBox(),
      Text(items.length.toString(),
          style: TextStyle(fontWeight: FontWeight.bold))
    ]));
    rows.add(TableRow(children: [
      Text(
        'Cashier Name:',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      SizedBox(),
      Text(cashierName.toString(),
          style: TextStyle(fontWeight: FontWeight.bold))
    ]));
    rows.add(
      TableRow(children: [
        SizedBox(height: 1),
      ]),
    );
    rows.add(
      TableRow(children: [
        Text(
          'RcvdAmt: $received',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(),
        Text("Change: ${cash - received}",
            style: TextStyle(fontWeight: FontWeight.bold))
      ]),
    );
    rows.add(
      TableRow(children: [
        SizedBox(height: 1),
      ]),
    );
    rows.add(
      TableRow(children: [
        Divider(height: 1),
        Divider(height: 1),
        Divider(height: 1)
      ]),
    );
    rows.add(
      TableRow(children: [
        SizedBox(height: 1),
      ]),
    );
    rows.add(
      TableRow(children: [
        Text('Pay Mode', style: TextStyle(fontWeight: FontWeight.bold)),
        Text(
          payMode,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        // Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
      ]),
    );
    rows.add(
      TableRow(children: [
        SizedBox(height: 1),
        SizedBox(height: 1),
        Divider(height: 1),
        Divider(height: 1),
        Divider(height: 1)
      ]),
    );
    if (receiptType == "TS") {
      row = TableRow(children: [
        SizedBox(),
        Text(
          'TRAINING MODE',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(),
      ]);
      rows.add(row);
    }

    if (receiptType == "PS") {
      row = TableRow(children: [
        SizedBox(),
        Text(
          'PROFORMA',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(),
      ]);
      rows.add(row);
    }
    rows.add(
      TableRow(children: [
        SizedBox(),
        Text("SDC INFORMATION",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(),
      ]),
    );
    rows.add(
      TableRow(children: [
        SizedBox(height: 1),
      ]),
    );
    rows.add(
      TableRow(children: [
        SizedBox(
            width: 150,
            child: Text(
              'Date: $date',
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
        SizedBox(),
        SizedBox(
            width: 150,
            child: Text("Time: $time",
                style: TextStyle(fontWeight: FontWeight.bold)))
      ]),
    );
    rows.add(TableRow(children: [
      Text(
        'SDC ID:',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      SizedBox(),
      Text(sdcId, style: TextStyle(fontWeight: FontWeight.bold))
    ]));
    rows.add(
      TableRow(children: [
        Text(
          'RECEIPT NUMBER:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(),
        Text("$sdcReceiptNum $receiptType",
            style: TextStyle(fontWeight: FontWeight.bold))
      ]),
    );
    rows.add(
      TableRow(children: [
        SizedBox(height: 1),
        Divider(height: 1),
        Divider(height: 1),
        Divider(height: 1)
      ]),
    );
    rows.add(TableRow(children: [
      Text("Internal Data:", style: TextStyle(fontWeight: FontWeight.bold)),
      Text(internalData, style: TextStyle(fontWeight: FontWeight.normal)),
    ]));
    rows.add(
      TableRow(children: [
        SizedBox(height: 1),
      ]),
    );
    rows.add(
      TableRow(children: [
        Text("Receipt Signature:",
            style: TextStyle(fontWeight: FontWeight.bold)),
        Text(receiptSignature, style: TextStyle(fontWeight: FontWeight.normal)),
      ]),
    );
    rows.add(
      TableRow(children: [
        SizedBox(height: 4),
      ]),
    );
    rows.add(TableRow(children: [
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
    ]));
    rows.add(
      TableRow(children: [
        SizedBox(height: 4),
      ]),
    );
    rows.add(
      TableRow(children: [
        Text(
          'INVOICE NUMBER:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(),
        Text(invoiceNum.toString(),
            style: TextStyle(fontWeight: FontWeight.bold))
      ]),
    );
    rows.add(
      TableRow(children: [
        SizedBox(
            width: 150,
            child: Text(
              'DATE: $date',
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
        SizedBox(),
        SizedBox(
            width: 150,
            child: Text("TIME: $time",
                style: TextStyle(fontWeight: FontWeight.bold)))
      ]),
    );
    rows.add(TableRow(children: [
      Text(
        'MRC',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      SizedBox(),
      Text(mrc, style: TextStyle(fontWeight: FontWeight.bold))
    ]));
    // end of footer
    doc.addPage(
      MultiPage(
        maxPages: 100,
        pageFormat: PdfPageFormat.a4,
        orientation: PageOrientation.portrait,
        footer: (c) => Align(
            alignment: Alignment.centerRight,
            child: Column(children: [
              Text('Thank you'),
              Text('Come back again'),
              Text('EBM v2: v1.5', style: TextStyle(font: font))
            ])),
        build: (context) {
          return List<Widget>.generate(1, (index) {
            return Column(
              children: [
                Table(
                  children: rows,
                ),
              ],
            );
          });
        },
      ),
    );
    // experiment layout the pdf file
    Uint8List pdfData = await doc.save();

    if (ProxyService.box.isAutoPrintEnabled()) {
      await Printing.layoutPdf(
          name: 'receipt', onLayout: (PdfPageFormat format) async => pdfData);
      return;
    } else {
      // end of experiment
      await Printing.sharePdf(
        bytes: pdfData,
        filename: 'receipt.pdf',
        subject: "receipt",
        body: "Thank you for visiting us",
        emails: emails,
      );
    }
  }

  // Uint8List
  Future<void> generateDoc({
    String brandName = "yegobox shop",
    String brandAddress = "CITY CENTER, Kigali Rwanda",
    String brandTel = "27131153",
    String brandTIN = "101587390",
    String brandDescription = "We build app that server you!",
    String brandFooter = "yegobox shop",
    String? receiverPhone,
    List<String>? emails,
    String? customerTin = "000000000",
    required List<TableRow> rows,
    required String invoiceType,
    required String sdcReceiptNum,
  }) async {
    ImageProvider? image;
    if (!kIsWeb) {
      const imageLogo = c.AssetImage(
        'assets/rralogo.jpg',
      );
      image = await flutterImageProvider(imageLogo);
    }
    final font = await PdfGoogleFonts.cairoRegular();

    doc.addPage(
      MultiPage(
        maxPages: 100,
        pageFormat: PdfPageFormat.a4,
        orientation: PageOrientation.portrait,
        footer: (c) => Align(
            alignment: Alignment.centerRight,
            child: Center(
                child: Text('Thank you for your visit! EBM v2: v1.5',
                    style: TextStyle(font: font)))),
        build: (context) => [
          ...Iterable<Widget>.generate(1, (index) {
            final level = (sin(index / 5) * 6).abs().toInt();
            return Column(
              children: [
                Header(
                  child: Column(children: [
                    image != null ? Image(image) : Text(""),
                    Text(
                      brandName,
                      style: TextStyle(
                        font: Font.helvetica(),
                        fontBold: Font.helveticaBold(),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      brandAddress,
                      style: TextStyle(
                        font: Font.helvetica(),
                        fontBold: Font.helveticaBold(),
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      "Tel:$brandTel",
                      style: TextStyle(
                          font: Font.helvetica(),
                          fontBold: Font.helveticaBold(),
                          fontSize: 14),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'TIN:',
                          style: TextStyle(
                            fontBold: Font.helveticaBold(),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 100),
                        Text(
                          brandTIN,
                          style: TextStyle(
                            fontBold: Font.helveticaBold(),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1),
                    Text(
                      'Client ID: $customerTin',
                      style: TextStyle(
                        fontBold: Font.helveticaBold(),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    // add wording
                    if (invoiceType == "NR")
                      Text(
                        'Refund',
                        style: TextStyle(
                          fontBold: Font.helveticaBold(),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    if (invoiceType == "NR") SizedBox(height: 3),
                    if (invoiceType == "NR")
                      Text(
                        'REF.NORMAL RECEIPT#:$sdcReceiptNum',
                        style: TextStyle(
                          fontBold: Font.helveticaBold(),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    if (invoiceType == "NR") SizedBox(height: 3),
                    if (invoiceType == "NR")
                      Text(
                        'REFUND IS APPROVED ONLY FOR ORIGINAL SALES RECEIPT\n Client ID:$customerTin',
                        style: TextStyle(
                          fontBold: Font.helveticaBold(),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    if (invoiceType == "CS")
                      Text(
                        'COPY',
                        style: TextStyle(
                          fontBold: Font.helveticaBold(),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    if (invoiceType == "CS") SizedBox(height: 3),
                    if (invoiceType == "CS")
                      Text(
                        'REF.NORMAL RECEIPT#:$sdcReceiptNum',
                        style: TextStyle(
                          fontBold: Font.helveticaBold(),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    if (invoiceType == "CS") SizedBox(height: 3),
                    if (invoiceType == "CS")
                      Text(
                        'REFUND IS APPROVED ONLY FOR ORIGINAL SALES RECEIPT\n Client ID:$customerTin',
                        style: TextStyle(
                          fontBold: Font.helveticaBold(),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    if (invoiceType == "TS")
                      Text(
                        'TRAINING MODE',
                        style: TextStyle(
                          fontBold: Font.helveticaBold(),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                  ]),
                  level: level,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                  decoration: BoxDecoration(
                      color: PdfColor.fromHex('#FFF'),
                      borderRadius: BorderRadius.circular(0)),
                  child: Table(children: [
                    ...rows,
                  ]),
                ),
              ],
            );
          }),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'receipt.pdf',
      subject: "receipt",
      body: "Thank you for visiting us",
      emails: emails,
    );
  }
}
