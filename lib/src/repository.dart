import "dart:mirrors";

import "package:app_orm/src/attribute.dart";
import "package:app_orm/src/identifiable.dart";
import "package:app_orm/src/index.dart";
import "package:app_orm/src/permission.dart";
import "package:app_orm/src/utils/reflection.dart";
import "package:app_orm/src/utils/serializable.dart";

import "entity.dart";
import "orm.dart";
import 'utils/enums.dart';

class Repository<T extends Entity> extends Identifiable<Repository<T>> {
  @Orm(AttributeType.native)
  late String databaseId;

  @Orm(AttributeType.native)
  late String name;

  @Orm(AttributeType.native)
  late bool documentSecurity;

  @Orm(AttributeType.native)
  late bool enabled;

  @Orm(AttributeType.native, modifiers: {Modifier.array: true})
  late List<Attribute> attributes;

  @Orm(AttributeType.native, modifiers: {Modifier.array: true})
  late List<Permission> permissions;

  @Orm(AttributeType.native, modifiers: {Modifier.array: true})
  late List<Index> indexes;

  Repository({
    this.documentSecurity = false,
    this.enabled = true,
    this.permissions = const [],
    this.indexes = const [],
  }) : super.empty() {
    name = T.toString();
    attributes = [];
    //TODO: use new method to select annotation
    Reflection.listClassFields(T).forEach((name, mirror) {
      final InstanceMirror? metadata = mirror.metadata
          .where((e) =>
              e.reflectee is Orm && e.reflectee.type != AttributeType.native)
          .firstOrNull;
      if (metadata == null) {
        return;
      }
      final Orm orm = metadata.reflectee;
      attributes.add(Attribute(
        name,
        orm.type,
        modifiers: Map.from(orm.modifiers),
      ));
    });
  }

  Repository.fromMap(Map<String, dynamic> data) : super.empty() {
    attributes = [];
    permissions = [];
    indexes = [];
    fromMap(data);
  }

  @override
  bool equals(Serializable other) {
    return other is Repository &&
        super.equals(other) &&
        other.databaseId == databaseId &&
        other.name == name &&
        other.documentSecurity == documentSecurity &&
        other.enabled == enabled &&
        other.attributes.length == attributes.length &&
        !other.attributes.any((o) => !attributes.any((e) => o.equals(e))) &&
        other.permissions.length == permissions.length &&
        !other.permissions.any((o) => !permissions.any((e) => o.equals(e))) &&
        other.indexes.length == indexes.length &&
        !other.indexes.any((o) => !indexes.any((e) => o.equals(e)));
  }
}
