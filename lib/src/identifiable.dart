import "dart:mirrors";

import "package:app_orm/src/permission.dart";
import "package:app_orm/src/serializable.dart";
import "package:app_orm/src/utils.dart";

import "annotations.dart";
import "enums.dart";
import "logger.dart";

class Identifiable<T> implements Serializable<T> {
  final AbstractLogger logger = Utils.logger;
  final Map<String, List<String>> foreignKeys = {};

  // @OrmTest(AttributeType.string)
  // @OrmNative($prefix: true)
  @OrmTest(AttributeType.string)
  String id = Utils.uniqueId();

  // @OrmNative($prefix: true)
  @OrmTest(AttributeType.string)
  String createdAt = DateTime.now().toIso8601String();

  // @OrmNative($prefix: true)
  @OrmTest(AttributeType.string)
  String updatedAt = DateTime.now().toIso8601String();

  Identifiable.empty();

  //TODO patch for cyclic references
  @override
  Map<String, dynamic> serialize() {
    final Map<String, dynamic> data = {};
    Reflection.listInstanceFields(this).forEach((key, value) {
      if (value.variableMirror.metadata
          .where((e) => e.reflectee is OrmTest)
          .isEmpty) {
        return;
      }

      /*if (value.value is Serializable) {
        return MapEntry(key, value.value.serialize());
      } else if (value.value is List<Serializable>) {
        return MapEntry(key, value.value.map((e) => e.serialize()).toList());
      }*/
      data.addAll({key: value.value.toString()});
    });
    return data;
  }

  @override
  T deserialize(Map<String, dynamic> data) {
    Map.from(data).forEach((key, value) {
      if (key.startsWith("\$")) {
        data[key.substring(1)] = data.remove(key);
      }
    });

    Reflection.listClassFields(runtimeType).forEach((name, mirror) {
      final InstanceMirror? metadata = mirror.metadata
          .where(
            (e) => e.reflectee is OrmTest,
          )
          .firstOrNull;

      if (metadata == null) return;

      final AttributeType type = metadata.reflectee.type;
      final Map<Modifier, dynamic> modifiers = metadata.reflectee.modifiers;

      name = type == AttributeType.entity ? "${name}_ORMID" : name;

      dynamic value = data[name];

      if (type == AttributeType.entity) {
        if (modifiers[Modifier.array] == true) {
          foreignKeys[name] = value.cast<String>();
        } else {
          foreignKeys[name] = [value];
        }
      } else if (modifiers[Modifier.array] == true) {
        final List field = Reflection.getField(
          this,
          MirrorSystem.getName(mirror.simpleName),
        );
        field.clear();

        if (type == AttributeType.native) {
          final Type type = mirror.type.typeArguments.first.reflectedType;
          value = value
              .map((e) => Reflection.instantiate(
                    type,
                    constructor: type == Permission ? "fromString" : "fromMap",
                    args: [e],
                  ))
              .toList();
        }

        for (var item in value) {
          field.add(item);
        }
      } else {
        Reflection.setFieldValue(this, value, mirror: mirror);
      }
    });
    logger.warn(foreignKeys);
    return this as T;
  }
}
