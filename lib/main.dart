import 'package:flutter/material.dart';
import 'package:isar_demo/printing_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(home: PrintingModel()));
}
