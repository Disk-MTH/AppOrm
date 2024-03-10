import "dart:convert";
import "dart:math";
import "dart:mirrors";

import "package:app_orm/src/appwrite_orm.dart";
import "package:app_orm/src/reflected_variable.dart";
import "package:app_orm/src/repository.dart";
import "package:app_orm/src/serializable.dart";
import "package:dart_appwrite/dart_appwrite.dart";
import "package:dart_appwrite/models.dart";

import "logger.dart";

class Utils {
  static AbstractLogger logger = DummyLogger();
  static final Random random = Random(DateTime.now().millisecondsSinceEpoch);
  static const String idCharset = "abcdefghijklmnopqrstuvwxyz0123456789";

  static String uniqueId() {
    return List.generate(
      20,
      (_) => idCharset[random.nextInt(idCharset.length)],
    ).join();
  }

  static String beautify(dynamic input) {
    if (input is Serializable) {
      return "${input.runtimeType}\n${JsonEncoder.withIndent("  ").convert(input.serialize())}";
    } else if (input is List<Serializable>) {
      return "${input.runtimeType}\n${input.map((e) => beautify(e)).join("\n")}";
    } else if (input is Map<String, dynamic>) {
      return JsonEncoder.withIndent("  ").convert(input);
    } else if (input is List<Map<String, dynamic>>) {
      return input.map((e) => beautify(e)).join("\n");
    }
    return input;
  }

  //TODO add more filters
  static Future<List<Document>> listDocuments(
    AppwriteOrm appOrm,
    String typeName, {
    List<String> ids = const [],
  }) {
    logger.debug(
      "Retrieving documents for {}: {}",
      args: [typeName, ids.isEmpty ? "all" : ids],
    );

    return appOrm.databases.listDocuments(
      databaseId: appOrm.id,
      collectionId: appOrm.getRepository(typeName: typeName).id,
      queries: [
        if (ids.isNotEmpty) Query.equal("\$id", ids),
      ],
    ).then((value) => value.documents);
  }
}

class DatabaseUtils {
  static Future<bool> createCollection(
    Databases databases,
    Repository repository,
  ) async {
    final logger = Utils.logger;
    bool failed = false;

    await databases
        .createCollection(
      databaseId: repository.databaseId,
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
        args: [repository.name, repository.databaseId],
      );
    }).onError((error, stackTrace) {
      failed = true;
      logger.error(
        "Failed to create collection \"{}\" in database \"{}\"",
        args: [repository.name, repository.databaseId],
        exception: error,
      );
    });

    if (failed) return false;

    for (var index in repository.indexes) {
      await databases
          .createIndex(
        databaseId: repository.databaseId,
        collectionId: repository.id,
        key: index.key,
        type: index.type.name,
        attributes: index.attributes.keys.toList(),
        orders: index.attributes.values.map((e) => e.name).toList(),
      )
          .then((value) {
        logger.log(
          "Index \"{}\" created in collection \"{}\"",
          args: [index.key, repository.name],
        );
      }).onError((error, stackTrace) {
        failed = true;
        logger.error(
          "Failed to create index \"{}\" in collection \"{}\"",
          args: [index.key, repository.name],
          exception: error,
        );
      });
    }

    if (failed) return false;

    return true;
  }
}

class Reflection {
  static bool isSubtype(Type type, Type parent) {
    return reflectClass(type).isSubclassOf(reflectClass(parent));
  }

  static Map<String, VariableMirror> listClassFields(
    Type type, {
    Type? annotation,
  }) {
    final fields = <String, VariableMirror>{};
    ClassMirror? cm = reflectClass(type);

    while (cm != null && cm != reflectClass(Object)) {
      cm.declarations.forEach((key, value) {
        if (value is VariableMirror) fields[MirrorSystem.getName(key)] = value;
      });
      cm = cm.superclass;
    }

    fields.removeWhere((key, value) {
      return annotation != null &&
          value.metadata
              .where((e) => e.type.reflectedType == annotation)
              .isEmpty;
    });

    return fields;
  }

  static Map<String, ReflectedVariable> listInstanceFields(dynamic instance) {
    final fields = <String, ReflectedVariable>{};
    final InstanceMirror im = reflect(instance);

    listClassFields(instance.runtimeType).forEach((name, variableMirror) {
      fields[name] = ReflectedVariable(
        variableMirror,
        im.getField(variableMirror.simpleName).reflectee,
      );
    });

    return fields;
  }

  static dynamic getField(dynamic instance, String name) {
    return reflect(instance).getField(Symbol(name)).reflectee;
  }

  static void setFieldValue(
    dynamic instance,
    dynamic value, {
    String? name,
    VariableMirror? mirror,
  }) {
    if ((name == null && mirror == null) || (name != null && mirror != null)) {
      throw "You must provide a field OR a variable mirror";
    }

    reflect(instance).setField(
      name != null ? Symbol(name) : mirror!.simpleName,
      value,
    );
  }

  static dynamic instantiate(
    Type type, {
    String constructor = "",
    List<dynamic> args = const [],
  }) {
    return reflectClass(type).newInstance(Symbol(constructor), args).reflectee;
  }

  static Type typeByName(String typeName) {
    return MirrorSystem.getSymbol(typeName).runtimeType;
  }
}
