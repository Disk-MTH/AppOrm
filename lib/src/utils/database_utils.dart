import "package:app_orm/src/repository.dart";
import "package:app_orm/src/utils/utils.dart";

import "../appwrite_orm.dart";
import 'enums.dart';

class DatabaseUtils {
  static Future<bool> createCollection(
    AppwriteOrm orm,
    Repository repository,
  ) async {
    final logger = Utils.logger;
    bool failed = false;

    await orm.databases
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
          await orm.databases
              .createStringAttribute(
            databaseId: orm.id,
            collectionId: repository.id,
            key: attribute.key,
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
          await orm.databases
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
          await orm.databases
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
          await orm.databases
              .createFloatAttribute(
            databaseId: orm.id,
            collectionId: repository.id,
            key: attribute.key,
            xrequired: attribute.modifiers[Modifier.required] ?? false,
            array: attribute.modifiers[Modifier.array] ?? false,
            xdefault: attribute.modifiers[Modifier.defaultValue],
            min: attribute.modifiers[Modifier.min] ?? Utils.floatMin,
            max: attribute.modifiers[Modifier.max] ?? Utils.floatMax,
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
          await orm.databases
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
          await orm.databases
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
          await orm.databases
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
          await orm.databases
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
          await orm.databases
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
          await orm.databases
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
      await Future.delayed(Duration(milliseconds: 100));
    } while ((await orm.databases.listAttributes(
      databaseId: orm.id,
      collectionId: repository.id,
    ))
        .attributes
        .any((e) => e["status"] != Status.available.name));

    for (var index in repository.indexes) {
      await orm.databases
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

  static Future<bool> updateCollection(
    AppwriteOrm orm,
    Repository repository,
  ) async {
    return false;
  }

  static Future<bool> deleteCollection(
    AppwriteOrm orm,
    String id,
  ) async {
    final logger = Utils.logger;
    bool failed = false;

    await orm.databases
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
}
