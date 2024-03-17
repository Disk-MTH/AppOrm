import "dart:mirrors";

import "package:app_orm/src/utils/reflection.dart";
import 'package:app_orm/src/utils/serializable.dart';

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

  Identifiable fromMap(Map<String, dynamic> data) {
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
        Reflection.setFieldValue(this, value, variable: mirror);
      }
    });
    return this;
  }

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

  //TODO redo this
  @override
  Identifiable deserialize(Map<String, dynamic> data) {
    print(data);
    Reflection.listClassFields(runtimeType, annotation: Orm)
        .forEach((name, variable) {
      final Orm annotation = variable.metadata
          .firstWhere(
            (e) => e.reflectee is Orm,
          )
          .reflectee;

      Reflection.setFieldValue(
        this,
        data[name],
        variable: variable,
      );
    });
    return this;
  }

  @override
  bool equals(Serializable other) {
    return other is Identifiable &&
        other.id == id &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }
}
