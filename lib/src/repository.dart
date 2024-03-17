import "dart:mirrors";

import "package:app_orm/src/attribute.dart";
import "package:app_orm/src/entity.dart";
import "package:app_orm/src/identifiable.dart";
import "package:app_orm/src/index.dart";
import "package:app_orm/src/permission.dart";
import "package:app_orm/src/utils/reflection.dart";
import "package:app_orm/src/utils/serializable.dart";
import "package:app_orm/src/utils/utils.dart";

import "orm.dart";
import 'utils/enums.dart';

class Repository<T extends Entity> extends Identifiable {
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

  Repository({
    this.documentSecurity = false,
    this.enabled = true,
    permissions = const [],
    indexes = const [],
  }) {
    name = T.toString();
    Reflection.listClassFields(T).forEach((name, mirror) {
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
    for (var permission in permissions) {
      this.permissions.add(permission);
    }
    for (var index in indexes) {
      this.indexes.add(index);
    }
  }

  Repository.fromMap(Map<String, dynamic> data) {
    deserialize(data);
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

  T instantiate(T entity) {
    entity.id = Utils.uniqueId();
    entity.createdAt = DateTime.now().toIso8601String();
    entity.updatedAt = entity.createdAt;
    entity.databaseId = databaseId;
    entity.collectionId = id;
    return entity;
  }

  Future<List<T>> findAll() async {
    return [];
  }
}
