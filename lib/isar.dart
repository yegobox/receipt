import 'package:isar/isar.dart';
import 'package:isar_demo/student.dart';
import 'package:isar_demo/teacher.dart';
import 'user.dart';
import 'post.dart';

late Isar isar;

class IsarApi {
  static addPosts() async {
    await isar.writeTxn((isar) async {
      await isar.users.put(User()..name = "Linda", saveLinks: true);
    });
    User? a = isar.users.where().filter().nameEqualTo('Linda').findFirstSync();
    a!.posts.add(Post()
      ..title = 'Hello World'
      ..table = "posts");
    await isar.writeTxn((isar) async {
      await a.posts.save();
    });
  }

  // a stream of posts from isar db
  static Stream<List<Post>> posts() async* {
    isar = await Isar.open(
      directory: 'main',
      schemas: [
        PostSchema,
        UserSchema,
        StudentSchema,
        TeacherSchema,
      ],
      inspector: true,
    );

    Query<Post> usersWithA = isar.posts.filter().tableEqualTo("posts").build();

    Stream<List<Post>> queryChanged = usersWithA.watch(initialReturn: true);
    yield* queryChanged;
  }
}
