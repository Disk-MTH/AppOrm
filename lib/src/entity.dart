import "package:app_orm/src/annotations.dart";
import "package:app_orm/src/identifiable.dart";
import "package:app_orm/src/permission.dart";

abstract class Entity<T> extends Identifiable<T> {
  @OrmNative($prefix: true)
  String databaseId = "";

  @OrmNative($prefix: true)
  String collectionId = "";

  //TODO: review this
  @OrmNative($prefix: true)
  List<Permission> permissions = [];

  Entity.empty() : super.empty();
}
