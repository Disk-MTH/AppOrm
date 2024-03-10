import "dart:mirrors";

import "package:app_orm/src/attribute.dart";
import "package:app_orm/src/identifiable.dart";
import "package:app_orm/src/index.dart";
import "package:app_orm/src/permission.dart";
import "package:app_orm/src/utils.dart";

import "entity.dart";
import "enums.dart";
import "orm.dart";

class Repository<T extends Entity> extends Identifiable<Repository<T>> {
  @Orm(AttributeType.string, modifiers: {
    Modifier.isRequired: true,
    Modifier.size: 20,
  })
  late String databaseId;

  @Orm(AttributeType.string, modifiers: {Modifier.isRequired: true})
  late String name;

  @Orm(AttributeType.boolean, modifiers: {Modifier.isRequired: true})
  late bool documentSecurity;

  @Orm(AttributeType.boolean, modifiers: {Modifier.isRequired: true})
  late bool enabled;

  @Orm(AttributeType.native, modifiers: {Modifier.isArray: true})
  late List<Attribute> attributes;

  @Orm(AttributeType.native, modifiers: {Modifier.isArray: true})
  late List<Permission> permissions;

  @Orm(AttributeType.native, modifiers: {Modifier.isArray: true})
  late List<Index> indexes;

  // List<T> entities = [];

  Repository({
    this.documentSecurity = false,
    this.enabled = true,
    this.permissions = const [],
    this.indexes = const [],
  }) : super.empty() {
    name = T.toString();
    attributes = [];
    Reflection.listClassFields(T).forEach((name, mirror) {
      final InstanceMirror? metadata = mirror.metadata
          .where(
            (e) => e.reflectee is Orm,
          )
          .firstOrNull;
      if (metadata == null) {
        return;
      }
      final Orm orm = metadata.reflectee;
      attributes.add(Attribute(name, orm.type, modifiers: orm.modifiers));
    });
  }

  Repository.fromMap(Map<String, dynamic> data) : super.empty() {
    attributes = [];
    permissions = [];
    indexes = [];
    deserialize(data);
  }
}
