import 'package:isar/isar.dart';

part 'user.g.dart';

@Collection()
class User {
  late int id = Isar.autoIncrement;
  late String name;
}
