library;

import 'package:flipper_services/proxy.dart';
import 'package:flutter/foundation.dart' hide Category;

import 'package:supabase_models/brick/models/all_models.dart';
import 'package:receipt/OmniPrinterA4.dart';
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
    bool skipPresentation = false,
    required double totalTaxA,
    required double totalTaxB,
    required double totalTaxC,
    required double totalTaxD,
    required String customerName,
    required int rcptNo,
    required int totRcptNo,
    required DateTime whenCreated,
    required Function(Uint8List bytes) printCallback,
    required double totalDiscount,
    required DateTime timeFromServer,
    String? customerPhone,
    String? brandEmail,
    int? originalInvoiceNumber,
    required double taxTT,
    required double totalTaxTT,
    required bool vatEnabled,
  }) async {
    if (ProxyService.box.A4()) {
      final Printable printerA4 = OmniPrinterA4();
      return await printerA4.generatePdfAndPrint(
        vatEnabled: vatEnabled,
        taxB: taxB,
        originalInvoiceNumber: originalInvoiceNumber,
        customerTin: customerTin,
        timeFromServer: timeFromServer,
        totalTaxC: taxC,
        totalDiscount: totalDiscount,
        taxA: taxA,
        customerPhone: customerPhone,
        taxC: taxC,
        taxTT: taxTT,
        totalTaxTT: totalTaxTT,
        whenCreated: whenCreated,
        taxD: taxD,
        brandName: brandName,
        customerName: customerName,
        brandAddress: brandAddress,
        brandDescription: brandDescription,
        brandTel: brandTel,
        brandTIN: brandTIN,
        autoPrint: autoPrint,
        skipPresentation: skipPresentation,
        brandFooter: brandFooter,
        emails: emails,
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
        totalPayable: items
            .map((e) =>
                (double.tryParse(e.price.toString()) ?? 0.0) *
                (double.tryParse(e.qty.toString()) ?? 0.0))
            .fold(0.0, (sum, value) => sum + value),
        totalTaxA: totalTaxA,
        transaction: transaction,
        totalTaxB: totalTaxB,
        totalTaxD: totalTaxD,
        transactionId: transaction.id,
        brandEmail: brandEmail,
        printCallback: (Uint8List bytes) {
          printCallback(bytes);
        },
      );
    } else {
      final Printable printer = OmniPrinter();
      return await printer.generatePdfAndPrint(
        vatEnabled: vatEnabled,
        taxB: taxB,
        brandEmail: brandEmail,
        timeFromServer: timeFromServer,
        totalDiscount: totalDiscount,
        taxA: taxA,
        customerPhone: customerPhone,
        taxC: taxC,
        whenCreated: whenCreated,
        taxD: taxD,
        taxTT: taxTT,
        totalTaxTT: totalTaxTT,
        brandName: brandName,
        customerName: customerName,
        brandAddress: brandAddress,
        brandDescription: brandDescription,
        brandTel: brandTel,
        brandTIN: brandTIN,
        autoPrint: autoPrint,
        skipPresentation: skipPresentation,
        brandFooter: brandFooter,
        emails: emails,
        originalInvoiceNumber: originalInvoiceNumber,
        customerTin: customerTin,
        receiptType: receiptType,
        items: items,
        totalTax: totalTax,
        cash: cash,
        rcptNo: rcptNo,
        transactionId: transaction.id,
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
        totalPayable: items
            .map((e) =>
                (double.tryParse(e.price.toString()) ?? 0.0) *
                (double.tryParse(e.qty.toString()) ?? 0.0))
            .fold(0.0, (sum, value) => sum + value),
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
}
