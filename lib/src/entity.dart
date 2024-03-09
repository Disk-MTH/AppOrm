import "package:app_orm/src/annotations.dart";
import "package:app_orm/src/identifiable.dart";
import "package:app_orm/src/permission.dart";

import "enums.dart";

abstract class Entity<T> extends Identifiable<T> {
  @OrmTest(AttributeType.string)
  String databaseId = "";

  @OrmTest(AttributeType.string)
  String collectionId = "";

  @OrmTest(AttributeType.native, modifiers: {Modifier.array: true})
  List<Permission> permissions = [];

  Entity.empty() : super.empty();
}
