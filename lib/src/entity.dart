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

/*  //TODO: patch
  @Orm(AttributeType.boolean, modifiers: {Modifier.isRequired: true})
  bool enabled = false;

  //TODO: patch
  @Orm(AttributeType.boolean, modifiers: {Modifier.isRequired: true})
  bool documentSecurity = false;*/

  @Orm(AttributeType.native, modifiers: {Modifier.isArray: true})
  List<Permission> permissions = [];

/*  //TODO: patch
  @Orm(AttributeType.native, modifiers: {Modifier.isArray: true})
  List<Attribute> attributes = [];

  //TODO: patch
  @Orm(AttributeType.native, modifiers: {Modifier.isArray: true})
  List<Index> indexes = [];*/

  Entity.empty() : super.empty();
}
