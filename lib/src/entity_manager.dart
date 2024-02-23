import "package:app_orm/src/logger.dart";
import "package:app_orm/src/repository.dart";
import "package:dart_appwrite/dart_appwrite.dart";
import "package:dart_appwrite/models.dart";

import "annotations.dart";
import "entity.dart";
import "identifiable.dart";

class EntityManager extends Identifiable {
  @OrmNative()
  late final String name;

  @OrmNative()
  late final bool enabled;

  final AbstractLogger logger;
  final Databases databases;

  final Map<Type, Repository> _repositories = {};

  EntityManager._(
    this.databases,
    super.model, [
    AbstractLogger? logger,
  ]) : logger = logger ?? DummyLogger();

  static Future<EntityManager> create(
    Databases databases,
    String databaseId, [
    AbstractLogger? logger,
  ]) async {
    return EntityManager._(
      databases,
      await databases.get(databaseId: databaseId),
      logger ?? DummyLogger(),
    );
  }

  Future<Repository<T>> getRepository<T extends Entity>() async {
    Repository<T>? repository = _repositories[T] as Repository<T>?;

    if (repository == null) {
      final List<Collection> collections = await databases
          .listCollections(databaseId: id)
          .then((value) => value.collections);

      repository = Repository<T>(
        this,
        collections.where((e) => e.name == T.toString()).first,
      );
      _repositories[T] = repository;
    }

    return repository;
  }

  void tempLog() {
    print('Temp log: ${_repositories.length}');
    for (var key in _repositories.keys) {
      print('Key: $key, Value: ${_repositories[key]?.toMap()}');
    }
  }

/*  List<Type> findEntities() {
    final entities = <Type>[];

    currentMirrorSystem().libraries.forEach((key, value) {
      value.declarations.forEach((key, value) {
        bool isAnnotationPresent = value.metadata.any((element) {
          return element.type.reflectedType == OrmEntity;
        });

        logger.log("Class: $key, isAnnotationPresent: $isAnnotationPresent");
      });
    });

    return entities;
  }*/

/*  Repository<T> getRepository<T extends Entity>() {
    final repository = Repository<T>(this, id: '');
    _repositories.add(repository);
    return repository;
    //TODO return new or existing repository
  }*/

/*Future<void> initialize(List<Type> entities) async {
    logger.debug("Initializing entity manager: $id");

    for (var type in entities) {
      if (!Reflection.isSubtype<Entity>(type)) {
        throw "Type \"$type\" is not an Entity";
      }
      logger.debug("Entity found: {}", args: [type]);
      _entityTypes.add(type);
    }

    final List<Collection> collections = await _databases
        .listCollections(databaseId: id)
        .then((value) => value.collections);

    logger.debug("Collections found: {}", args: [collections.length]);

    for (var collection in collections) {
      final Type? entityType = _entityTypes.where((type) {
        return type.toString() == collection.name;
      }).firstOrNull;

      if (entityType != null) {
        logger.debug(
          "Repository mapped: {} with {}",
          args: [collection.name, collection.$id],
        );
        _repositories.add(Repository(entityType, collection));
      } else {
        logger.debug(
          "No entity for collection: {} - {}",
          args: [collection.name, collection.$id],
        );
      }
    }
  }*/

/*Future<void> pull() async {
    logger.debug("Pulling data...");

    final Map<Type, List<Document>> documentsByType = {};
    final Map<String, Entity> entitiesById = {};

    for (var repository in _repositories) {
      final List<Document> documents = await _databases
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
        final Entity entity = Reflection.instantiate(
          repository.type,
          args: [document],
        );
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
          print('######');

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
  }*/
}
