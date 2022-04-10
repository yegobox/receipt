import 'package:pdf/widgets.dart';
import 'package:pdf/pdf.dart';

import 'package:receipt/pw_page.dart';
import 'package:printing/printing.dart';

/// [generateDoc] example
/// generateDoc(
///   header: [
///     Text('K5 25 Ave', style: const TextStyle(fontSize: 5)),
///     Text('+250 788 888 888',
///         style: const TextStyle(fontSize: 5)),
///   ],
///   subHeader: [
///     Text('Cashier: John Doe',
///         style: const TextStyle(fontSize: 5)),
///     Container(width: 10),
///     Column(
///       children: [
///         Text('June 19,2021',
///             style: const TextStyle(fontSize: 5)),
///         Text('11:20 am', style: const TextStyle(fontSize: 5)),
///       ],
///     )
///   ],
///   body: Table(children: [
///     TableRow(children: [
///       Text('Qty', style: const TextStyle(fontSize: 5)),
///       Text('DESC', style: const TextStyle(fontSize: 5)),
///       Text('AMT', style: const TextStyle(fontSize: 5)),
///     ]),
///     TableRow(children: [
///       Text('1', style: const TextStyle(fontSize: 5)),
///       Text('Coffee', style: const TextStyle(fontSize: 5)),
///       Text('\$1.00', style: const TextStyle(fontSize: 5)),
///     ]),
///     TableRow(children: [
///       Text('1', style: const TextStyle(fontSize: 5)),
///       Text('Coffee', style: const TextStyle(fontSize: 5)),
///       Text('\$1.00', style: const TextStyle(fontSize: 5)),
///     ]),
///     TableRow(children: [
///       Text('1', style: const TextStyle(fontSize: 5)),
///       Text('Coffee', style: const TextStyle(fontSize: 5)),
///       Text('\$1.00', style: const TextStyle(fontSize: 5)),
///     ]),
///     /// show total
///     TableRow(children: [
///       Text(''),
///       Text('Total', style: const TextStyle(fontSize: 6)),
///       Text('\$3.00', style: const TextStyle(fontSize: 6)),
///     ]),
///   ]),
/// );
class OmniPrinter {
  final doc = Document();

  Future<bool> autoPrint() async {
    Printing.layoutPdf(
      format: PdfPageFormat.roll80,
      // format: PdfPageFormat.a4,
      onLayout: (PdfPageFormat format) async {
        return doc.save();
      },
      // this will use a default printer if it is set.
      usePrinterSettings: true,
    );
    return Future.value(false);
  }

  // Uint8List
  Future<void> generateDoc({
    String? date = "4/9/2020",
    String? info,
    String? taxId = "12331",
    String? receiverName = "Richie",
    String? receiverMail = "info@yegobox.com",
    String? receiverPhone,
    String email = "info@yegobox.com",
    required List<TableRow> rows,
  }) async {
    doc.addPage(
      Page(
        pageFormat: PdfPageFormat.a4,
        build: (Context context) {
          return PwPage(
            date: date,
            info: info,
            taxID: taxId,
            receiverName: receiverName,
            receiverMail: receiverMail,
            receiverPhone: receiverPhone,
            rows: rows,
          );
        },
      ),
    );
    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'receipt.pdf',
      subject: "receipt",
      body: "Thank you for visinting us",
      emails: [email],
    );
  }
}
