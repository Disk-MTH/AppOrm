import "dart:mirrors";

import "package:app_orm/src/entity.dart";
import "package:app_orm/src/utils.dart";
import "package:dart_appwrite/dart_appwrite.dart";
import "package:dart_appwrite/models.dart";

import "annotations.dart";
import "identifiable.dart";

class AppOrm extends Identifiable<AppOrm> {
  @OrmNative()
  late String? name;

  @OrmNative()
  late bool? enabled;

  final Databases databases;

  final String _databaseId;
  final Map<String, String> _collections = {};

  AppOrm(this._databaseId, this.databases) : super.empty();

  Future<void> setup({bool preloadSkeleton = true}) async {
    logger.debug("Setting up AppOrm...");

    deserialize((await databases.get(databaseId: _databaseId)).toMap());

    logger.debug("AppOrm mapped to: {}", args: [id]);

    if (preloadSkeleton) await loadSkeleton();
  }

  Future<void> loadSkeleton() async {
    _collections.clear();

    await databases.listCollections(databaseId: id!).then((value) {
      for (var collection in value.collections) {
        _collections[collection.name] = collection.$id;
      }
    });

    logger.debug(
      "{} collections found: {}",
      args: [_collections.length, _collections.keys],
    );
  }

  Future<List<T>> pull<T extends Entity>({
    bool loadArchitecture = false,
    List<String> ids = const [],
  }) async {
    logger.debug("Listing {}: {}", args: [T, ids.isEmpty ? "all" : ids]);

    final List<T> entities = [];
    final List<Document> documents = await _listDocuments(
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

  Future<List<Document>> _listDocuments(
    String typeName, {
    List<String> ids = const [],
  }) {
    if (!_collections.containsKey(typeName)) {
      throw "Collection not found for type \"$typeName\"";
    }

    logger.debug(
      "Retrieving documents for {}: {}",
      args: [typeName, ids.isEmpty ? "all" : ids],
    );

    return databases.listDocuments(
      databaseId: id!,
      collectionId: _collections[typeName]!,
      queries: [
        if (ids.isNotEmpty) Query.equal("\$id", ids),
      ],
    ).then((value) => value.documents);
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

      name = "${name.substring(1)}_ORMID";

      if (references.any((e) => e.id == origin.foreignKeys[name])) {
        Reflection.setFieldValue(
          origin,
          references.firstWhere((e) => e.id == origin.foreignKeys[name]),
          mirror: mirror,
        );
      } else {
        final data = (await _listDocuments(
          mirror.type.reflectedType.toString(),
          ids: [origin.foreignKeys[name]!],
        ))[0]
            .data;

        final entity = Reflection.instantiate(
          mirror.type.reflectedType,
          constructor: "empty",
        ).deserialize(data);

        await _fetchEntity(entity, [origin, ...references]);
        await _fetchEntity(origin, [entity, ...references]);
      }
    }
  }
}
