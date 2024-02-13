library receipt;

import 'package:flipper_models/isar_models.dart';
import 'package:flipper_services/proxy.dart';
import 'package:pdf/widgets.dart';
import 'package:receipt/omni_printer.dart';

class Print {
  ImageProvider? netImage;
  Future<String> receiptQr(String url) async {
    return url;
  }

  /// interact with omni_printer pass data required to print a receipt
  /// this method is kinda a helpter class to avoid having too much code in omni_printer.dart
  /// the idea is also to be able to debug the receipt outside of the app
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
    required String receiptType,
    required List<TransactionItem> items,
    required ITransaction transaction,
  }) {
    receiptQr(receiptQrCode).then((qrCode) {
      OmniPrinter printer;
      printer = OmniPrinter();
      if (ProxyService.box.isAutoPrintEnabled()) {
        printer.generatePdfAndPrint(
            brandName: brandName,
            brandAddress: brandAddress,
            brandDescription: brandDescription,
            brandTel: brandTel,
            brandTIN: brandTIN,
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
            totalPrice: 0,
            transaction: transaction);
      } else {
        printer.generatePdfAndPrint(
            brandName: brandName,
            brandAddress: brandAddress,
            brandDescription: brandDescription,
            brandTel: brandTel,
            brandTIN: brandTIN,
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
            totalPrice: 0,
            transaction: transaction);
      }
    });
  }
}
