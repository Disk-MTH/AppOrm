import 'dart:mirrors';

import "package:app_orm/src/utils/reflection.dart";
import 'package:app_orm/src/utils/serializable.dart';
import 'package:collection/collection.dart';

import "orm.dart";
import 'utils/enums.dart';

class Identifiable with Serializable {
  final Map<String, List<String>> foreignKeys = {};

  @Orm(AttributeType.native)
  late final String id;

  @Orm(AttributeType.native)
  late final String createdAt;

  @Orm(AttributeType.native)
  late final String updatedAt;

  Identifiable();

  Identifiable.orm(Map<String, dynamic> data) {
    deserialize(data);
  }

  /*Identifiable fromMap(Map<String, dynamic> data) {
    if (data.isEmpty) return this;
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
        Reflection.setFieldValue(this, value, variable: mirror);
      }
    });
    return this;
  }*/

  @override
  Map<String, dynamic> serialize() {
    final Map<String, dynamic> data = {};
    Reflection.listInstanceFields(this).forEach((name, variable) {
      if (variable.variableMirror.metadata
          .where((e) => e.reflectee is Orm)
          .isEmpty) {
        return;
      }

      if (variable.value is Serializable) {
        data[name] = variable.value.serialize();
      } else if (variable.value is List<Serializable>) {
        data[name] = variable.value.map((e) => e.serialize()).toList();
      } else {
        data[name] = variable.value;
      }
    });
    return data;
  }

  @override
  Identifiable deserialize(Map<String, dynamic> data) {
    Reflection.listClassFields(runtimeType).forEach((name, variable) {
      final Orm? annotation = variable.metadata
          .firstWhereOrNull((e) => e.reflectee is Orm)
          ?.reflectee;

      if (annotation == null) return;

      try {
        final bool isEntity = annotation.type == AttributeType.entity;
        if (annotation.modifiers[Modifier.array] == true) {
          final field = Reflection.getField(
            this,
            MirrorSystem.getName(variable.simpleName),
          );
          field.clear();
          data[name].forEach((e) {
            field.add(
              isEntity
                  ? Reflection.instantiate(
                      variable.type.typeArguments.first.reflectedType,
                      constructor: "orm",
                      args: [e],
                    )
                  : e,
            );
          });
        } else {
          Reflection.setFieldValue(
            this,
            isEntity
                ? Reflection.instantiate(
                    variable.type.reflectedType,
                    constructor: "orm",
                    args: [data[name]],
                  )
                : data[name],
            variable: variable,
          );
        }
      } catch (_) {}
    });

    return this;
  }
}
