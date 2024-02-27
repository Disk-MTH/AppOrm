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

  Future<void> setup() async {
    deserialize((await databases.get(databaseId: _databaseId)).toMap());

    logger.debug("Initializing entity manager: {}", args: [id]);

    await databases.listCollections(databaseId: id!).then((value) {
      for (var collection in value.collections) {
        _collections[collection.name] = collection.$id;
      }
    });

    logger.debug("Collections found: {}", args: [_collections.length]);
  }

  Future<List<T>> list<T extends Entity>({
    Type? type,
    List<String> ids = const [],
  }) async {
    if (type != null && type != T) {
      throw "Type and generic type mismatch";
    }

    type ??= T;

    logger.debug("Listing {}: {}", args: [type, ids.isEmpty ? "all" : ids]);

    final List<T> entities = [];
    final List<Document> documents = await listDocuments(
      type.toString(),
      ids: ids,
    );

    for (var document in documents) {
      final data = document.data;

      for (var key in List<String>.from(data.keys)) {
        if (key.contains("_ORMID_")) {
          final List<String> fieldData = key.split("_ORMID_");

          data[fieldData.first] =
              (await listDocuments(fieldData.last, ids: [data[key]]))[0].data;
        }
      }

      entities.add(
        Reflection.instantiate(T, constructor: "empty").deserialize(data),
      );
    }

    return entities;
  }

  Future<List<Document>> listDocuments(
    String typeName, {
    List<String> ids = const [],
  }) {
    if (!_collections.containsKey(typeName)) {
      throw "Collection not found for type \"$typeName\"";
    }

    logger.debug(
      "Listing documents for {}: {}",
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

/*  Future<T> get<T extends Entity>(String id) async {
    if (!_collections.containsKey(T.toString())) {
      throw "Collection not found for type \"$T\"";
    }

    logger.debug("Getting $T: $id");

    final Document document = await databases.getDocument(
      databaseId: this.id!,
      collectionId: _collections[T.toString()]!,
      documentId: id,
    );

    print("###########");
    print(document.data["documents"]);

    return Reflection.instantiate<T>(constructor: "empty")
        .deserialize(document.data);
  }*/

  /*Future<void> pull() async {
    logger.debug("Pulling data...");

    final Map<Type, List<Document>> documentsByType = {};
    final Map<String, Entity> entitiesById = {};

    for (var repository in _repositories) {
      final List<Document> documents = await databases
          .listDocuments(databaseId: id, collectionId: repository.id)
          .then((value) => value.documents);

      documentsByType[repository.type] = documents;

      logger.debug(
        "Documents found for {}: {}",
        args: [repository.type.toString(), documents.length],
      );
      logger.debug(
        "Instantiating {} {}",
        args: [documents.length, repository.type],
      );

      for (var document in documents) {
        final Entity entity = Reflection.instantiate<Entity>(args: [document]);
        repository.add(entity);
        entitiesById[entity.id] = entity;
      }
    }

    for (var entity in entitiesById.values) {
      Reflection.listClassFields(entity.runtimeType).forEach((name, mirror) {
        final InstanceMirror? metadata = mirror.metadata
            .where((e) => e.reflectee is OrmAttribute)
            .firstOrNull;

        if (metadata == null) return;

        final OrmAttribute annotation = metadata.reflectee;
        annotation.validate();

        if (annotation.runtimeType == OrmEntity) {
          final String? refDocId = documentsByType[entity.runtimeType]!
              .where((e) => e.$id == entity.id)
              .firstOrNull
              ?.data["orm${mirror.type.reflectedType}Id"];

          final Document? refDoc = documentsByType[mirror.type.reflectedType]!
              .where((e) => e.$id == refDocId)
              .firstOrNull;

          if (refDoc == null) {
            throw "Entity reference \"$name\" not found";
          }

          Reflection.setFieldValue(entity, mirror, entitiesById[refDoc.$id]!);
        }
      });
    }
  }
  }*/

/*  Repository<T> getRepository<T extends Entity>() {
    final Repository<T>? repository = _repositories
        .where(
          (e) => e.type == T,
        )
        .firstOrNull as Repository<T>?;

    if (repository == null) {
      throw "Repository not found for type \"$T\"";
    }

    return repository;
  }*/

/*  Repository getRepositoryByType(Type type) {
    final Repository? repository = _repositories
        .where(
          (e) => e.type == type,
        )
        .firstOrNull;

    if (repository == null) {
      throw "Repository not found for type \"$type\"";
    }

    return repository;
  }

  Repository<T> getRepository<T extends Entity>() {
    return getRepositoryByType(T) as Repository<T>;
  }*/
}
