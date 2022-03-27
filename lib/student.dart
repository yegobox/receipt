import 'package:isar/isar.dart';
import 'package:isar_demo/teacher.dart';
part 'student.g.dart';

@Collection()
class Student {
  int? id;

  late String name;

  final teachers = IsarLinks<Teacher>();
}
