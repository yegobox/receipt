import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:receipt/receipt_pdf_assets.dart';
import 'package:flipper_services/proxy.dart';
import 'package:flipper_models/helperModels/extensions.dart';

class A4SdcInfo extends pw.StatelessWidget {
  final String receiptType;
  final DateTime timeFromServer;
  final String sdcId;
  final int rcptNo;
  final int totRcptNo;
  final String? internalData;
  final String? receiptSignature;
  final int invoiceNum;
  final String mrc;
  final DateTime whenCreated;
  final String? receiptQrCode;
  final pw.Font? font;

  A4SdcInfo({
    required this.receiptType,
    required this.timeFromServer,
    required this.sdcId,
    required this.rcptNo,
    required this.totRcptNo,
    required this.internalData,
    required this.receiptSignature,
    required this.invoiceNum,
    required this.mrc,
    required this.whenCreated,
    this.receiptQrCode,
    required this.font,
  });

  @override
  pw.Widget build(pw.Context context) {
    // Don't show SDC info for certain receipt types
    if (receiptType == "CR" ||
        receiptType == "PS" ||
        receiptType == "TR" ||
        receiptType == "TS") {
      return pw.SizedBox.shrink();
    }

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      children: [
        // SDC Information Column
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'SDC INFORMATION',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  font: font,
                ),
              ),
              _dashWidget(),
              pw.SizedBox(height: 5),
              _buildInfoRow('Date:', timeFromServer.isoDateTime),
              _buildInfoRow('SDC ID:', sdcId),
              _buildInfoRow(
                  'Receipt Number:', '$rcptNo/$totRcptNo $receiptType'),
              if (receiptType != "PS" &&
                  receiptType != "TS" &&
                  receiptType != "TR")
                _buildInfoRow('Internal Data:',
                    internalData?.toDashedStringInternalData() ?? ''),
              if (receiptType != "PS" &&
                  receiptType != "TS" &&
                  receiptType != "TR")
                _buildInfoRow('Receipt Signature:',
                    receiptSignature?.toDashedStringRcptSign() ?? ''),
              pw.SizedBox(height: 5),
              _dashWidget(),
              pw.SizedBox(height: 5),
              _buildInfoRow('Receipt Number:', invoiceNum.toString()),
              _buildInfoRow('Date:', whenCreated.isoDateTime),
              _buildInfoRow('MRC:', _getMrc().toUpperCase()),
              _dashWidget(),
            ],
          ),
        ),
        // Spacer between columns
        if (receiptType != "PS" && receiptType != "TS" && receiptType != "CR")
          pw.SizedBox(width: 20),
        // QR Code (if applicable)
        if (receiptType != "PS" &&
            receiptType != "TS" &&
            receiptType != "TR" &&
            receiptType != "CR" &&
            receiptQrCode != null)
          _buildQrCode(),
      ],
    );
  }

  String _getMrc() {
    final boxMrc = ProxyService.box.mrc();
    if (boxMrc != null && boxMrc.isNotEmpty && boxMrc.length == 11) {
      return boxMrc;
    }
    return mrc;
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Text(
      '$label $value',
      style: pw.TextStyle(fontSize: 10, font: font),
    );
  }

  pw.Widget _dashWidget() {
    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.symmetric(vertical: 4),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColors.black,
            width: 0.5,
            style: pw.BorderStyle.dashed,
          ),
        ),
      ),
    );
  }

  pw.Widget _buildQrCode() {
    return pw.Center(
      child: ReceiptPdfAssets.qrBarcode(
        data: receiptQrCode!,
        size: 60,
      ),
    );
  }
}
