import 'package:flipper_models/realm/schemas.dart';

import 'package:flutter/material.dart' as material;

abstract class Printable {
  Future<void> generatePdfAndPrint(
      {String brandName = "yegobox shop",
      String brandAddress = "CITY CENTER, Kigali Rwanda",
      String brandTel = "271311123",
      String brandTIN = "1211287390",
      String brandDescription = "We build app that server you!",
      String brandFooter = "yegobox shop",
      List<String>? emails,
      String? customerTin = "000000000",
      required List<TransactionItem> items,
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
      required ITransaction transaction,
      bool? autoPrint = false});
}
