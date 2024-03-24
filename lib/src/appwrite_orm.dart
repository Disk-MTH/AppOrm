import "package:app_orm/src/repository.dart";
import "package:app_orm/src/utils/database_utils.dart";
import "package:collection/collection.dart";
import "package:dart_appwrite/dart_appwrite.dart";
import "package:dart_appwrite/models.dart";

import "attribute.dart" as models;
import "identifiable.dart";
import "index.dart" as models;
import "orm.dart";
import "permission.dart" as models;
import "utils/enums.dart";

class AppwriteOrm extends Identifiable {
  @Orm(AttributeType.native)
  late final String name;

  @Orm(AttributeType.native)
  late final bool enabled;

  final Databases appwriteDB;
  final List<Repository> _skeleton = [];

  AppwriteOrm(this.appwriteDB, this.name, {this.enabled = true});

  //TODO: Create better migrations
  Future<void> setup(
    List<Repository> skeleton, {
    bool sync = false,
  }) async {
    logger.debug(
      "Appwrite ORM setup. Migrate mode: {}",
      args: [sync],
    );

    _skeleton.clear();

    if (await _checkDatabase(sync)) {
      final List<Collection> collections = await DatabaseUtils.listCollections(
        this,
      );

      for (var repository in skeleton) {
        if (await _checkRepository(
          collections.firstWhereOrNull((e) => e.name == repository.name),
          repository,
          sync,
        )) _skeleton.add(repository);
      }
    }

    if (_skeleton.isEmpty) {
      throw "Skeleton mismatch, please sync it to the database";
    } else {
      logger.debug(
        "Skeleton loaded: {}",
        args: [_skeleton.map((e) => e.name)],
      );
    }
  }

  Future<bool> _checkDatabase(bool sync) async {
    final Database? database = (await DatabaseUtils.listDatabases(this))
        .where((e) => e.name == name)
        .firstOrNull;

    if (database == null) {
      logger.warn("Database \"{}\" not found", args: [name]);
      if (sync && await DatabaseUtils.createDatabase(this)) return true;
      return false;
    }

    id = database.$id;
    createdAt = database.$createdAt;
    updatedAt = database.$updatedAt;
    return true;
  }

  Future<bool> _checkRepository(
    Collection? collection,
    Repository repository,
    bool sync,
  ) async {
    repository.databaseId = id;

    if (collection == null) {
      logger.warn(
        "Collection \"{}\" not found in database \"{}\"",
        args: [repository.name, name],
      );

      if (sync && await DatabaseUtils.createCollection(this, repository)) {
        return true;
      }

      return false;
    }

    repository.id = collection.$id;
    repository.createdAt = collection.$createdAt;
    repository.updatedAt = collection.$updatedAt;

    if (!DeepCollectionEquality.unordered().equals(
      repository.serialize(),
      {
        "id": collection.$id,
        "createdAt": collection.$createdAt,
        "updatedAt": collection.$updatedAt,
        "databaseId": collection.databaseId,
        "name": collection.name,
        "documentSecurity": collection.documentSecurity,
        "enabled": collection.enabled,
        "attributes": collection.attributes
            .map((e) => models.Attribute.fromModel(e).serialize())
            .toList(),
        "permissions": collection.$permissions
            .map((e) => models.Permission.fromModel(e).serialize())
            .toList(),
        "indexes": collection.indexes
            .map((e) => models.Index.fromModel(e.toMap()).serialize())
            .toList(),
      },
    )) {
      logger.warn(
        "Collection \"{}\" has differences with the skeleton",
        args: [repository.name],
      );

      final newRepository = Repository.orm({
        "databaseId": repository.databaseId,
        "name": repository.name,
        "documentSecurity": repository.documentSecurity,
        "enabled": repository.enabled,
        "attributes": repository.attributes,
        "permissions": repository.permissions,
        "indexes": repository.indexes,
      });

      if (sync &&
          await DatabaseUtils.deleteCollection(this, collection.$id) &&
          await DatabaseUtils.createCollection(this, newRepository)) {
        repository = newRepository;
        return true;
      }

      return false;
    }

    return true;
  }

  /*Future<List<T>> pull<T extends Entity>({
    List<String> ids = const [],
  }) async {
    final Repository? repository = getRepository(type: T);
    if (repository == null) {
      throw "Repository not found for type: $T";
    }

    logger.debug("Listing {}: {}", args: [T, ids.isEmpty ? "all" : ids]);

    final List<T> entities = [];
    final List<Document> documents = await DatabaseUtils.listDocuments(
      this,
      repository,
      ids: ids,
    );

    for (var document in documents) {
      final T entity =
          Reflection.instantiate(T, constructor: "orm").fromMap(document.data);

      await _fetchEntity(entity, []);
      entities.add(entity);
    }

    return entities;
  }

  Future<bool> push(Entity entity) async {
    final Repository? repository = getRepository(entity: entity);
    if (repository == null) {
      throw "Repository not found for type: ${entity.runtimeType}";
    }

    logger.debug("Pushing {}", args: [entity.runtimeType]);

    return await DatabaseUtils.createDocument(
      this,
      repository,
      entity,
    );
  }*/

  // get skeleton => _skeleton;

/*  Repository? getRepository({String? typeName, Type? type, Entity? entity}) {
    if ((typeName == null && type == null && entity == null) ||
        (typeName != null && type != null && entity != null)) {
      throw "You must provide either a typeName, a type or an entity";
    }

    if (type != null) typeName = type.toString();
    if (entity != null) typeName = entity.runtimeType.toString();

    return _skeleton.where((e) => e.name == typeName).firstOrNull;
  }*/

  T? getRepository<T extends Repository>() {
    return _skeleton.whereType<T>().firstOrNull;
  }

/*Future<void> _fetchEntity(
    Identifiable origin,
    List<Identifiable> references,
  ) async {
    final fields = Reflection.listClassFields(origin.runtimeType);

    for (var name in fields.keys) {
      final mirror = fields[name]!;

      final InstanceMirror? metadata = mirror.metadata
          .where(
            (e) =>
                e.reflectee is Orm && e.reflectee.type == AttributeType.entity,
          )
          .firstOrNull;

      if (metadata == null) continue;

      metadata.reflectee.validate();
      final String keyName = "${name}_ORMID";

      if (metadata.reflectee.modifiers[Modifier.array] == true) {
        final refList = Reflection.getField(origin, name);

        for (var foreignKey in origin.foreignKeys[keyName]!) {
          if (references.any((e) => e.id == foreignKey)) {
            refList.add(references.firstWhere((e) => e.id == foreignKey));
          } else {
            await _test(
              origin,
              references,
              mirror.type.typeArguments.first.reflectedType,
              foreignKey,
            );
          }
        }
      } else {
        final String foreignKey = origin.foreignKeys[keyName]!.first;

        if (references.any((e) => e.id == foreignKey)) {
          Reflection.setFieldValue(
            origin,
            references.firstWhere((e) => e.id == foreignKey),
            mirror: mirror,
          );
        } else {
          await _test(
            origin,
            references,
            mirror.type.reflectedType,
            foreignKey,
          );
        }
      }
    }
  }*/

//TODO rename
/*Future<void> _test(
    Identifiable origin,
    List<Identifiable> references,
    Type type,
    String foreignKey,
  ) async {
    final repository = getRepository(type: type)!;
    final data = (await DatabaseUtils.listDocuments(
      this,
      repository,
      ids: [foreignKey],
    ))
        .first
        .data;

    final entity = Reflection.instantiate(
      type,
      constructor: "orm",
    ).deserialize(data);

    await _fetchEntity(entity, [origin, ...references]);
    await _fetchEntity(origin, [entity, ...references]);
  }*/
}

/*repository.databaseId = id;

      final Map<String, dynamic> collection = collections
              .where((e) => e.name == repository.name)
              .firstOrNull
              ?.toMap() ??
          {};

      if (collection.isEmpty) {
        logger.warn(
          "Collection \"{}\" not found in database \"{}\"",
          args: [repository.name, name],
        );

        if (sync && await DatabaseUtils.createCollection(this, repository)) {
          _skeleton.add(repository);
        }
        continue;
      }

      repository.id = collection["\$id"];
      repository.createdAt = collection["\$createdAt"];
      repository.updatedAt = collection["\$updatedAt"];

      if (repository != Repository.fromMap(collection)) {
        logger.warn(
          "Collection \"{}\" has differences with the skeleton",
          args: [repository.name],
        );

        //TODO: change by fromMap
        final newRepository = Repository.fromExisting(repository);
        if (sync &&
            await DatabaseUtils.deleteCollection(this, collection["id"]) &&
            await DatabaseUtils.createCollection(this, newRepository)) {
          _skeleton.add(newRepository);
        }
        continue;
      }

      _skeleton.add(repository);*/

/*    for (var collection in collections) {
      if (_skeleton.any((e) => e.name == collection.name)) continue;

      logger.warn(
        "Collection \"{}\" is present in the database but not in the skeleton",
        args: [collection.name],
      );

      if (sync) await DatabaseUtils.deleteCollection(this, collection.$id);
    }*/
