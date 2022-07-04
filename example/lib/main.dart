import 'package:flutter/material.dart';
import 'package:flipper_services/locator.dart';
import 'package:get_storage/get_storage.dart';
import 'print_example.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  // done init in mobile.//done separation.
  setupLocator();
  runApp(const MaterialApp(home: PrintExample()));
}
