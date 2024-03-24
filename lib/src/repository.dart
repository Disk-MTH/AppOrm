import "dart:mirrors";

import "package:app_orm/src/attribute.dart";
import "package:app_orm/src/entity.dart";
import "package:app_orm/src/identifiable.dart";
import "package:app_orm/src/index.dart";
import "package:app_orm/src/permission.dart";
import "package:app_orm/src/utils/reflection.dart";
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

  Repository.orm(super.data) : super.orm();

  T init(T entity) {
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
