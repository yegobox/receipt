import 'package:flutter/foundation.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';
import 'package:flutter/material.dart' as c;

import 'omni_printer.dart';

class ZReport extends OmniPrinter {
  _loadLogoImage() async {
    ImageProvider? image;
    const imageLogo = c.AssetImage('assets/rra.jpg', package: 'receipt');
    image = await flutterImageProvider(imageLogo);
    return image;
  }

  Future<void> printZReport({
    int totalNumberSalesNS = 26,
    double totalAmountSalesNS = 191921000,
    int totalNumberCopySalesNS = 0,
    double totalAmountCopySalesNS = 0.0,
    int totalNumberRefundNR = 0,
    double totalAmountRefundNR = 0.00,
    double totalTaxableAEX = 0.0,
    double totalTaxableB = 191921000,
    double totalTaxableC = 0.00,
    double totalTaxableD = 0.00,
    double totalTaxeAEX = 0.00,
    double totalTaxeB = 29276084.75,
    double totalTaxeC = 0.00,
    double totalTaxeD = 0.00,
    double refundTaxableAEX = 0.00,
    double refundTaxableB = 0.00,
    double refundTaxableC = 0.00,
    double refundTaxableD = 0.00,
    double refundTaxeAEX = 0.00,
    double refundTaxeB = 0.00,
    double refundTaxeC = 0.00,
    double refundTaxeD = 0.00,
  }) async {
    final image = await _loadLogoImage();

    await _header(
      image: image,
      businessName: 'R.R.A. S.A.',
      email: '<EMAIL>',
      fromDate: DateTime.now().toString(),
      tinNumber: '000000000000000',
      toDate: DateTime.now().toString(),
    );
    _body(
      totalNumberSalesNS: totalNumberSalesNS,
      totalAmountSalesNS: totalAmountSalesNS,
      totalNumberCopySalesNS: totalNumberCopySalesNS,
      totalAmountCopySalesNS: totalAmountCopySalesNS,
      totalNumberRefundNR: totalNumberRefundNR,
      totalAmountRefundNR: totalAmountRefundNR,
      totalTaxableAEX: totalTaxableAEX,
      totalTaxableB: totalTaxableB,
      totalTaxableC: totalTaxableC,
      totalTaxableD: totalTaxableD,
      totalTaxeAEX: totalTaxeAEX,
      totalTaxeB: totalTaxeB,
      totalTaxeC: totalTaxeC,
      totalTaxeD: totalTaxeD,
      refundTaxableAEX: refundTaxableAEX,
      refundTaxableB: refundTaxableB,
      refundTaxableC: refundTaxableC,
      refundTaxableD: refundTaxableD,
      refundTaxeAEX: refundTaxeAEX,
      refundTaxeB: refundTaxeB,
      refundTaxeC: refundTaxeC,
      refundTaxeD: refundTaxeD,
    );
    // body now goes here

    doc.addPage(
      Page(
        pageFormat: PdfPageFormat.roll80,
        orientation: PageOrientation.portrait,
        build: (context) => Column(
          children: rows,
        ),
      ),
    );
    Uint8List pdfData = await doc.save();
    handlePdfData(
        pdfData: pdfData, emails: ['info@yegobox.com'], autoPrint: false);
  }

  void _body({
    int totalNumberSalesNS = 26,
    double totalAmountSalesNS = 191921000,
    int totalNumberCopySalesNS = 0,
    double totalAmountCopySalesNS = 0.0,
    int totalNumberRefundNR = 0,
    double totalAmountRefundNR = 0.00,
    double totalTaxableAEX = 0.0,
    double totalTaxableB = 191921000,
    double totalTaxableC = 0.00,
    double totalTaxableD = 0.00,
    double totalTaxeAEX = 0.00,
    double totalTaxeB = 29276084.75,
    double totalTaxeC = 0.00,
    double totalTaxeD = 0.00,
    double refundTaxableAEX = 0.00,
    double refundTaxableB = 0.00,
    double refundTaxableC = 0.00,
    double refundTaxableD = 0.00,
    double refundTaxeAEX = 0.00,
    double refundTaxeB = 0.00,
    double refundTaxeC = 0.00,
    double refundTaxeD = 0.00,
  }) {
    final normalSales = <Widget>[
      _buildAlign('TOTAL NUMBER SALES NS: $totalNumberSalesNS'),
      _buildAlign('TOTAL AMOUNT SALES NS: $totalAmountSalesNS'),
      _buildAlign('TOTAL NUMBER COPY SALES NS: $totalNumberCopySalesNS'),
      _buildAlign('TOTAL AMOUNT COPY SALES NS: $totalAmountCopySalesNS'),
    ];

    final refundSales = <Widget>[
      _buildAlign('TOTAL NUMBER REFUND NR: $totalNumberRefundNR'),
      _buildAlign('TOTAL AMOUNT REFUND NR: $totalAmountRefundNR'),
    ];

    final taxes = <Widget>[
      _buildAlign('TOTAL TAXABLE A-EX: $totalTaxableAEX'),
      _buildAlign('TOTAL TAXABLE B: $totalTaxableB'),
      _buildAlign('TOTAL TAXABLE C: $totalTaxableC'),
      _buildAlign('TOTAL TAXABLE D: $totalTaxableD'),
      _buildAlign('TOTAL TAXE A-EX: $totalTaxeAEX'),
      _buildAlign('TOTAL TAXE B: $totalTaxeB'),
      _buildAlign('TOTAL TAXE C: $totalTaxeC'),
      _buildAlign('TOTAL TAXE D: $totalTaxeD'),
    ];

    final refundTaxes = <Widget>[
      _buildAlign('TOTAL TAXABLE A-EX: $refundTaxableAEX'),
      _buildAlign('TOTAL TAXABLE B: $refundTaxableB'),
      _buildAlign('TOTAL TAXABLE C: $refundTaxableC'),
      _buildAlign('TOTAL TAXABLE D: $refundTaxableD'),
      _buildAlign('TOTAL TAXE A-EX: $refundTaxeAEX'),
      _buildAlign('TOTAL TAXE B: $refundTaxeB'),
      _buildAlign('TOTAL TAXE C: $refundTaxeC'),
      _buildAlign('TOTAL TAXE D: $refundTaxeD'),
    ];

    rows.add(
      Column(
        children: normalSales,
      ),
    );
    dashedLine(dashThickness: 1);
    rows.add(
      Column(
        children: refundSales,
      ),
    );
    dashedLine(dashThickness: 1);
    rows.add(
      Column(
        children: taxes,
      ),
    );
    dashedLine(dashThickness: 1);
    rows.add(
      Column(
        children: refundTaxes,
      ),
    );
  }

  Widget _buildAlign(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child:
          Text(text, style: TextStyle(fontSize: 5), textAlign: TextAlign.left),
    );
  }

  _header(
      {required image,
      required String businessName,
      required String tinNumber,
      required String email,
      required String fromDate,
      required String toDate}) {
    rows.add(Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      SizedBox(width: 5),
      Row(children: [
        Image(image, width: 25, height: 25),
      ]),
      SizedBox(height: 5),
      Row(children: [
        Text(businessName, textScaleFactor: 1, style: TextStyle(fontSize: 5)),
      ]),
      SizedBox(height: 5),
      Row(children: [
        Text('TIN: $tinNumber',
            textScaleFactor: 1, style: TextStyle(fontSize: 5)),
      ]),
      SizedBox(height: 5),
      Row(children: [
        Text('Email: $email',
            textScaleFactor: 1, style: TextStyle(fontSize: 5)),
      ]),
      SizedBox(height: 5),
      Row(children: [
        Text('Daily Z-Report',
            textScaleFactor: 1, style: TextStyle(fontSize: 5)),
      ]),
      SizedBox(height: 5),
      Row(children: [
        Text('From: $fromDate To: $toDate',
            textScaleFactor: 1, style: TextStyle(fontSize: 5)),
      ]),
      SizedBox(height: 5),
    ]));
  }
}
