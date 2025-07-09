import 'package:pdf/widgets.dart';

extension NormalizePhoneNumber on String {
  /// Normalizes a phone number:
  /// - "00783054874" => "0783054874"
  /// - "783054874"   => "0783054874"
  /// - "0783054874"  => "0783054874"
  String normalizePhoneNumber() {
    final digitsOnly = replaceAll(RegExp(r'\D'), ''); // remove non-digits
    if (digitsOnly.startsWith('00')) {
      return '0${digitsOnly.substring(2)}';
    } else if (digitsOnly.length == 9 && digitsOnly.startsWith('7')) {
      return '0$digitsOnly';
    } else {
      return digitsOnly;
    }
  }
}

extension HideIfNull on Widget {
  /// Hides this widget if [hide] is true, otherwise returns the widget.
  Widget hideIf(bool hide) => hide ? SizedBox.shrink() : this;
}