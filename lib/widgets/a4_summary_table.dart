import 'package:pdf/widgets.dart' as pw;
import 'package:flipper_services/proxy.dart';
import 'package:supabase_models/brick/models/all_models.dart';
import 'package:flipper_models/helperModels/extensions.dart';

class A4SummaryTable extends pw.StatelessWidget {
  final String receiptType;
  final List<TransactionItem> items;
  final double totalPayable;
  final double totalDiscount;
  final double totalTax;
  final double totalTaxA;
  final double totalTaxB;
  final double totalTaxC;
  final double totalTaxD;
  final pw.Font? font;
  final bool vatEnabled;

  final bool hasTTItem;

  A4SummaryTable(
      {required this.receiptType,
      required this.items,
      required this.totalPayable,
      required this.totalDiscount,
      required this.totalTax,
      required this.totalTaxA,
      required this.totalTaxB,
      required this.totalTaxC,
      required this.totalTaxD,
      required this.font,
      required this.vatEnabled,
      required this.hasTTItem});

  @override
  pw.Widget build(pw.Context context) {
    final isRefund =
        receiptType == "NR" || receiptType == "CR" || receiptType == "TR";
    final prefix = isRefund ? "-" : "";
    final hasTaxA = items.any((item) => item.taxTyCd == "A") &&
        items.where((item) => item.taxTyCd == "A").fold<double>(
                  0.0,
                  (sum, item) => sum + (item.price * item.qty),
                ) >
            0;

    return pw.Expanded(
      child: pw.Column(
        children: [
          pw.SizedBox(height: 5),
          // Totals and Taxes Table
          pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            children: [
              // Total Row
              _buildTableRow(
                label: 'TOTAL:',
                value:
                    '$prefix${(totalPayable - totalDiscount).toNoCurrencyFormatted()}',
                isBold: true,
              ),

              // Total A-EX (if applicable)
              if (hasTaxA)
                _buildTableRow(
                  label: 'TOTAL A-EX:',
                  value: _calculateTaxATotal(),
                ),

              // Total B-18% (if applicable)
              if (totalTaxB != 0) ...[
                _buildTableRow(
                  label: 'TOTAL B-18%:',
                  value: _calculateTaxBTotal(),
                ),
                _buildTableRow(
                  label: 'TOTAL TAX B:',
                  value: '$prefix${totalTaxB.toNoCurrencyFormatted()}',
                ),
              ],

              // Total C (if applicable)
              if (items.any((item) => item.taxTyCd == "C"))
                _buildTableRow(
                  label: 'TOTAL C:',
                  value: _calculateTaxCTotal(),
                ),
              // Total D (if applicable)
              if (totalTaxD != 0)
                _buildTableRow(
                  label: 'Total D:',
                  value: '$prefix${totalTaxD.toStringAsFixed(2)}',
                ),
              if (!vatEnabled && hasTTItem)
                // Total TT (if applicable)
                _buildTableRow(
                  label: 'TOTAL TT:',
                  value: _calculateTaxCTotal(),
                ),
              if (vatEnabled || (!vatEnabled && !hasTTItem))
                // Total Tax
                _buildTableRow(
                  label: 'TOTAL TAX:',
                  value: '$prefix${totalTax.toStringAsFixed(2)}',
                ),
            ],
          ),

          // Payment Method and Items Number
          pw.SizedBox(height: 5),
          pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            children: [
              _buildTableRow(
                label: 'PAYMENT METHOD:',
                value: '${_getPaymentType(ProxyService.box.pmtTyCd())}:',
              ),
              _buildTableRow(
                label: 'ITEMS NUMBER:',
                value: items.length.toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.TableRow _buildTableRow({
    required String label,
    required String value,
    bool isBold = false,
  }) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : null,
              fontSize: 10,
              font: font,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 10,
              font: font,
            ),
          ),
        ),
      ],
    );
  }

  String _calculateTaxATotal() {
    final total = items.where((item) => item.taxTyCd == "A").fold<double>(
          0.0,
          (sum, item) => sum + (item.price * item.qty),
        );
    final prefix =
        (receiptType == "NR" || receiptType == "CR" || receiptType == "TR")
            ? "-"
            : "";
    return '$prefix${total.toStringAsFixed(2)}';
  }

  String _calculateTaxBTotal() {
    // Sum item totals for tax type B after applying per-item discounts
    final total = items.where((item) => item.taxTyCd == "B").fold<double>(
      0.0,
      (sum, item) {
        final itemTotal = item.price * item.qty;
        final discounted = itemTotal * (1 - (item.dcRt ?? 0) / 100);
        return sum + discounted;
      },
    );
    final prefix =
        (receiptType == "NR" || receiptType == "CR" || receiptType == "TR")
            ? "-"
            : "";
    return '$prefix${total.toNoCurrencyFormatted()}';
  }

  String _calculateTaxCTotal() {
    final total = items.where((item) => item.taxTyCd == "C").fold<double>(
          0.0,
          (sum, item) => sum + (item.price * item.qty),
        );
    final prefix =
        (receiptType == "NR" || receiptType == "CR" || receiptType == "TR")
            ? "-"
            : "";
    return '$prefix${total.toNoCurrencyFormatted()}';
  }

  String _getPaymentType(String paymentCode) {
    switch (paymentCode) {
      case '01':
        return 'CASH';
      case '02':
        return 'CREDIT CARD';
      case '03':
        return 'CASH/CREDIT CARD';
      case '04':
        return 'BANK CHECK';
      case '05':
        return 'DEBIT&CREDIT CARD';
      case '06':
        return 'MOBILE MONEY';
      case '07':
      default:
        return 'OTHER';
    }
  }
}
