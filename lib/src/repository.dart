import "package:app_orm/src/attribute.dart";
import "package:app_orm/src/identifiable.dart";
import "package:app_orm/src/index.dart";
import "package:app_orm/src/permission.dart";

import "enums.dart";
import "orm.dart";

class Repository extends Identifiable {
  @Orm(AttributeType.string, modifiers: {
    Modifier.isRequired: true,
    Modifier.size: 20,
  })
  String databaseId = "";

  @Orm(AttributeType.string, modifiers: {Modifier.isRequired: true})
  String name = "";

  @Orm(AttributeType.boolean, modifiers: {Modifier.isRequired: true})
  bool enabled = false;

  @Orm(AttributeType.boolean, modifiers: {Modifier.isRequired: true})
  bool documentSecurity = false;

  @Orm(AttributeType.native, modifiers: {Modifier.isArray: true})
  List<Permission> permissions = [];

  @Orm(AttributeType.native, modifiers: {Modifier.isArray: true})
  List<Attribute> attributes = [];

  @Orm(AttributeType.native, modifiers: {Modifier.isArray: true})
  List<Index> indexes = [];

  Repository(Map<String, dynamic> data) : super.empty() {
    deserialize(data);
  }
}
