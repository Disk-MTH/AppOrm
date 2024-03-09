import "dart:mirrors";

import "package:app_orm/src/entity.dart";
import "package:app_orm/src/repository.dart";
import "package:app_orm/src/utils.dart";
import "package:dart_appwrite/dart_appwrite.dart";
import "package:dart_appwrite/models.dart";

import "annotations.dart";
import "enums.dart";
import "identifiable.dart";

class AppOrm extends Identifiable<AppOrm> {
  //@OrmNative()
  @OrmTest(AttributeType.string)
  String name = "";

  // @OrmNative()
  @OrmTest(AttributeType.boolean)
  bool enabled = false;

  final Databases databases;

  final String _databaseId;
  final Map<String, Repository> _skeleton = {};

  AppOrm(this._databaseId, this.databases) : super.empty();

  Future<void> setup({bool preloadSkeleton = true}) async {
    logger.debug("Setting up AppOrm...");

    deserialize((await databases.get(databaseId: _databaseId)).toMap());

    logger.debug("AppOrm mapped to: {}", args: [id]);

    if (preloadSkeleton) await loadSkeleton();
  }

  Future<void> loadSkeleton() async {
    _skeleton.clear();

    await databases.listCollections(databaseId: id).then((value) {
      for (var collection in value.collections) {
        _skeleton[collection.name] = Repository(collection.toMap());
      }
    });

    logger.debug(
      "{} collections found: {}",
      args: [_skeleton.length, _skeleton.keys],
    );
  }

  Future<List<T>> pull<T extends Entity>({
    bool loadArchitecture = false,
    List<String> ids = const [],
  }) async {
    logger.debug("Listing {}: {}", args: [T, ids.isEmpty ? "all" : ids]);

    final List<T> entities = [];
    final List<Document> documents = await Utils.listDocuments(
      this,
      T.toString(),
      ids: ids,
    );

    for (var document in documents) {
      final T entity = Reflection.instantiate(
        T,
        constructor: "empty",
      ).deserialize(document.data);

      await _fetchEntity(entity, []);
      entities.add(entity);
    }

    return entities;
  }

  List<Repository> get repositories => _skeleton.values.toList();

  Repository getRepository({String? typeName, Type? type, Entity? entity}) {
    if ((typeName == null && type == null && entity == null) ||
        (typeName != null && type != null && entity != null)) {
      throw "You must provide either a typeName, a type or an entity";
    }

    if (type != null) typeName = type.toString();
    if (entity != null) typeName = entity.runtimeType.toString();

    if (!_skeleton.containsKey(typeName)) {
      throw "Repository not found for type \"$typeName\"";
    }

    return _skeleton[typeName.toString()]!;
  }

  Future<void> _fetchEntity(
    Identifiable origin,
    List<Identifiable> references,
  ) async {
    final fields = Reflection.listClassFields(origin.runtimeType);

    for (var name in fields.keys) {
      final mirror = fields[name]!;

      final InstanceMirror? metadata = mirror.metadata
          .where((e) => e.reflectee is OrmEntity || e.reflectee is OrmEntities)
          .firstOrNull;

      if (metadata == null) continue;

      final OrmAttribute annotation = metadata.reflectee;
      annotation.validate();

      final String keyName = "${name}_ORMID";

      if (annotation is OrmEntity) {
        final String foreignKey = origin.foreignKeys[keyName]!.first;

        if (references.any((e) => e.id == foreignKey)) {
          Reflection.setFieldValue(
            origin,
            references.firstWhere((e) => e.id == foreignKey),
            mirror: mirror,
          );
        } else {
          final data = (await Utils.listDocuments(
            this,
            mirror.type.reflectedType.toString(),
            ids: [foreignKey],
          ))
              .first
              .data;

          final entity = Reflection.instantiate(
            mirror.type.reflectedType,
            constructor: "empty",
          ).deserialize(data);

          await _fetchEntity(entity, [origin, ...references]);
          await _fetchEntity(origin, [entity, ...references]);
        }
      } else {
        final refList = Reflection.getField(origin, name);

        for (var foreignKey in origin.foreignKeys[keyName]!) {
          if (references.any((e) => e.id == foreignKey)) {
            refList.add(references.firstWhere((e) => e.id == foreignKey));
          } else {
            final data = (await Utils.listDocuments(
              this,
              mirror.type.typeArguments.first.reflectedType.toString(),
              ids: [foreignKey],
            ))
                .first
                .data;

            final entity = Reflection.instantiate(
              mirror.type.typeArguments.first.reflectedType,
              constructor: "empty",
            ).deserialize(data);

            await _fetchEntity(entity, [origin, ...references]);
            await _fetchEntity(origin, [entity, ...references]);
          }
        }
      }
    }
  }
}
