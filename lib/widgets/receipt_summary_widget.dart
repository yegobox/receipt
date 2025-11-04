import 'package:flipper_services/proxy.dart';
import 'package:pdf/widgets.dart';
import 'package:supabase_models/brick/models/all_models.dart';
import 'package:flipper_models/helperModels/extensions.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

class ReceiptSummaryWidget extends StatelessWidget {
  final String receiptType;
  final String receiptQrCode;
  final List<TransactionItem> items;
  final double totalPayable;
  final double totalDiscount;
  final double totalTax;
  final double totalTaxB;
  final double totalTaxD;
  final double totalTaxTT;
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
  final bool vatEnabled;

  ReceiptSummaryWidget({
    required this.receiptType,
    required this.receiptQrCode,
    required this.items,
    required this.totalPayable,
    required this.totalDiscount,
    required this.totalTax,
    required this.totalTaxB,
    required this.totalTaxD,
    required this.totalTaxTT,
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
    required this.vatEnabled,
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
          SizedBox(height: 1),
          _dashWidget(),
          SizedBox(height: 1),
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
          SizedBox(height: 1),
          Table(
            border: TableBorder.all(width: 0.5),
            children: [
              _buildTotalRow(),
              if (_shouldShowTaxA()) _buildTaxARow(),
              if (safeParseDouble(totalTaxB) != 0) _buildTaxBRow(),
              if (safeParseDouble(totalTaxB) != 0) _buildTotalTaxBRow(),
              if (items.any((item) => item.taxTyCd == "C")) _buildTaxCRow(),
              if (items.any((item) => item.taxTyCd == "D")) _buildTaxDRow(),
              if (items.any((item) => item.ttCatCd == "TT") && vatEnabled)
                _buildTaxTTRow(),
              _buildTotalTaxRow(),
              _builtPaymentInfoRow(
                payment: transaction.paymentType!.toUpperCase(),
              ),
            ],
          ),
          SizedBox(height: 1),
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
    // Sum item totals for tax type B after applying per-item discounts
    final totalB = items.where((item) => item.taxTyCd == "B").fold<double>(
      0.0,
      (sum, item) {
        final itemTotal = item.price * item.qty;
        final discounted = itemTotal * (1 - (item.dcRt ?? 0) / 100);
        return sum + discounted;
      },
    );
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
    // Start with configured totalTaxB. Do NOT add TT VAT portion here —
    // upstream calculations already include any VAT contributions to totalTaxB.
    // The TT-specific VAT/exclusive breakdown is shown under 'TOTAL TT-3%'.
    double displayedTotalTaxB = safeParseDouble(totalTaxB);

    return TableRow(
      children: [
        _buildCell('TOTAL TAX B:'),
        _buildCell(
          (receiptType == "NR" || receiptType == "CR" || receiptType == "TR")
              ? "-${displayedTotalTaxB.toNoCurrencyFormatted()}"
              : displayedTotalTaxB.toNoCurrencyFormatted(),
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
    // Calculate actual total tax including TT tax
    double actualTotalTax = safeParseDouble(totalTax);
    bool hasTTItem = items.any((item) => item.ttCatCd == 'TT');

    // Add TT tax amount if there are TT items and it's not already included
    if (hasTTItem) {
      double ttTaxAmount = 0.0;
      for (var item in items.where((item) => item.ttCatCd == 'TT')) {
        double totalAfterDiscount =
            (item.price * item.qty) * (1 - (item.dcRt ?? 0) / 100);

        ttTaxAmount +=
            totalAfterDiscount * 3 / (100 + 3); // Using configuration formula
      }
      // Add TT tax since it's not included in the original totalTax parameter
      actualTotalTax += ttTaxAmount;
    }

    // Show 'TOTAL TT:' when VAT disabled and TT items exist, otherwise 'TOTAL TAX:'
    String taxLabel = (!vatEnabled && hasTTItem) ? 'TOTAL TT:' : 'TOTAL TAX:';

    return TableRow(
      children: [
        _buildCell(taxLabel),
        _buildCell(
          (receiptType == "NR" || receiptType == "CR" || receiptType == "TR")
              ? "-${actualTotalTax.toStringAsFixed(2)}"
              : actualTotalTax.toStringAsFixed(2),
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
    // Sum item totals for tax type D after applying per-item discounts, excluding TT items
    final totalD = items.where((item) => item.taxTyCd == "D").fold<double>(
      0.0,
      (sum, item) {
        final itemTotal = item.price * item.qty;
        final discounted = itemTotal * (1 - (item.dcRt ?? 0) / 100);
        return sum + discounted;
      },
    );
    if (totalD == 0) return TableRow(children: []);
    return TableRow(children: [
      _buildCell('TOTAL D:'),
      _buildCell(
        (receiptType == "NR" || receiptType == "CR" || receiptType == "TR")
            ? "-${totalD.toNoCurrencyFormatted()}"
            : totalD.toNoCurrencyFormatted(),
      ),
    ]);
  }

  TableRow _buildTaxTTRow() {
    // Calculate TT tax amount using the same logic as rw_tax.dart
    double ttTaxAmount = 0.0;

    for (var item in items.where((item) => item.ttCatCd == 'TT')) {
      double totalAfterDiscount =
          (item.price * item.qty) * (1 - (item.dcRt ?? 0) / 100);

      ttTaxAmount +=
          totalAfterDiscount * 3 / (100 + 3); // Using configuration formula
    }

    return TableRow(
      children: [
        _buildCell('TOTAL TT:'),
        _buildCell(
          (receiptType == "NR" || receiptType == "CR" || receiptType == "TR")
              ? "-${ttTaxAmount.toNoCurrencyFormatted()}"
              : ttTaxAmount.toNoCurrencyFormatted(),
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
    return CustomPaint(
      size: const PdfPoint(double.infinity, 10),
      painter: (PdfGraphics canvas, PdfPoint size) {
        const double dashWidth = 2.0, dashSpace = 2.0;
        double startX = 0.0;
        while (startX < size.x) {
          canvas
            ..moveTo(startX, 0)
            ..lineTo(startX + dashWidth, 0)
            ..setColor(PdfColors.black)
            ..setLineWidth(0.5)
            ..strokePath();
          startX += dashWidth + dashSpace;
        }
      },
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
