import "dart:mirrors";

import "package:app_orm/src/permission.dart";
import "package:app_orm/src/serializable.dart";
import "package:app_orm/src/utils.dart";

import "enums.dart";
import "logger.dart";
import "orm.dart";

class Identifiable<T> implements Serializable<T> {
  final AbstractLogger logger = Utils.logger;
  final Map<String, List<String>> foreignKeys = {};

  @Orm(AttributeType.string, modifiers: {
    Modifier.isRequired: true,
    Modifier.size: 20,
  })
  String id = Utils.uniqueId();

  @Orm(AttributeType.string, modifiers: {Modifier.isRequired: true})
  String createdAt = DateTime.now().toIso8601String();

  @Orm(AttributeType.string, modifiers: {Modifier.isRequired: true})
  String updatedAt = DateTime.now().toIso8601String();

  Identifiable.empty();

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
            (e) => e.reflectee is Orm,
          )
          .firstOrNull;

      if (metadata == null) return;

      final Orm annotation = metadata.reflectee;
      final AttributeType type = annotation.type;
      final Map<Modifier, dynamic> modifiers = annotation.modifiers;

      name = type == AttributeType.entity ? "${name}_ORMID" : name;

      dynamic value = data[name];
      annotation.validate();

      if (type == AttributeType.entity) {
        if (modifiers[Modifier.isArray] == true) {
          foreignKeys[name] = value.cast<String>();
        } else {
          foreignKeys[name] = [value];
        }
      } else if (modifiers[Modifier.isArray] == true) {
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
    return this as T;
  }
}
