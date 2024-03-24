import "package:app_orm/src/entity.dart";
import "package:app_orm/src/repository.dart";
import "package:app_orm/src/utils/utils.dart";
import "package:dart_appwrite/dart_appwrite.dart";
import "package:dart_appwrite/models.dart";

import "../appwrite_orm.dart";
import 'enums.dart';

class DatabaseUtils {
  static Future<List<Database>> listDatabases(AppwriteOrm orm) async {
    final logger = Utils.logger;
    final List<Database> databases = [];

    await orm.appwriteDB
        .list()
        .then((value) => databases.addAll(value.databases))
        .onError((error, stackTrace) {
      logger.error(
        "Failed to list databases",
        exception: "$error\n$stackTrace",
      );
    });

    return databases;
  }

  static Future<bool> createDatabase(AppwriteOrm orm) async {
    final logger = Utils.logger;
    bool failed = false;

    await orm.appwriteDB
        .create(
      databaseId: Utils.uniqueId(),
      name: orm.name,
      enabled: orm.enabled,
    )
        .then((value) {
      orm.id = value.$id;
      orm.createdAt = value.$createdAt;
      orm.updatedAt = value.$updatedAt;

      logger.log(
        "Database \"{}\" created",
        args: [orm.name],
      );
    }).onError((error, stackTrace) {
      failed = true;
      logger.error(
        "Failed to create database",
        exception: "$error\n$stackTrace",
      );
    });

    if (failed) return false;
    return true;
  }

  static Future<List<Collection>> listCollections(AppwriteOrm orm) async {
    final logger = Utils.logger;
    final List<Collection> collections = [];

    await orm.appwriteDB
        .listCollections(databaseId: orm.id)
        .then((value) => collections.addAll(value.collections))
        .onError((error, stackTrace) {
      logger.error(
        "Failed to list collections in database \"{}\"",
        args: [orm.name],
        exception: "$error\n$stackTrace",
      );
    });

    return collections;
  }

  static Future<bool> createCollection(
    AppwriteOrm orm,
    Repository repository,
  ) async {
    final logger = Utils.logger;
    bool failed = false;

    await orm.appwriteDB
        .createCollection(
      databaseId: orm.id,
      collectionId: Utils.uniqueId(),
      name: repository.name,
      documentSecurity: repository.documentSecurity,
      enabled: repository.enabled,
      permissions: repository.permissions.map((e) => e.string).toList(),
    )
        .then((value) {
      repository.id = value.$id;
      repository.createdAt = value.$createdAt;
      repository.updatedAt = value.$updatedAt;

      logger.log(
        "Collection \"{}\" created in database \"{}\"",
        args: [repository.name, orm.name],
      );

      for (var permission in repository.permissions) {
        logger.log(
          "Permission \"{}\" created in collection \"{}\"",
          args: [permission.string, repository.name],
        );
      }
    }).onError((error, stackTrace) {
      failed = true;
      logger.error(
        "Failed to create collection \"{}\" in database \"{}\"",
        args: [repository.name, orm.name],
        exception: "$error\n$stackTrace",
      );
    });

    if (failed) return false;

    for (var attribute in repository.attributes) {
      switch (attribute.type) {
        case AttributeType.entity:
          await orm.appwriteDB
              .createStringAttribute(
            databaseId: orm.id,
            collectionId: repository.id,
            key: "${attribute.key}_ORM_ENTITY",
            xrequired: attribute.modifiers[Modifier.required] ?? false,
            array: attribute.modifiers[Modifier.array] ?? false,
            size: Utils.idLength,
          )
              .then((value) {
            attribute.status = Status.values.firstWhere(
              (e) => e.name == value.status,
            );
            attribute.error = value.error.isEmpty ? null : value.error;
            logger.log(
              "Attribute \"{}\" ({}) created in collection \"{}\"",
              args: [attribute.key, attribute.type, repository.name],
            );
          }).onError((error, stackTrace) {
            failed = true;
            logger.error(
              "Failed to create attribute \"{}\" ({}) in collection \"{}\"",
              args: [attribute.key, attribute.type, repository.name],
              exception: "$error\n$stackTrace",
            );
          });
          break;
        case AttributeType.string:
          await orm.appwriteDB
              .createStringAttribute(
            databaseId: orm.id,
            collectionId: repository.id,
            key: attribute.key,
            xrequired: attribute.modifiers[Modifier.required] ?? false,
            array: attribute.modifiers[Modifier.array] ?? false,
            xdefault: attribute.modifiers[Modifier.defaultValue],
            size: attribute.modifiers[Modifier.size] ?? Utils.stringMax,
          )
              .then((value) {
            attribute.status = Status.values.firstWhere(
              (e) => e.name == value.status,
            );
            attribute.error = value.error.isEmpty ? null : value.error;
            logger.log(
              "Attribute \"{}\" ({}) created in collection \"{}\"",
              args: [attribute.key, attribute.type, repository.name],
            );
          }).onError((error, stackTrace) {
            failed = true;
            logger.error(
              "Failed to create attribute \"{}\" ({}) in collection \"{}\"",
              args: [attribute.key, attribute.type, repository.name],
              exception: "$error\n$stackTrace",
            );
          });
          break;
        case AttributeType.integer:
          await orm.appwriteDB
              .createIntegerAttribute(
            databaseId: orm.id,
            collectionId: repository.id,
            key: attribute.key,
            xrequired: attribute.modifiers[Modifier.required] ?? false,
            array: attribute.modifiers[Modifier.array] ?? false,
            xdefault: attribute.modifiers[Modifier.defaultValue],
            min: attribute.modifiers[Modifier.min] ?? Utils.intMin,
            max: attribute.modifiers[Modifier.max] ?? Utils.intMax,
          )
              .then((value) {
            attribute.status = Status.values.firstWhere(
              (e) => e.name == value.status,
            );
            attribute.error = value.error.isEmpty ? null : value.error;
            logger.log(
              "Attribute \"{}\" ({}) created in collection \"{}\"",
              args: [attribute.key, attribute.type, repository.name],
            );
          }).onError((error, stackTrace) {
            failed = true;
            logger.error(
              "Failed to create attribute \"{}\" ({}) in collection \"{}\"",
              args: [attribute.key, attribute.type, repository.name],
              exception: "$error\n$stackTrace",
            );
          });
          break;
        case AttributeType.double:
          await orm.appwriteDB
              .createFloatAttribute(
            databaseId: orm.id,
            collectionId: repository.id,
            key: attribute.key,
            xrequired: attribute.modifiers[Modifier.required] ?? false,
            array: attribute.modifiers[Modifier.array] ?? false,
            xdefault: attribute.modifiers[Modifier.defaultValue],
            min: attribute.modifiers[Modifier.min] ?? Utils.doubleMin,
            max: attribute.modifiers[Modifier.max] ?? Utils.doubleMax,
          )
              .then((value) {
            attribute.status = Status.values.firstWhere(
              (e) => e.name == value.status,
            );
            attribute.error = value.error.isEmpty ? null : value.error;
            logger.log(
              "Attribute \"{}\" ({}) created in collection \"{}\"",
              args: [attribute.key, attribute.type, repository.name],
            );
          }).onError((error, stackTrace) {
            failed = true;
            logger.error(
              "Failed to create attribute \"{}\" ({}) in collection \"{}\"",
              args: [attribute.key, attribute.type, repository.name],
              exception: "$error\n$stackTrace",
            );
          });
          break;
        case AttributeType.boolean:
          await orm.appwriteDB
              .createBooleanAttribute(
            databaseId: orm.id,
            collectionId: repository.id,
            key: attribute.key,
            xrequired: attribute.modifiers[Modifier.required] ?? false,
            array: attribute.modifiers[Modifier.array] ?? false,
            xdefault: attribute.modifiers[Modifier.defaultValue],
          )
              .then((value) {
            attribute.status = Status.values.firstWhere(
              (e) => e.name == value.status,
            );
            attribute.error = value.error.isEmpty ? null : value.error;
            logger.log(
              "Attribute \"{}\" ({}) created in collection \"{}\"",
              args: [attribute.key, attribute.type, repository.name],
            );
          }).onError((error, stackTrace) {
            failed = true;
            logger.error(
              "Failed to create attribute \"{}\" ({}) in collection \"{}\"",
              args: [attribute.key, attribute.type, repository.name],
              exception: "$error\n$stackTrace",
            );
          });
          break;
        case AttributeType.datetime:
          await orm.appwriteDB
              .createDatetimeAttribute(
            databaseId: orm.id,
            collectionId: repository.id,
            key: attribute.key,
            xrequired: attribute.modifiers[Modifier.required] ?? false,
            array: attribute.modifiers[Modifier.array] ?? false,
            xdefault: attribute.modifiers[Modifier.defaultValue],
          )
              .then((value) {
            attribute.status = Status.values.firstWhere(
              (e) => e.name == value.status,
            );
            attribute.error = value.error.isEmpty ? null : value.error;
            logger.log(
              "Attribute \"{}\" ({}) created in collection \"{}\"",
              args: [attribute.key, attribute.type, repository.name],
            );
          }).onError((error, stackTrace) {
            failed = true;
            logger.error(
              "Failed to create attribute \"{}\" ({}) in collection \"{}\"",
              args: [attribute.key, attribute.type, repository.name],
              exception: "$error\n$stackTrace",
            );
          });
          break;
        case AttributeType.email:
          await orm.appwriteDB
              .createEmailAttribute(
            databaseId: orm.id,
            collectionId: repository.id,
            key: attribute.key,
            xrequired: attribute.modifiers[Modifier.required] ?? false,
            array: attribute.modifiers[Modifier.array] ?? false,
            xdefault: attribute.modifiers[Modifier.defaultValue],
          )
              .then((value) {
            attribute.status = Status.values.firstWhere(
              (e) => e.name == value.status,
            );
            attribute.error = value.error.isEmpty ? null : value.error;
            logger.log(
              "Attribute \"{}\" ({}) created in collection \"{}\"",
              args: [attribute.key, attribute.type, repository.name],
            );
          }).onError((error, stackTrace) {
            failed = true;
            logger.error(
              "Failed to create attribute \"{}\" ({}) in collection \"{}\"",
              args: [attribute.key, attribute.type, repository.name],
              exception: "$error\n$stackTrace",
            );
          });
          break;
        case AttributeType.ip:
          await orm.appwriteDB
              .createIpAttribute(
            databaseId: orm.id,
            collectionId: repository.id,
            key: attribute.key,
            xrequired: attribute.modifiers[Modifier.required] ?? false,
            array: attribute.modifiers[Modifier.array] ?? false,
            xdefault: attribute.modifiers[Modifier.defaultValue],
          )
              .then((value) {
            attribute.status = Status.values.firstWhere(
              (e) => e.name == value.status,
            );
            attribute.error = value.error.isEmpty ? null : value.error;
            logger.log(
              "Attribute \"{}\" ({}) created in collection \"{}\"",
              args: [attribute.key, attribute.type, repository.name],
            );
          }).onError((error, stackTrace) {
            failed = true;
            logger.error(
              "Failed to create attribute \"{}\" ({}) in collection \"{}\"",
              args: [attribute.key, attribute.type, repository.name],
              exception: "$error\n$stackTrace",
            );
          });
          break;
        case AttributeType.url:
          await orm.appwriteDB
              .createUrlAttribute(
            databaseId: orm.id,
            collectionId: repository.id,
            key: attribute.key,
            xrequired: attribute.modifiers[Modifier.required] ?? false,
            array: attribute.modifiers[Modifier.array] ?? false,
            xdefault: attribute.modifiers[Modifier.defaultValue],
          )
              .then((value) {
            attribute.status = Status.values.firstWhere(
              (e) => e.name == value.status,
            );
            attribute.error = value.error.isEmpty ? null : value.error;
            logger.log(
              "Attribute \"{}\" ({}) created in collection \"{}\"",
              args: [attribute.key, attribute.type, repository.name],
            );
          }).onError((error, stackTrace) {
            failed = true;
            logger.error(
              "Failed to create attribute \"{}\" ({}) in collection \"{}\"",
              args: [attribute.key, attribute.type, repository.name],
              exception: "$error\n$stackTrace",
            );
          });
          break;
        case AttributeType.enumeration:
          await orm.appwriteDB
              .createEnumAttribute(
            databaseId: orm.id,
            collectionId: repository.id,
            key: attribute.key,
            xrequired: attribute.modifiers[Modifier.required] ?? false,
            array: attribute.modifiers[Modifier.array] ?? false,
            xdefault: attribute.modifiers[Modifier.defaultValue],
            elements: attribute.modifiers[Modifier.elements],
          )
              .then((value) {
            attribute.status = Status.values.firstWhere(
              (e) => e.name == value.status,
            );
            attribute.error = value.error.isEmpty ? null : value.error;
            logger.log(
              "Attribute \"{}\" ({}) created in collection \"{}\"",
              args: [attribute.key, attribute.type, repository.name],
            );
          }).onError((error, stackTrace) {
            failed = true;
            logger.error(
              "Failed to create attribute \"{}\" ({}) in collection \"{}\"",
              args: [attribute.key, attribute.type, repository.name],
              exception: "$error $stackTrace",
            );
          });
          break;
        default:
          break;
      }
    }

    if (failed) {
      await deleteCollection(orm, repository.id);
      return false;
    }

    do {
      await Future.delayed(Duration(milliseconds: 50));
    } while ((await orm.appwriteDB.listAttributes(
      databaseId: orm.id,
      collectionId: repository.id,
    ))
        .attributes
        .any((e) => e["status"] != Status.available.name));

    for (var index in repository.indexes) {
      await orm.appwriteDB
          .createIndex(
        databaseId: orm.id,
        collectionId: repository.id,
        key: index.key,
        type: index.type.name,
        attributes: index.attributes.keys.toList(),
        orders: index.attributes.values.map((e) => e.name).toList(),
      )
          .then((value) {
        logger.log(
          "Index \"{}\" ({}) created in collection \"{}\"",
          args: [index.key, index.type, repository.name],
        );
      }).onError((error, stackTrace) {
        failed = true;
        logger.error(
          "Failed to create index \"{}\" ({}) in collection \"{}\"",
          args: [index.key, index.type, repository.name],
          exception: "$error\n$stackTrace",
        );
      });
    }

    if (failed) {
      await deleteCollection(orm, repository.id);
      return false;
    }

    return true;
  }

  static Future<bool> deleteCollection(
    AppwriteOrm orm,
    String id,
  ) async {
    final logger = Utils.logger;
    bool failed = false;

    await orm.appwriteDB
        .deleteCollection(
      databaseId: orm.id,
      collectionId: id,
    )
        .then((value) {
      logger.log(
        "Collection \"{}\" deleted from database \"{}\"",
        args: [id, orm.name],
      );
    }).onError((error, stackTrace) {
      failed = true;
      logger.error(
        "Failed to delete collection \"{}\" from database \"{}\"",
        args: [id, orm.name],
        exception: "$error\n$stackTrace",
      );
    });

    if (failed) return false;

    return true;
  }

  //TODO: add more queries
  static Future<List<Document>> listDocuments(
    AppwriteOrm orm,
    Repository repository, {
    List<String> ids = const [],
  }) async {
    final logger = Utils.logger;
    final List<Document> documents = [];

    await orm.appwriteDB
        .listDocuments(
          databaseId: orm.id,
          collectionId: repository.id,
          queries: [
            if (ids.isNotEmpty) Query.equal("\$id", ids),
          ],
        )
        .then((value) => documents.addAll(value.documents))
        .onError((error, stackTrace) {
          logger.error(
            "Failed to list documents in collection \"{}\" from database \"{}\"",
            args: [repository.name, orm.name],
            exception: "$error\n$stackTrace",
          );
        });

    return documents;
  }

  static Future<bool> createDocument(
    AppwriteOrm orm,
    Repository repository,
    Entity entity,
  ) async {
    final logger = Utils.logger;
    bool failed = false;

    await orm.appwriteDB.createDocument(
      databaseId: orm.id,
      collectionId: repository.id,
      documentId: Utils.uniqueId(),
      permissions: entity.permissions.map((e) => e.string).toList(),
      data: {},
    ).then((value) {
      entity.id = value.$id;
      entity.createdAt = value.$createdAt;
      entity.updatedAt = value.$updatedAt;

      logger.log(
        "Document \"{}\" created in collection \"{}\" from database \"{}\"",
        args: [entity.id, repository.name, orm.name],
      );
    }).onError((error, stackTrace) {
      failed = true;
      logger.error(
        "Failed to create document in collection \"{}\" from database \"{}\"",
        args: [repository.name, orm.name],
        exception: "$error\n$stackTrace",
      );
    });

    if (failed) return false;
    return true;
  }
}
