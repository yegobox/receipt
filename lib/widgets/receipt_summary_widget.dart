import 'package:flipper_services/proxy.dart';
import 'package:pdf/widgets.dart';
import 'package:supabase_models/brick/models/all_models.dart';
import 'package:flipper_models/helperModels/extensions.dart';
import 'package:pdf/widgets.dart' as pw;

class ReceiptSummaryWidget extends StatelessWidget {
  final String receiptType;
  final String receiptQrCode;
  final List<TransactionItem> items;
  final double totalPayable;
  final double totalDiscount;
  final double totalTax;
  final double totalTaxB;
  final double totalTaxD;
  final Font? unicodeFont;
  final DateTime timeFromServer;
  final String sdcId;
  final String internalData;
  final String receiptSignature;
  final int rcptNo;
  final int totRcptNo;
  final int invoiceNum;
  final DateTime whenCreated;
  final String mrc;
  final ITransaction transaction;

  ReceiptSummaryWidget({
    required this.receiptType,
    required this.receiptQrCode,
    required this.items,
    required this.totalPayable,
    required this.totalDiscount,
    required this.totalTax,
    required this.totalTaxB,
    required this.totalTaxD,
    this.unicodeFont,
    required this.timeFromServer,
    required this.sdcId,
    required this.internalData,
    required this.receiptSignature,
    required this.rcptNo,
    required this.totRcptNo,
    required this.invoiceNum,
    required this.whenCreated,
    required this.mrc,
    required this.transaction,
  });

  @override
  Widget build(pw.Context context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildSdcInfoSection(),
        if (receiptType != "PS" && receiptType != "TS" && receiptType != "CR")
          SizedBox(width: 20),
        if (receiptType != "PS" &&
            receiptType != "TS" &&
            receiptType != "TR" &&
            receiptType != "CR")
          _buildQrCodeSection(),
        SizedBox(width: 20),
        _buildSummaryTable(),
      ],
    );
  }

  Widget _buildSdcInfoSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SDC INFORMATION',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              font: unicodeFont,
            ),
          ),
          _dashWidget(),
          SizedBox(height: 5),
          Text(
            'Date: ${timeFromServer.isoDateTime}',
            style: TextStyle(fontSize: 10, font: unicodeFont),
          ),
          Text(
            'SDC ID: $sdcId',
            style: TextStyle(fontSize: 10, font: unicodeFont),
          ),
          Text(
            'Receipt Number: $rcptNo/$totRcptNo $receiptType',
            style: TextStyle(fontSize: 10, font: unicodeFont),
          ),
          if (receiptType != "PS" && receiptType != "TS" && receiptType != "TR")
            Text(
              'Internal Data: ${internalData.toDashedStringInternalData()}',
              style: TextStyle(fontSize: 10, font: unicodeFont),
            ),
          if (receiptType != "PS" && receiptType != "TS" && receiptType != "TR")
            Text(
              'Receipt Signature: ${receiptSignature.toDashedStringRcptSign()}',
              style: TextStyle(fontSize: 10, font: unicodeFont),
            ),
          SizedBox(height: 5),
          _dashWidget(),
          SizedBox(height: 5),
          Text(
            'Receipt Number: $invoiceNum',
            style: TextStyle(fontSize: 10, font: unicodeFont),
          ),
          Text(
            'Date: ${whenCreated.isoDateTime}',
            style: TextStyle(fontSize: 10, font: unicodeFont),
          ),
          Text(
            "MRC: ${_getMrc()}",
            style: TextStyle(fontSize: 10, font: unicodeFont),
          ),
          _dashWidget(),
        ],
      ),
    );
  }

  String _getMrc() {
    final boxMrc = ProxyService.box.mrc();
    if (boxMrc != null && boxMrc.isNotEmpty && boxMrc.length == 11) {
      return boxMrc;
    }
    return mrc;
  }

  Widget _buildQrCodeSection() {
    return Center(
      child: SizedBox(
        width: 60,
        height: 60,
        child: BarcodeWidget(
          barcode: Barcode.qrCode(
            errorCorrectLevel: BarcodeQRCorrectionLevel.high,
          ),
          data: receiptQrCode,
        ),
      ),
    );
  }

  Widget _buildSummaryTable() {
    return Expanded(
      child: Column(
        children: [
          SizedBox(height: 5),
          Table(
            border: TableBorder.all(width: 0.5),
            children: [
              _buildTotalRow(),
              if (_shouldShowTaxA()) _buildTaxARow(),
              if (safeParseDouble(totalTaxB) != 0) _buildTaxBRow(),
              if (safeParseDouble(totalTaxB) != 0) _buildTotalTaxBRow(),
              if (items.any((item) => item.taxTyCd == "C")) _buildTaxCRow(),
              _buildTotalTaxRow(),
              _builtPaymentInfoRow(
                payment: transaction.paymentType!.toUpperCase(),
              ),
              if (safeParseDouble(totalTaxD) != 0) _buildTaxDRow(),
            ],
          ),
          SizedBox(height: 5),
          _buildPaymentInfoTable(),
        ],
      ),
    );
  }

  TableRow _buildTotalRow() {
    return TableRow(
      children: [
        _buildCell('TOTAL:', fontWeight: FontWeight.bold),
        _buildCell(
          (receiptType == "NR" || receiptType == "CR" || receiptType == "TR")
              ? "-${safeParseDouble(totalPayable - totalDiscount).toNoCurrencyFormatted()}"
              : safeParseDouble(totalPayable - totalDiscount)
                  .toNoCurrencyFormatted(),
        ),
      ],
    );
  }

  bool _shouldShowTaxA() {
    return items.any((item) =>
        item.taxTyCd == "A" &&
        items.where((item) => item.taxTyCd == "A").fold<double>(
                0.0, (sum, item) => sum + (item.price * item.qty)) >
            0);
  }

  TableRow _buildTaxARow() {
    final totalA = items
        .where((item) => item.taxTyCd == "A")
        .fold<double>(0.0, (sum, item) => sum + (item.price * item.qty));
    return TableRow(
      children: [
        _buildCell('TOTAL A-EX:'),
        _buildCell(
          (receiptType == "NR" || receiptType == "CR" || receiptType == "TR")
              ? "-${totalA.toStringAsFixed(2)}"
              : totalA.toStringAsFixed(2),
        ),
      ],
    );
  }

  TableRow _buildTaxBRow() {
    final totalB = items
        .where((item) => item.taxTyCd == "B")
        .fold<double>(0.0, (sum, item) => sum + (item.price * item.qty));
    return TableRow(children: [
      _buildCell('TOTAL B-18%:'),
      _buildCell(
        (receiptType == "NR" || receiptType == "CR" || receiptType == "TR")
            ? "-${totalB.toNoCurrencyFormatted()}"
            : totalB.toNoCurrencyFormatted(),
      ),
    ]);
  }

  TableRow _buildTotalTaxBRow() {
    return TableRow(
      children: [
        _buildCell('TOTAL TAX B:'),
        _buildCell(
          (receiptType == "NR" || receiptType == "CR" || receiptType == "TR")
              ? "-${safeParseDouble(totalTaxB).toNoCurrencyFormatted()}"
              : safeParseDouble(totalTaxB).toNoCurrencyFormatted(),
        ),
      ],
    );
  }

  TableRow _buildTaxCRow() {
    final totalC = items
        .where((item) => item.taxTyCd == "C")
        .fold<double>(0.0, (sum, item) => sum + (item.price * item.qty));
    return TableRow(
      children: [
        _buildCell('TOTAL C:'),
        _buildCell(
          (receiptType == "NR" || receiptType == "CR" || receiptType == "TR")
              ? "-${totalC.toNoCurrencyFormatted()}"
              : totalC.toNoCurrencyFormatted(),
        ),
      ],
    );
  }

  TableRow _buildTotalTaxRow() {
    return TableRow(
      children: [
        _buildCell('TOTAL TAX:'),
        _buildCell(
          (receiptType == "NR" || receiptType == "CR" || receiptType == "TR")
              ? "-${safeParseDouble(totalTax).toStringAsFixed(2)}"
              : safeParseDouble(totalTax).toStringAsFixed(2),
        ),
      ],
    );
  }

  TableRow _builtPaymentInfoRow({required String payment}) {
    return TableRow(
      children: [
        _buildCell('$payment:'),
        _buildCell((receiptType == "NR" ||
                receiptType == "CR" ||
                receiptType == "TR")
            ? "-${safeParseDouble(totalPayable - totalDiscount).toNoCurrencyFormatted()}"
            : safeParseDouble(totalPayable - totalDiscount)
                .toNoCurrencyFormatted()),
      ],
    );
  }

  TableRow _buildTaxDRow() {
    return TableRow(
      children: [
        _buildCell('Total D'),
        _buildCell(
          (receiptType == "NR" || receiptType == "CR" || receiptType == "TR")
              ? "-${safeParseDouble(totalTaxD).toStringAsFixed(2)}"
              : safeParseDouble(totalTaxD).toStringAsFixed(2),
        ),
      ],
    );
  }

  Widget _buildPaymentInfoTable() {
    return Table(
      border: TableBorder.all(width: 0.5),
      children: [
        TableRow(
          children: [
            _buildCell('PAYMENT METHOD:'),
            _buildCell(transaction.paymentType ?? ""),
          ],
        ),
        TableRow(
          children: [
            _buildCell('ITEMS NUMBER:'),
            _buildCell(items.length.toString()),
          ],
        ),
      ],
    );
  }

  Widget _buildCell(String text, {FontWeight? fontWeight}) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          font: unicodeFont,
          fontWeight: fontWeight,
        ),
      ),
    );
  }

  Widget _dashWidget() {
    return Container(
      height: 1,
      // color: Colors.black,
      margin: const EdgeInsets.symmetric(vertical: 2),
    );
  }

  double safeParseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }
}
