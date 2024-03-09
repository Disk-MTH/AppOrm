import "package:app_orm/src/identifiable.dart";
import "package:app_orm/src/orm.dart";
import "package:app_orm/src/permission.dart";

import "enums.dart";

abstract class Entity<T> extends Identifiable<T> {
  @Orm(AttributeType.string, modifiers: {
    Modifier.isRequired: true,
    Modifier.size: 20,
  })
  String databaseId = "";

  @Orm(AttributeType.string, modifiers: {
    Modifier.isRequired: true,
    Modifier.size: 20,
  })
  String collectionId = "";

  @Orm(AttributeType.native, modifiers: {Modifier.isArray: true})
  List<Permission> permissions = [];

  Entity.empty() : super.empty();
}
