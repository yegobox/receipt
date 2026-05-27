import 'dart:convert';

import 'package:flipper_services/proxy.dart';
import 'package:flutter/material.dart' as c;
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';

class ReceiptPdfAssets {
  static Font? _unicodeFont;
  static Future<Font>? _unicodeFontFuture;
  static final Map<String, Future<ImageProvider?>> _assetLogoFutures = {};
  static String? _middleLogoBase64;
  static ImageProvider? _middleLogo;

  static Future<Font> unicodeFont() async {
    final font = _unicodeFont;
    if (font != null) return font;

    final pendingFont = _unicodeFontFuture;
    if (pendingFont != null) return pendingFont;

    final future = _loadUnicodeFont();
    _unicodeFontFuture = future;

    try {
      return await future;
    } catch (_) {
      if (identical(_unicodeFontFuture, future)) {
        _unicodeFontFuture = null;
      }
      rethrow;
    }
  }

  static Future<Font> _loadUnicodeFont() async {
    final fontData = await rootBundle
        .load('packages/receipt/assets/fonts/NotoSans-Regular.ttf');
    final font = Font.ttf(fontData);
    _unicodeFont = font;
    // Any pdf/widgets document without an explicit theme uses this (not Courier).
    ThemeData.buildThemeData = () => unicodeTheme(font);
    return font;
  }

  /// [TextStyle] with all font slots set so bold/italic never resolve to Type1 Courier.
  static TextStyle textStyle(
    Font font, {
    double fontSize = 10,
    FontWeight fontWeight = FontWeight.normal,
    FontStyle fontStyle = FontStyle.normal,
    PdfColor? color,
  }) {
    // inherit:false requires every metric field; defaultStyle() supplies them.
    return TextStyle.defaultStyle().copyWith(
      color: color ?? PdfColors.black,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      font: font,
      fontNormal: font,
      fontBold: font,
      fontItalic: font,
      fontBoldItalic: font,
    );
  }

  /// QR on receipts does not need a caption; [drawText: false] avoids dart_pdf's
  /// default Courier caption style inside [BarcodeWidget].
  static Widget qrBarcode({
    required String data,
    double size = 40,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: BarcodeWidget(
        barcode: Barcode.qrCode(
          errorCorrectLevel: BarcodeQRCorrectionLevel.high,
        ),
        data: data,
        drawText: false,
      ),
    );
  }

  /// Default [Document]/[Page] theme so dart_pdf never falls back to Courier
  /// (Courier cannot render most Unicode and triggers slow fallback paths).
  static ThemeData unicodeTheme(Font font) {
    return ThemeData.withFont(
      base: font,
      bold: font,
      italic: font,
      boldItalic: font,
    );
  }

  /// Ensures a loaded Unicode font is available after [unicodeFont].
  static Font requireUnicodeFont(Font? font) {
    if (font != null) return font;
    throw StateError(
      'Receipt Unicode font not loaded. Call ReceiptPdfAssets.unicodeFont() '
      'or OmniPrinter.loadUnicodeFont() before building a PDF.',
    );
  }

  static Future<ImageProvider?> logo({required String position}) {
    if (position == 'middle') {
      return Future.value(_customMiddleLogo());
    }

    return _assetLogoFutures.putIfAbsent(
      position,
      () async {
        try {
          return await _loadAssetLogo(position);
        } catch (_) {
          _assetLogoFutures.remove(position);
          rethrow;
        }
      },
    );
  }

  static ImageProvider? _customMiddleLogo() {
    final customLogo = ProxyService.box.receiptLogoBase64();
    if (customLogo == null || customLogo.isEmpty) {
      _middleLogoBase64 = null;
      _middleLogo = null;
      return null;
    }

    if (customLogo == _middleLogoBase64) {
      return _middleLogo;
    }

    try {
      final bytes = base64Decode(customLogo);
      if (bytes.isEmpty) return null;

      _middleLogoBase64 = customLogo;
      _middleLogo = MemoryImage(bytes);
      return _middleLogo;
    } catch (_) {
      return null;
    }
  }

  static Future<ImageProvider?> _loadAssetLogo(String position) async {
    switch (position) {
      case 'left':
        const imageLogo =
            c.AssetImage('assets/logo_left.png', package: 'receipt');
        return flutterImageProvider(
          imageLogo,
          configuration: const c.ImageConfiguration(size: Size(600, 600)),
        );
      case 'right':
        const imageLogo =
            c.AssetImage('assets/logo_right.png', package: 'receipt');
        return flutterImageProvider(
          imageLogo,
          configuration: const c.ImageConfiguration(size: Size(100, 100)),
        );
      default:
        throw ArgumentError('Invalid position: $position');
    }
  }
}
