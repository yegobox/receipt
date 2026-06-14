class PlatformPrinter {
  Future<bool> printFile(dynamic imageData) async {
    // No-op on web - printing not supported
    return false;
  }
}
