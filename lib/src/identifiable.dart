import "dart:mirrors";

import "package:app_orm/src/utils/reflection.dart";
import 'package:app_orm/src/utils/serializable.dart';

import "orm.dart";
import 'utils/enums.dart';

class Identifiable<T> with Serializable<T> {
  final Map<String, List<String>> foreignKeys = {};

  @Orm(AttributeType.native)
  late String id;

  @Orm(AttributeType.native)
  late String createdAt;

  @Orm(AttributeType.native)
  late String updatedAt;

  Identifiable.empty();

  T fromMap(Map<String, dynamic> data) {
    Map.from(data).forEach((key, value) {
      if (key.startsWith("\$")) {
        data[key.substring(1)] = data.remove(key);
      }
    });

    Reflection.listClassFields(
      runtimeType,
      annotation: Orm,
    ).forEach((name, mirror) {
      final Orm annotation =
          mirror.metadata.firstWhere((e) => e.reflectee is Orm).reflectee;
      final AttributeType type = annotation.type;
      final Map<Modifier, dynamic> modifiers = annotation.modifiers;

      name = type == AttributeType.entity ? "${name}_ORMID" : name;

      dynamic value = data[name];
      annotation.validate("");

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
                    constructor: "fromModel",
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
    return this as T;
  }

  //TODO patch for cyclic references
  @override
  Map<String, dynamic> serialize() {
    final Map<String, dynamic> data = {};
    Reflection.listInstanceFields(this).forEach((key, value) {
      if (value.variableMirror.metadata
          .where((e) => e.reflectee is Orm)
          .isEmpty) {
        return;
      }

      /*if (!data.containsKey(key)) {
        if (value.value is Serializable) {
          data[key] = value.value.serialize();
        } else if (value.value is List<Serializable>) {
          data[key] = value.value.map((e) => e.serialize()).toList();
        } else {
          data[key] = value.value;
        }
      }*/
      data[key] = value.value;
    });
    return data;
  }

  @override
  T deserialize(Map<String, dynamic> data) {
    logger.error("unique");
    return this as T;
  }

  @override
  bool equals(Serializable other) {
    return other is Identifiable &&
        other.id == id &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }
}
