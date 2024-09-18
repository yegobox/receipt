library receipt;

import 'package:flutter/foundation.dart';

import 'package:flipper_models/realm_model_export.dart';
import 'package:receipt/omni_printer.dart';
import 'package:receipt/printable.dart';

class Print {
  Future<String> receiptQr(String url) async {
    return url;
  }

  /// Prints a receipt with the provided details.
  ///
  /// Parameters:
  /// - grandTotal: The grand total amount of the receipt.
  /// - currencySymbol: The currency symbol to use, e.g. '$'.
  /// - totalTax: The total tax amount.
  /// - totalB: The total for tax bracket B.
  /// - totalB18: The total for 18% tax items.
  /// - totalAEx: The total for exempt items.
  /// - cash: The cash amount paid.
  /// - received: The total amount received.
  /// - sdcId: The SDC ID.
  /// - sdcReceiptNum: The SDC receipt number.
  /// - invoiceNum: The invoice number.
  /// - brandName: The brand name.
  /// - brandAddress: The brand address.
  /// - brandTel: The brand phone number.
  /// - brandTin: The brand TIN.
  /// - brandDescription: The brand description.
  /// - brandFooter: The brand footer text.
  /// - cashierName: The cashier name.
  /// - payMode: The payment mode.
  /// - mrc: The MRC number.
  /// - internalData: Internal data to print.
  /// - receiptSignature: The receipt signature.
  /// - receiptQrCode: The QR code data.
  /// - emails: Email addresses to send receipt to.
  /// - customerTin: The customer TIN.
  /// - receiptType: The receipt type.
  /// - items: The list of transaction items.
  /// - transaction: The transaction object.
  /// - autoPrint: Whether to automatically print.
  Future<void> print({
    required double grandTotal,
    required String currencySymbol,
    required String totalTax,
    required double cash,
    required double received,
    required String sdcId,
    required int invoiceNum,
    required double taxA,
    required double taxB,
    required double taxC,
    required double taxD,
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
    required String receiptType,
    required List<TransactionItem> items,
    required ITransaction transaction,
    bool? autoPrint = false,
    required double totalTaxA,
    required double totalTaxB,
    required double totalTaxC,
    required double totalTaxD,
    required String customerName,
    required int rcptNo,
    required int totRcptNo,
    required Function(Uint8List bytes) printCallback,
  }) async {
    Printable printer = OmniPrinter();
    return await printer.generatePdfAndPrint(
      taxB: taxB,
      taxA: taxA,
      taxC: taxC,
      taxD: taxD,
      brandName: brandName,
      customerName: customerName,
      brandAddress: brandAddress,
      brandDescription: brandDescription,
      brandTel: brandTel,
      brandTIN: brandTIN,
      autoPrint: autoPrint,
      brandFooter: brandFooter,
      emails: emails,
      customerTin: customerTin.toString(),
      receiptType: receiptType,
      items: items,
      totalTax: totalTax,
      cash: cash,
      rcptNo: rcptNo,
      totRcptNo: totRcptNo,
      cashierName: cashierName,
      received: received,
      payMode: payMode,
      sdcId: sdcId,
      internalData: internalData,
      receiptSignature: receiptSignature,
      receiptQrCode: receiptQrCode,
      invoiceNum: invoiceNum,
      mrc: mrc,
      totalPayable: transaction.subTotal,
      totalTaxA: totalTaxA,
      transaction: transaction,
      totalTaxB: totalTaxB,
      totalTaxC: totalTaxC,
      totalTaxD: totalTaxD,
      printCallback: (Uint8List bytes) {
        printCallback(bytes);
      },
    );
  }
}
