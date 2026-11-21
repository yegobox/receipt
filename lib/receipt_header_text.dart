/// The line printed under the business details when the branch has not set
/// its own (Tax Settings → Receipt header in Flipper).
const String defaultReceiptWelcomeMessage = 'WELCOME TO OUR SHOP';

/// The welcome line to print: the branch's own text, or the default when it is
/// missing or blank.
String receiptWelcomeLine(String? message) {
  final trimmed = message?.trim() ?? '';
  return trimmed.isEmpty ? defaultReceiptWelcomeMessage : trimmed;
}

/// Whether a header contact value (phone, email) has anything worth printing.
/// A blank value prints no line at all rather than a bare `TEL:` label.
bool hasReceiptContact(String? value) => (value?.trim() ?? '').isNotEmpty;
