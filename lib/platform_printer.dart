// This file conditionally imports the correct implementation based on platform
export 'platform_printer_web.dart'
    if (dart.library.io) 'platform_printer_io.dart';
