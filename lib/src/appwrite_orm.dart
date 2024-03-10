import "dart:mirrors";

import "package:app_orm/src/entity.dart";
import "package:app_orm/src/repository.dart";
import "package:app_orm/src/utils/database_utils.dart";
import "package:app_orm/src/utils/reflection.dart";
import "package:app_orm/src/utils/utils.dart";
import "package:dart_appwrite/dart_appwrite.dart";
import "package:dart_appwrite/models.dart";

import "identifiable.dart";
import "orm.dart";
import 'utils/enums.dart';

class AppwriteOrm extends Identifiable<AppwriteOrm> {
  @Orm(AttributeType.native)
  String name = "";

  @Orm(AttributeType.native)
  bool enabled = false;

  final Databases databases;
  final List<Repository> _skeleton = [];

  AppwriteOrm(String databaseId, this.databases) : super.empty() {
    id = databaseId;
  }

  Future<void> setup(
    List<Repository> skeleton, {
    bool sync = false,
    bool clean = false,
  }) async {
    logger.debug("Appwrite ORM setup ${sync ? "with" : "without"} sync mode");

    fromMap((await databases.get(databaseId: id)).toMap());

    logger.debug("Mapped to database \"{}\"", args: [name]);
    _skeleton.clear();

    final List<Collection> collections = await databases
        .listCollections(databaseId: id)
        .then((value) => value.collections);

    for (var repository in skeleton) {
      repository.databaseId = id;

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

      if (!repository.equals(Repository.fromMap(collection))) {
        logger.warn(
          "Collection \"{}\" has differences with the skeleton",
          args: [repository.name],
        );

        if (!sync && await DatabaseUtils.updateCollection(this, repository)) {
          _skeleton.add(repository);
        }
        continue;
      }

      _skeleton.add(repository);
    }

    for (var collection in collections) {
      if (_skeleton.any((e) => e.name == collection.name)) continue;

      logger.warn(
        "Collection \"{}\" is present in the database but not in the skeleton",
        args: [collection.name],
      );

      if (clean) await DatabaseUtils.deleteCollection(this, collection.$id);
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

  get skeleton => _skeleton;

  /*Future<void> loadSkeleton(List<Type> skeleton) async {
    logger.debug("Loading skeleton...");

    final List<Repository> userSkeleton = [];

    for (var type in skeleton) {
      if (!Reflection.isSubtype(type, Entity)) {
        throw "Type $type is not a subtype of Entity";
      }
      // userSkeleton.add(Repository(type));
    }

    _skeleton.clear();
    _skeleton.addAll(userSkeleton);

    logger.debug("User skeleton loaded: {}", args: [_skeleton]);

    */ /*  _skeleton.clear();

    await databases.listCollections(databaseId: id).then((value) {
      for (var collection in value.collections) {
        _skeleton[collection.name] = Repository(collection.toMap());
      }
    });

    logger.debug(
      "{} collections found: {}",
      args: [_skeleton.length, _skeleton.keys],
    );*/ /*
  }*/

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

      Reflection.setFieldValue(entity, getRepository(type: T),
          name: "repository");

      await _fetchEntity(entity, []);
      entities.add(entity);
    }

    return entities;
  }

  // List<Repository> get repositories => _skeleton.values.toList();

  Repository getRepository({String? typeName, Type? type, Entity? entity}) {
    /*if ((typeName == null && type == null && entity == null) ||
        (typeName != null && type != null && entity != null)) {
      throw "You must provide either a typeName, a type or an entity";
    }

    if (type != null) typeName = type.toString();
    if (entity != null) typeName = entity.runtimeType.toString();

    if (!_skeleton.containsKey(typeName)) {
      throw "Repository not found for type \"$typeName\"";
    }

    return _skeleton[typeName.toString()]!;*/
    return _skeleton.first;
  }

  Future<void> _fetchEntity(
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
  }

  Future<void> _test(
    Identifiable origin,
    List<Identifiable> references,
    Type type,
    String foreignKey,
  ) async {
    final data = (await Utils.listDocuments(
      this,
      type.toString(),
      ids: [foreignKey],
    ))
        .first
        .data;

    final entity = Reflection.instantiate(
      type,
      constructor: "empty",
    ).deserialize(data);

    await _fetchEntity(entity, [origin, ...references]);
    await _fetchEntity(origin, [entity, ...references]);

    /*final data = (await Utils.listDocuments(
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
    await _fetchEntity(origin, [entity, ...references]);*/
  }
}
