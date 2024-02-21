import "package:app_orm/src/entity.dart";
import "package:app_orm/src/logger.dart";
import "package:app_orm/src/repository.dart";
import "package:app_orm/src/utils.dart";
import "package:dart_appwrite/dart_appwrite.dart";
import "package:dart_appwrite/models.dart";

import "identifiable.dart";

class EntityManager extends Identifiable {
  final AbstractLogger logger;
  final Client _client;
  final Databases _databases;

  final List<Type> _entityTypes = [];
  final List<Repository> _repositories = [];

  EntityManager(
    this._client,
    String databaseId, [
    AbstractLogger? logger,
  ])  : logger = logger ?? Logger(),
        _databases = Databases(_client),
        super(Database(
          $id: databaseId,
          name: "",
          $createdAt: "",
          $updatedAt: "",
          enabled: true,
        ));

  // super(id: databaseId);

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

  Future<void> initialize(List<Type> entities) async {
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
  }

  Future<void> pull() async {
    logger.debug("Pulling data...");
    for (var repository in _repositories) {
      final List<Document> documents = await _databases
          .listDocuments(databaseId: id, collectionId: repository.id)
          .then((value) => value.documents);

      logger.debug(
        "Documents found for {}: {}",
        args: [repository.type.toString(), documents.length],
      );

      for (var document in documents) {
        repository.add(Reflection.instantiate(
          repository.type,
          args: [document],
        ));
      }

      logger.log(repository.list());
      //print(repository.toMap());
    }
  }

// Future<void> sync() {}

/*  void pushModel(List<Type> entities) {
    for (var type in entities) {
      if (!Reflection.isSubtype<Entity>(type)) {
        throw "Type \"$type\" is not an Entity";
      }

      final fields = Reflection.fieldsFromClass(type);

      fields.forEach((key, value) {
        for (var annotation in value.metadata) {
          switch (annotation.type.reflectedType) {
            case const (OrmString):
              print("StringAttribute");
              break;
            default:
              throw "Unknown annotation";
          }
        }
      });
    }
  }*/
}
