library receipt;

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as c;
import 'package:pdf/widgets.dart';
import 'package:pdf/pdf.dart';

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
  final doc = Document();

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
  }) async {
    ImageProvider? image;
    if (!kIsWeb) {
      const imageLogo = c.AssetImage(
        'assets/rralogo.jpg',
      );
      image = await flutterImageProvider(imageLogo);
    }

    doc.addPage(
      MultiPage(
        pageFormat: PdfPageFormat.a4,
        orientation: PageOrientation.portrait,
        footer: (c) => Align(
            alignment: Alignment.centerRight,
            child: Text('Thank you for your visit!')),
        // child: Text('Page: ${c.pageNumber}/${c.pagesCount}')),
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
