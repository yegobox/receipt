import 'package:isar/isar.dart';

part 'post.g.dart';

@Collection()
class Post {
  late int id = Isar.autoIncrement;
  late String title;
  late String table;
}
