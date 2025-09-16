import 'package:pdf/widgets.dart' as pw;
import 'package:supabase_models/brick/models/all_models.dart';
import 'package:flipper_models/helperModels/extensions.dart';

class A4ItemsTable extends pw.StatelessWidget {
  final List<TransactionItem> items;
  final String receiptType;
  final pw.Font? font;
  final int minRows;

  A4ItemsTable({
    required this.items,
    required this.receiptType,
    required this.font,
    this.minRows = 10,
  });
  // Helper method:
  String _buildTotalPriceText(TransactionItem item, String receiptType) {
    final isNegativeReceipt = ["NR", "CR", "TR"].contains(receiptType);
    final baseAmount = item.qty * item.price;

    String firstLine = isNegativeReceipt
        ? "-${baseAmount.toNoCurrencyFormatted()}"
        : baseAmount.toNoCurrencyFormatted();

    if (safeParseDouble(item.dcRt) == 0) {
      return firstLine;
    }

    final discountedAmount = baseAmount - (baseAmount * item.dcRt! / 100);
    String secondLine = isNegativeReceipt
        ? "-${discountedAmount.toNoCurrencyFormatted()}"
        : discountedAmount.toNoCurrencyFormatted();

    return "$firstLine\n$secondLine";
  }

  double safeParseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) {
      if (value.isNaN || value.isInfinite) return 0.0;
      return value;
    }
    if (value is int) return value.toDouble();
    if (value is String) {
      final cleaned = value.replaceAll(',', '').trim();
      final parsed = double.tryParse(cleaned);
      if (parsed == null || parsed.isNaN || parsed.isInfinite) return 0.0;
      return parsed;
    }
    return 0.0;
  }

  @override
  pw.Widget build(pw.Context context) {
    return pw.TableHelper.fromTextArray(
      headers: [
        'Item Code',
        'Description',
        'Qty',
        'Tax',
        'Unit Price',
        'Total Price'
      ],
      data: [
        ...items.map((item) => [
              item.itemCd ?? '',
              pw.Text(
                item.name +
                    (safeParseDouble(item.dcRt) != 0
                        ? "\nDiscount - ${item.dcRt}%"
                        : ""),
                style: pw.TextStyle(fontSize: 10, font: font),
              ),
              '${item.qty}',
              (item.taxTyCd ?? ''),
              item.price.toNoCurrencyFormatted(),
              pw.Text(
                _buildTotalPriceText(item, receiptType),
                style: pw.TextStyle(fontSize: 10, font: font),
              ),
            ]),
        // Only add empty rows if we have fewer items than minRows
        if (items.length < minRows)
          ...List.generate(
            minRows - items.length,
            (_) => ['', '', '', '', '', ''],
          ),
      ],
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 10,
        font: font,
      ),
      cellStyle: pw.TextStyle(fontSize: 10, font: font),
      cellAlignment: pw.Alignment.topLeft,
      headerHeight: 20,
      // Remove rowHeight to allow rows to grow with content
      columnWidths: {
        0: const pw.FixedColumnWidth(50), // Item Code - slightly smaller
        1: const pw.FixedColumnWidth(
            120), // Description - fixed width to limit space
        2: const pw.FixedColumnWidth(25), // Qty - slightly smaller
        3: const pw.FixedColumnWidth(25), // Tax - slightly smaller
        4: const pw.FixedColumnWidth(80), // Unit Price - increased width
        5: const pw.FixedColumnWidth(90), // Total Price - increased width
      },
      headerDecoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(width: 0.5),
          bottom: pw.BorderSide(width: 0.5),
          left: pw.BorderSide(width: 0.5),
          right: pw.BorderSide(width: 0.5),
        ),
      ),
      border: const pw.TableBorder(
        right: pw.BorderSide(width: 0.5),
        left: pw.BorderSide(width: 0.5),
        bottom: pw.BorderSide(width: 0.5),
        horizontalInside: pw.BorderSide.none,
        verticalInside: pw.BorderSide(width: 0.5),
      ),
      cellPadding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 5),
    );
  }
}
