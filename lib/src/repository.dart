import "dart:mirrors";

import "package:app_orm/src/attribute.dart";
import "package:app_orm/src/identifiable.dart";
import "package:app_orm/src/index.dart";
import "package:app_orm/src/permission.dart";
import "package:app_orm/src/utils/reflection.dart";
import "package:app_orm/src/utils/serializable.dart";

import "orm.dart";
import 'utils/enums.dart';

class Repository extends Identifiable<Repository> {
  @Orm(AttributeType.native)
  late final String databaseId;

  @Orm(AttributeType.native)
  late final String name;

  @Orm(AttributeType.native)
  late final bool documentSecurity;

  @Orm(AttributeType.native)
  late final bool enabled;

  @Orm(AttributeType.native, modifiers: {Modifier.array: true})
  final List<Attribute> attributes = [];

  @Orm(AttributeType.native, modifiers: {Modifier.array: true})
  final List<Permission> permissions = [];

  @Orm(AttributeType.native, modifiers: {Modifier.array: true})
  final List<Index> indexes = [];

  Repository(
    Type type, {
    this.documentSecurity = false,
    this.enabled = true,
    permissions = const [],
    indexes = const [],
  }) {
    name = type.toString();
    Reflection.listClassFields(type).forEach((name, mirror) {
      final InstanceMirror? metadata = mirror.metadata
          .where((e) =>
              e.reflectee is Orm && e.reflectee.type != AttributeType.native)
          .firstOrNull;

      if (metadata == null) return;

      final Orm orm = metadata.reflectee;
      attributes.add(Attribute(
        name,
        orm.type,
        modifiers: Map.from(orm.modifiers),
      ));
    });
    this.permissions.addAll(permissions);
    this.indexes.addAll(indexes);
  }

  Repository.fromMap(Map<String, dynamic> data) {
    fromMap(data);
  }

  //TODO remove, replaced by fromMap
  Repository.fromExisting(Repository repository) {
    databaseId = repository.databaseId;
    name = repository.name;
    documentSecurity = repository.documentSecurity;
    enabled = repository.enabled;
    attributes.addAll(repository.attributes);
    permissions.addAll(repository.permissions);
    indexes.addAll(repository.indexes);
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
