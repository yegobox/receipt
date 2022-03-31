import 'package:isar/isar.dart';
import 'package:isar_demo/stock_sync.dart';
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

    // test complicated
    StockSync stock = StockSync()
      ..canTrackingStock = false
      ..showLowStockAlert = false
      ..currentStock = 0.0
      ..branchId = 1
      ..variantId = 1
      ..supplyPrice = 0.0
      ..retailPrice = 0.0
      ..lowStock = 10.0
      ..canTrackingStock = true
      ..showLowStockAlert = true
      ..value = 300.0
      ..active = false
      ..productId = 1;

    await isar.writeTxn((isar) async {
      return isar.stockSyncs.put(stock, saveLinks: true);
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
        StockSyncSchema,
      ],
      inspector: true,
    );

    Query<Post> usersWithA = isar.posts.filter().tableEqualTo("posts").build();

    Stream<List<Post>> queryChanged = usersWithA.watch(initialReturn: true);
    yield* queryChanged;
  }
}
