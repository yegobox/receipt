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
    // final middle = await _loadLogoImage(position: "middle");
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
                    pw.Image(left, width: 100, height: 100)
                  else
                    pw.SizedBox.shrink(),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('JEAN MARIE NTIGINAMA',
                          style: pw.TextStyle(
                              fontSize: 20, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Gasabo MUHIMA NYARUGENGE KIGALI CITY'),
                      pw.Text('TEL: 0788672640'),
                      pw.Text('EMAIL: ntiginamajm@gmail.com'),
                      pw.Text('TIN: 101412555'),
                    ],
                  ),
                  if (right != null)
                    pw.Image(right, width: 150, height: 150)
                  else
                    pw.SizedBox.shrink(),
                ],
              ),
              pw.SizedBox(height: 20),

              // Invoice Information
              pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('INVOICE TO'),
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.SizedBox(height: 5),
                              pw.Container(
                                decoration: pw.BoxDecoration(
                                  border: pw.Border.all(
                                    color: PdfColors.black,
                                    width: 0,
                                  ),
                                ),
                                child: pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: pw.Column(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text('TIN: $customerTin'),
                                      pw.SizedBox(height: 5),
                                      pw.Text('Name: $customerName'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // pw.SizedBox(width: 10),
                          pw.Divider(),
                          pw.Container(
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(
                                color: PdfColors.black,
                                width: 0,
                              ),
                            ),
                            child: pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text('INVOICE NO: $invoiceNum'),
                                  pw.SizedBox(height: 5),
                                  pw.Text('Date: $whenCreated'),
                                ],
                              ),
                            ),
                          ),
                        ])
                  ]),
              pw.SizedBox(height: 10),

              // Item Table Header
              pw.TableHelper.fromTextArray(
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
                      'D',
                      '${item.price}',
                      '${item.qty * item.price}'
                    ],
                ],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.normal),
                cellStyle: const pw.TextStyle(fontSize: 10),
                cellAlignment: pw.Alignment.center,
              ),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  // SDC Information
                  pw.Column(
                    children: [
                      pw.Text('SDC INFORMATION',
                          style: pw.TextStyle(
                              fontSize: 10, fontWeight: pw.FontWeight.normal)),
                      pw.Text('Date: $whenCreated',
                          style: pw.TextStyle(
                              fontSize: 10, fontWeight: pw.FontWeight.normal)),
                      pw.Text('SDC ID: $sdcId',
                          style: pw.TextStyle(
                              fontSize: 10, fontWeight: pw.FontWeight.normal)),
                      pw.Text(
                          'Receipt Number: $rcptNo/$totRcptNo ($receiptType)',
                          style: pw.TextStyle(
                              fontSize: 10, fontWeight: pw.FontWeight.normal)),
                      pw.Text(
                          'Internal Data: ${internalData.toDashedStringInternalData()}',
                          style: pw.TextStyle(
                              fontSize: 10, fontWeight: pw.FontWeight.normal)),
                      pw.Text(
                          'Receipt Signature: ${receiptSignature.toDashedStringRcptSign()}',
                          style: pw.TextStyle(
                              fontSize: 10, fontWeight: pw.FontWeight.normal)),
                    ],
                  ),

                  // Add space between columns
                  pw.SizedBox(
                      width: 20), // Adjust this width to control the gap

                  // QR Code
                  pw.Center(
                    child: pw.SizedBox(
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

                  // Add space between columns
                  pw.SizedBox(
                      width: 20), // Adjust this width to control the gap

                  // Summary Table
                  pw.Column(
                    children: [
                      pw.Table(
                        border: pw.TableBorder.all(width: 0.5),
                        children: [
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(0),
                                child: pw.Text('Description',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(0),
                                child: pw.Text('Amount',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold)),
                              ),
                            ],
                          ),
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(0),
                                child: pw.Text('Total Rwf:'),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(0),
                                child: pw.Text('$totalPayable'),
                              ),
                            ],
                          ),
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(0),
                                child: pw.Text('Total A-EX Rwf:'),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text('$totalTaxA'),
                              ),
                            ],
                          ),
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(0),
                                child: pw.Text('Total B-18% Rwf:'),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(0),
                                child: pw.Text('$totalTaxB'),
                              ),
                            ],
                          ),
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(0),
                                child: pw.Text('Total D:'),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(0),
                                child: pw.Text('$totalTaxD'),
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
                                padding: const pw.EdgeInsets.all(0),
                                child: pw.Text(totalTax),
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),

              // Receipt Summary
              // Receipt Summary using a table

              pw.SizedBox(height: 20),

              // Footer
              pw.Text('Powered by EBM v2',
                  style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
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
