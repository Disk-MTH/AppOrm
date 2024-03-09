import "package:app_orm/src/attribute.dart";
import "package:app_orm/src/identifiable.dart";
import "package:app_orm/src/index.dart";
import "package:app_orm/src/permission.dart";

import "annotations.dart";
import "enums.dart";

class Repository extends Identifiable {
  @OrmTest(AttributeType.string)
  String databaseId = "";

  @OrmTest(AttributeType.string)
  String name = "";

  @OrmTest(AttributeType.boolean)
  bool enabled = false;

  @OrmTest(AttributeType.boolean)
  bool documentSecurity = false;

  @OrmTest(AttributeType.native, modifiers: {Modifier.array: true})
  List<Permission> permissions = [];

  @OrmTest(AttributeType.native, modifiers: {Modifier.array: true})
  List<Attribute> attributes = [];

  @OrmTest(AttributeType.native, modifiers: {Modifier.array: true})
  List<Index> indexes = [];

  Repository(Map<String, dynamic> data) : super.empty() {
    deserialize(data);
  }
}
