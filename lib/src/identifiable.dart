import "dart:mirrors";

import "package:app_orm/src/serializable.dart";
import "package:app_orm/src/utils.dart";

import "annotations.dart";
import "logger.dart";

class Identifiable<T> implements Serializable<T> {
  final AbstractLogger logger = Serializable.logger;
  final Map<String, List<String>> foreignKeys = {};

  @OrmNative($prefix: true)
  late String? id;

  @OrmNative($prefix: true)
  late String? createdAt;

  @OrmNative($prefix: true)
  late String? updatedAt;

  Identifiable.empty() {
    Reflection.listClassFields(runtimeType).forEach((name, mirror) {
      final OrmNative? annotation = mirror.metadata
          .where((e) => e.reflectee is OrmNative)
          .firstOrNull
          ?.reflectee;

      if (annotation == null) return;
      annotation.validate();

      Reflection.setFieldValue(this, null, mirror: mirror);
    });
  }

  //TODO patch for cyclic references
  @override
  Map<String, dynamic> serialize() {
    return Reflection.listInstanceFields(this).map((key, value) {
      /*if (value.value is Serializable) {
        return MapEntry(key, value.value.serialize());
      } else if (value.value is List<Serializable>) {
        return MapEntry(key, value.value.map((e) => e.serialize()).toList());
      }*/
      return MapEntry(key, value.value.toString());
    });
  }

  @override
  T deserialize(Map<String, dynamic> data) {
    Reflection.listClassFields(runtimeType).forEach((name, mirror) {
      final InstanceMirror? metadata =
          mirror.metadata.where((e) => e.reflectee is OrmAttribute).firstOrNull;

      if (metadata == null) return;

      final OrmAttribute annotation = metadata.reflectee;
      annotation.validate();

      name = annotation is OrmNative
          ? (annotation.$prefix ? "\$$name" : name)
          : name;

      name = annotation is OrmEntity || annotation is OrmEntities
          ? "${name}_ORMID"
          : name;

      dynamic value = data[name];

      if (value == null && (annotation.isRequired || annotation.isArray)) {
        throw "Field \"$name\" is not nullable";
      }

      if (annotation is OrmEntity) {
        foreignKeys[name] = [value];
      } else if (annotation is OrmEntities) {
        foreignKeys[name] = value.cast<String>();
      } else {
        Reflection.setFieldValue(this, value, mirror: mirror);
      }
    });
    return this as T;
  }
}
