import 'package:pdf/widgets.dart';

extension NormalizePhoneNumber on String {
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
  Widget hideIf(bool hide) => hide ? this : this;
}
