library flipper_models;

import 'package:isar/isar.dart';

import 'variant_sync.dart';

part 'product_sync.g.dart';

@Collection()
class ProductSync {
  late int id = Isar.autoIncrement;
  late String name;
  String? picture;
  String? description;
  late bool active;
  String? taxId;
  late bool hasPicture;
  String? table;
  late String color;
  late int businessId;
  late int branchId;
  String? supplierId;
  String? categoryId;
  String? createdAt;
  String? unit;
  bool? draft;
  bool? imageLocal;
  bool? currentUpdate;
  String? imageUrl;
  String? expiryDate;
  String? barCode;
  bool? synced;
  final variants = IsarLinks<VariantSync>();
}
