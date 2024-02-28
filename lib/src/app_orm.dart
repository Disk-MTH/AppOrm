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

  Future<void> setup({bool preLoadSkeleton = true}) async {
    logger.debug("Setting up AppOrm...");

    deserialize((await databases.get(databaseId: _databaseId)).toMap());

    logger.debug("AppOrm mapped to: {}", args: [id]);

    if (preLoadSkeleton) await loadSkeleton();
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

  Future<List<T>> list<T extends Entity>({
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
      final data = document.data;

      for (var key in List<String>.from(data.keys)) {
        if (key.contains("_ORMID_")) {
          final List<String> fieldData = key.split("_ORMID_");

          if (data[key] is List) {
            data[fieldData.first] = [];
            for (var id in data[key]) {
              data[fieldData.first].add(
                (await _listDocuments(fieldData.last, ids: [id]))[0].data,
              );
            }
          } else {
            data[fieldData.first] =
                (await _listDocuments(fieldData.last, ids: [data[key]]))[0]
                    .data;
          }
        }
      }

      entities.add(
        Reflection.instantiate(T, constructor: "empty").deserialize(data),
      );
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
}
