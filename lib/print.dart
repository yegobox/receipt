library receipt;

import 'package:flipper_models/realm_model_export.dart';
import 'package:pdf/widgets.dart';
import 'package:receipt/omni_printer.dart';

class Print {
  ImageProvider? netImage;
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
  print(
      {required double grandTotal,
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
      required String receiptType,
      required List<TransactionItem> items,
      required ITransaction transaction,
      bool? autoPrint = false}) {
    receiptQr(receiptQrCode).then((qrCode) {
      OmniPrinter printer;
      printer = OmniPrinter();

      printer.generatePdfAndPrint(
        brandName: brandName,
        brandAddress: brandAddress,
        brandDescription: brandDescription,
        brandTel: brandTel,
        brandTIN: brandTIN,
        autoPrint: autoPrint,
        brandFooter: brandFooter,
        emails: emails,
        customerTin: customerTin.toString(),
        receiptType: receiptType,
        sdcReceiptNum: sdcReceiptNum,
        items: items,
        totalAEx: totalAEx,
        totalB18: totalB18,
        totalB: totalB,
        totalTax: totalTax,
        cash: cash,
        cashierName: cashierName,
        received: received,
        payMode: payMode,
        sdcId: sdcId,
        internalData: internalData,
        receiptSignature: receiptSignature,
        receiptQrCode: qrCode,
        invoiceNum: invoiceNum,
        mrc: mrc,
        totalPayable: transaction.subTotal,
        transaction: transaction,
      );
    });
  }
}
