import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:receipt/SaveFile.dart';
import 'package:receipt/printable.dart';
import 'package:flipper_models/realm_model_export.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart' as c;
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart';
import 'package:pdf/widgets.dart' as pw;

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
    final pdf = pw.Document();
    final left = await _loadLogoImage(position: "left");
    final middle = await _loadLogoImage(position: "middle");
    final right = await _loadLogoImage(position: "right");
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Section
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  if (left != null)
                    pw.Image(left, width: 40, height: 40)
                  else
                    // Ensures consistent space if image is absent
                    pw.SizedBox(width: 100),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      if (middle != null)
                        pw.Image(middle, width: 40, height: 40)
                      else
                        // Ensures consistent space if image is absent
                        pw.SizedBox(width: 100),
                      pw.Text(
                        brandName.substring(
                            0, brandName.length > 20 ? 20 : brandName.length),
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      // pw.Text(brandName),
                      pw.SizedBox(height: 2),
                      pw.Text('TEL: $brandTel'),
                      pw.SizedBox(height: 2),
                      // pw.Text('EMAIL: ntiginamajm@gmail.com'),
                      pw.SizedBox(height: 2),
                      pw.Text('TIN: $brandTIN'),
                    ],
                  ),
                  if (right != null)
                    pw.Image(right, width: 40, height: 40)
                  else
                    pw.SizedBox(width: 100), // Consistent space
                ],
              ),
              pw.SizedBox(height: 20),

              // Invoice Information
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('INVOICE TO',
                      style: pw.TextStyle(
                          fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Container(
                        // width: 250,
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                            color: PdfColors.black,
                            width: 0.5,
                          ),
                        ),
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('TIN: $customerTin'),
                              pw.SizedBox(height: 5),
                              pw.Text('Name: $customerName'),
                            ],
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 10),
                      pw.Container(
                        // width: 250,
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                            color: PdfColors.black,
                            width: 0.5,
                          ),
                        ),
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('INVOICE NO: $rcptNo'),
                              pw.SizedBox(height: 5),
                              pw.Text('Date: $whenCreated'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              pw.SizedBox(height: 15),

              // Item Table Header
              pw.Container(
                height: 200, // Minimum height for the table
                child: pw.TableHelper.fromTextArray(
                  headers: [
                    'Item Code',
                    'Description',
                    'Qty',
                    'Tax',
                    'Unit Price',
                    'Total Price'
                  ],
                  data: [
                    for (var item in items)
                      [
                        item.itemCd,
                        item.name,
                        '${item.qty}',
                        '${item.taxTyCd}',
                        ((item.price).toNoCurrencyFormatted()),
                        ((item.qty * item.price).toNoCurrencyFormatted())
                      ],
                  ],
                  headerStyle: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 10),
                  cellStyle: const pw.TextStyle(fontSize: 10),
                  cellAlignment: pw.Alignment.center,
                  columnWidths: {
                    0: const pw.FixedColumnWidth(60),
                    1: const pw.FlexColumnWidth(),
                    2: const pw.FixedColumnWidth(30),
                    3: const pw.FixedColumnWidth(30),
                    4: const pw.FixedColumnWidth(60),
                    5: const pw.FixedColumnWidth(60),
                  },
                  headerDecoration: const pw.BoxDecoration(
                    border: pw.Border(
                      top: pw.BorderSide(width: 0.5),
                      bottom: pw.BorderSide(width: 0.5),
                      left: pw.BorderSide(width: 0.5),
                      right: pw.BorderSide(width: 0.5),
                    ),
                  ),
                  // Apply bottom border to the last row only
                  rowDecoration: const pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide.none, // Border for the last row
                    ),
                  ),
                  border: const pw.TableBorder(
                    right: pw.BorderSide(width: 0.5),
                    left: pw.BorderSide(width: 0.5),
                    bottom: pw.BorderSide(width: 0.5),
                  ),
                ),
              ),

              pw.SizedBox(height: 20),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  // SDC Information
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('SDC INFORMATION',
                            style: pw.TextStyle(
                                fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        dashWidget(),
                        pw.SizedBox(height: 5),
                        pw.Text('Date: $whenCreated',
                            style: const pw.TextStyle(fontSize: 10)),
                        pw.Text('SDC ID: $sdcId',
                            style: const pw.TextStyle(fontSize: 10)),
                        pw.Text(
                          'Receipt Number: $rcptNo/$totRcptNo ($receiptType)',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                        if (receiptType != "PS" && receiptType != "TS")
                          pw.Text(
                            'Internal Data: ${internalData.toDashedStringInternalData()}',
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        if (receiptType != "PS" && receiptType != "TS")
                          pw.Text(
                            'Receipt Signature: ${receiptSignature.toDashedStringRcptSign()}',
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        dashWidget(),
                        pw.Text(
                          'Receipt Number: $rcptNo/$totRcptNo ($receiptType)',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                        pw.Text('Date: $whenCreated',
                            style: const pw.TextStyle(fontSize: 10)),
                        pw.Text('MRC: $mrc',
                            style: const pw.TextStyle(fontSize: 10)),
                        dashWidget(),
                      ],
                    ),
                  ),
                  if (receiptType != "PS" && receiptType != "TS")
                    pw.SizedBox(width: 20),
                  if (receiptType != "PS" && receiptType != "TS")
                    pw.Center(
                      child: pw.SizedBox(
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

                  pw.SizedBox(width: 20), // Space between columns

                  // Summary Table
                  pw.Expanded(
                    child: pw.Column(
                      children: [
                        pw.Table(
                          border: pw.TableBorder.all(width: 0.5),
                          children: [
                            pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(4),
                                  child: pw.Text('Description',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold)),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(4),
                                  child: pw.Text('Amount',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold)),
                                ),
                              ],
                            ),
                            pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(4),
                                  child: pw.Text('Total Rwf:'),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(4),
                                  child: pw.Text(
                                      totalPayable.toNoCurrencyFormatted()),
                                ),
                              ],
                            ),
                            if (totalTaxA != 0)
                              pw.TableRow(
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(4),
                                    child: pw.Text('Total A-EX Rwf:'),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(4),
                                    child: pw.Text(
                                        totalTaxA.toNoCurrencyFormatted()),
                                  ),
                                ],
                              ),
                            pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(4),
                                  child: pw.Text('Total B-18% Rwf:'),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(4),
                                  child: pw.Text(
                                      totalTaxB.toNoCurrencyFormatted()),
                                ),
                              ],
                            ),
                            if (totalTaxD != 0)
                              pw.TableRow(
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(4),
                                    child: pw.Text('Total D:'),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(4),
                                    child: pw.Text(
                                        totalTaxD.toNoCurrencyFormatted()),
                                  ),
                                ],
                              ),
                            pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(4),
                                  child: pw.Text('Total Tax Rwf:'),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(4),
                                  child: pw.Text(double.parse(totalTax)
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

              // Footer
              pw.Text('POWERED BY RRA VSDC EBM2.1',
                  style: pw.TextStyle(fontStyle: pw.FontStyle.normal)),
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
