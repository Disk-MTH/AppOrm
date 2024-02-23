import "package:app_orm/src/logger.dart";
import "package:app_orm/src/repository.dart";
import "package:app_orm/src/utils.dart";
import "package:dart_appwrite/dart_appwrite.dart";
import "package:dart_appwrite/models.dart";

import "annotations.dart";
import "entity.dart";
import "identifiable.dart";

class AppOrm extends Identifiable {
  @OrmNative()
  late final String name;

  @OrmNative()
  late final bool enabled;

  final Databases databases;
  final AbstractLogger logger;

  final String _databaseId;
  final List<Repository> _repositories = [];

  AppOrm(this._databaseId, this.databases, {this.logger = const DummyLogger()});

/*  static Future<AppOrm> create(
    Databases databases,
    String databaseId, [
    AbstractLogger? logger,
    DataStorage? data,
  ]) async {
    return AppOrm._(
      logger ?? DummyLogger(),
      databases,
      data ?? Memory(),
      await databases.get(databaseId: databaseId),
    );
  }*/

/*  Future<Repository<T>> register<T extends Entity>(
      Repository<T> repository) async {
    data.register(repository);
    return repository;
  }*/

  Future<void> setup(List<Repository> repositories) async {
    initialize(await databases.get(databaseId: _databaseId));

    logger.debug("Initializing entity manager: $id");

    final List<Collection> collections = await databases
        .listCollections(databaseId: id)
        .then((value) => value.collections);

    logger.debug("Collections found: {}", args: [collections.length]);

    for (var repository in repositories) {
      repository.initialize(
        collections.firstWhere((e) => e.name == repository.type.toString()),
      );
      Reflection.setFieldValue(repository, this, name: "appOrm");

      logger.debug(
        "Repository mapped: {} with {}",
        args: [repository.name, repository.id],
      );
      _repositories.add(repository);
    }
  }

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

  Repository<T> getRepository<T extends Entity>() {
    final Repository<T>? repository = _repositories
        .where(
          (e) => e.type == T,
        )
        .firstOrNull as Repository<T>?;

    if (repository == null) {
      throw "Repository not found for type \"$T\"";
    }

    return repository;
  }
}
