import 'package:flutter/material.dart';

import 'print_example.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(home: PrintExample()));
}
