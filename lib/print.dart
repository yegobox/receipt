library receipt;

import 'package:flipper_models/isar_models.dart';
import 'package:pdf/widgets.dart';
import 'package:receipt/omni_printer.dart';

class Print {
  DateTime dateTime = DateTime.now();
  String date = "";
  String time = "";
  double totalPrice = 0;
  double totalItems = 0;
  List<TableRow> rows = [];
  ImageProvider? netImage;
  Future<String> receiptQr(String url) async {
    return url;
  }

  Future<List<TableRow>> feed(
    List<OrderItem> items,
  ) async {
    date = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
    time = "${dateTime.hour}:${dateTime.minute}:${dateTime.second}";

    for (var item in items) {
      totalItems = totalItems + 1;
      double total = item.price * item.qty;
      totalPrice = total + totalPrice;
      String taxLabel = item.isTaxExempted ? "-EX" : "-B";
      rows.add(TableRow(children: [
        Text(item.name, style: TextStyle(fontWeight: FontWeight.bold)),
      ]));
      rows.add(TableRow(children: [
        Text((item.price).toString()),
        Text(item.qty.toString()),
        Text(
          "$total $taxLabel",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ]));
      rows.add(TableRow(children: [
        SizedBox(height: 1),
      ]));
    }
    return rows;
  }

  print({
    required double grandTotal,
    required String currencySymbol,
    required String totalTax,
    required double totalB,
    required String totalB18,
    required double totalAEx,
    required double cash,
    required double received,
    required String sdcId,
    required String sdcReceiptNum,
    required int invoiceNum,
    required String brandName,
    required String brandAddress,
    required String brandTel,
    required String brandTIN,
    required String brandDescription,
    required String brandFooter,
    required String cashierName,
    required String payMode,
    required String mrc,
    required String internalData,
    required String receiptSignature,
    required String receiptQrCode,
    required List<String> emails,
    required String? customerTin,
    //add receipt type to I can add more wording.
    required String invoiceType,
  }) {
    receiptQr(receiptQrCode).then((qrCode) {
      OmniPrinter printer;
      printer = OmniPrinter();
      printer.generateDoc(
        brandName: brandName,
        brandAddress: brandAddress,
        brandDescription: brandDescription,
        brandTel: brandTel,
        brandTIN: brandTIN,
        brandFooter: brandFooter,
        emails: emails,
        customerTin: customerTin.toString(),
        invoiceType: invoiceType,
        sdcReceiptNum: sdcReceiptNum,
        rows: [
          ...rows,
          if (invoiceType == "TS" || invoiceType == "PS")
            TableRow(children: [
              Text(
                'THIS IS NOT AN OFFICIAL RECEIPT',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(),
              Text(totalB18, style: TextStyle(fontWeight: FontWeight.bold))
            ]),
          TableRow(children: [
            Divider(height: 1),
            Divider(height: 1),
            Divider(height: 1)
          ]),
          TableRow(children: [
            SizedBox(height: 1),
          ]),
          TableRow(children: [
            Text(
              'TOTAL:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(),
            Text(totalPrice.toString(),
                style: TextStyle(fontWeight: FontWeight.bold))
          ]),
          TableRow(children: [
            Text(
              'TOTAL A-EX:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(),
            Text(totalAEx.toString(),
                style: TextStyle(fontWeight: FontWeight.bold))
          ]),
          TableRow(children: [
            Text(
              'TOTAL B-18%:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(),
            Text(totalB18, style: TextStyle(fontWeight: FontWeight.bold))
          ]),
          TableRow(children: [
            Text(
              'TOTAL TAX B:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(),
            Text(totalB.toString(),
                style: TextStyle(fontWeight: FontWeight.bold))
          ]),
          TableRow(children: [
            Text(
              'TOTAL TAX:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(),
            Text(totalTax, style: TextStyle(fontWeight: FontWeight.bold))
          ]),
          TableRow(children: [
            SizedBox(height: 1),
          ]),
          TableRow(children: [
            Divider(height: 1),
            Divider(height: 1),
            Divider(height: 1)
          ]),
          TableRow(children: [
            SizedBox(height: 1),
          ]),
          TableRow(children: [
            Text(
              'CASH:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(),
            Text(cash.toString(), style: TextStyle(fontWeight: FontWeight.bold))
          ]),
          TableRow(children: [
            Text(
              'ITEMS NUMBER:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(),
            Text(totalItems.toString(),
                style: TextStyle(fontWeight: FontWeight.bold))
          ]),
          TableRow(children: [
            Text(
              'Cashier Name:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(),
            Text(cashierName.toString(),
                style: TextStyle(fontWeight: FontWeight.bold))
          ]),
          TableRow(children: [
            Text(
              'RcvdAmt: $received',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(),
            Text("Change: ${cash - received}",
                style: TextStyle(fontWeight: FontWeight.bold))
          ]),
          TableRow(children: [
            SizedBox(height: 1),
          ]),
          TableRow(children: [
            Divider(height: 1),
            Divider(height: 1),
            Divider(height: 1)
          ]),
          TableRow(children: [
            SizedBox(height: 1),
          ]),
          TableRow(children: [
            Text('Pay Mode', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              payMode,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
          ]),
          TableRow(children: [
            SizedBox(height: 1),
          ]),
          TableRow(children: [
            SizedBox(height: 1),
          ]),
          TableRow(children: [
            Divider(height: 1),
            Divider(height: 1),
            Divider(height: 1)
          ]),
          TableRow(children: [
            SizedBox(height: 1),
          ]),
          if (invoiceType == "TS")
            TableRow(children: [
              Text(
                'TRAINING MODE',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(),
              Text(totalB18, style: TextStyle(fontWeight: FontWeight.bold))
            ]),
          if (invoiceType == "PS")
            TableRow(children: [
              Text(
                'PROFORMA',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(),
              Text(totalB18, style: TextStyle(fontWeight: FontWeight.bold))
            ]),
          TableRow(children: [
            SizedBox(),
            Text("SDC INFORMATION",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(),
          ]),
          TableRow(children: [
            SizedBox(height: 1),
          ]),
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
          TableRow(children: [
            Text(
              'SDC ID:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(),
            Text(sdcId, style: TextStyle(fontWeight: FontWeight.bold))
          ]),
          TableRow(children: [
            Text(
              'RECEIPT NUMBER:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(),
            Text(sdcReceiptNum, style: TextStyle(fontWeight: FontWeight.bold))
          ]),
          TableRow(children: [
            SizedBox(height: 1),
          ]),
          TableRow(children: [
            Divider(height: 1),
            Divider(height: 1),
            Divider(height: 1)
          ]),
          TableRow(children: [
            Text("Internal Data:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(internalData, style: TextStyle(fontWeight: FontWeight.normal)),
          ]),
          TableRow(children: [
            SizedBox(height: 1),
          ]),
          TableRow(children: [
            Text("Receipt Signature:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(receiptSignature,
                style: TextStyle(fontWeight: FontWeight.normal)),
          ]),
          TableRow(children: [
            SizedBox(height: 4),
          ]),
          TableRow(children: [
            SizedBox(),
            Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: BarcodeWidget(
                  barcode: Barcode.qrCode(
                    errorCorrectLevel: BarcodeQRCorrectionLevel.high,
                  ),
                  data: qrCode,
                ),
              ),
            ),
            SizedBox(),
          ]),
          TableRow(children: [
            SizedBox(height: 1),
          ]),
          TableRow(children: [
            Divider(height: 1),
            Divider(height: 1),
            Divider(height: 1)
          ]),
          TableRow(children: [
            SizedBox(height: 1),
          ]),
          TableRow(children: [
            Text(
              'INVOICE NUMBER:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(),
            Text(invoiceNum.toString(),
                style: TextStyle(fontWeight: FontWeight.bold))
          ]),
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
          TableRow(children: [
            Text(
              'MRC',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(),
            Text(mrc, style: TextStyle(fontWeight: FontWeight.bold))
          ]),
        ],
      );
    });
  }
}
