import "dart:mirrors";

import "package:app_orm/src/serializable.dart";
import "package:app_orm/src/utils.dart";

import "annotations.dart";
import "logger.dart";

class Identifiable<T> implements Serializable<T> {
  final AbstractLogger logger = Serializable.logger;

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

  @override
  Map<String, dynamic> serialize() {
    return Reflection.listInstanceFields(this).map((key, value) {
      if (value.value is Serializable) {
        return MapEntry(key, value.value.serialize());
      } else if (value.value is List<Serializable>) {
        return MapEntry(key, value.value.map((e) => e.serialize()).toList());
      }
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

      dynamic value = annotation is OrmNative
          ? data[annotation.$prefix ? "\$$name" : name]
          : data[name.substring(1)];

      if (value == null && (annotation.isRequired || annotation.isArray)) {
        throw "Field \"$name\" is not nullable";
      }

      if (annotation is OrmEntity) {
        value = Reflection.instantiate(
          mirror.type.reflectedType,
          constructor: "empty",
        ).deserialize(value);
      }

      Reflection.setFieldValue(this, value, mirror: mirror);
    });
    return this as T;
  }
}
