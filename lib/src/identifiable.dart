import "dart:mirrors";

import "package:app_orm/src/utils.dart";
import "package:dart_appwrite/models.dart";

import "annotations.dart";

class Identifiable<M extends Model> implements Model {
  @OrmNative($prefix: true)
  late final String id;

  @OrmNative($prefix: true)
  late final String createdAt;

  @OrmNative($prefix: true)
  late final String updatedAt;

  void initialize(M model) {
    Reflection.listClassFields(runtimeType).forEach((name, mirror) {
      final InstanceMirror? metadata =
          mirror.metadata.where((e) => e.reflectee is OrmNative).firstOrNull;

      if (metadata == null) return;

      final OrmNative annotation = metadata.reflectee;
      annotation.validate();

      Reflection.setFieldValue(
        this,
        Reflection.listInstanceFields(
                model)[annotation.$prefix ? "\$$name" : name]
            ?.value,
        mirror: mirror,
      );
    });
  }

  @override
  Map<String, dynamic> toMap() {
    return Reflection.listInstanceFields(this).map((key, value) {
      if (value.value is Model) {
        return MapEntry(key, value.value.toMap());
      } else if (value.value is List<Model>) {
        return MapEntry(key, value.value.map((e) => e.toMap()).toList());
      }
      return MapEntry(key, value.value.toString());
    });
  }
}
