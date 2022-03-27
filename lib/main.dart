import 'package:flutter/material.dart';
// import 'package:isar_demo/printing_model.dart';

import 'isar.dart';
import 'isar_demo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // runApp(const MaterialApp(home: PrintingModel()));
  IsarApi();
  runApp(MaterialApp(home: IsarDemo()));
}
