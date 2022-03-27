import 'package:isar/isar.dart';

import 'post.dart';

part 'user.g.dart';

@Collection()
class User {
  late int id = Isar.autoIncrement;
  late String name;
  final posts = IsarLinks<Post>();
}
