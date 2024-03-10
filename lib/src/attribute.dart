import "package:app_orm/src/serializable.dart";

import "enums.dart";

class Attribute with Serializable<Attribute> {
  late String key;
  late AttributeType type;
  late Map<Modifier, dynamic> modifiers;
  late final Status? status;
  late final String? error;

  Attribute(
    this.key,
    this.type, {
    this.modifiers = const {},
  })  : status = null,
        error = null;

  Attribute.empty();

  Attribute.fromMap(Map<String, dynamic> attribute) {
    attribute["defaultValue"] = attribute.remove("default");

    key = attribute["key"];

    for (var type in AttributeType.values) {
      if (type.name == attribute["format"] || type.name == attribute["type"]) {
        this.type = type;
      }
    }

    modifiers = {};
    for (var modifier in Modifier.values) {
      if (attribute.containsKey(modifier.name)) {
        modifiers[modifier] = attribute[modifier.name];
      }
    }

    status = Status.values.firstWhere(
      (e) => e.name == attribute["status"],
    );

    error = attribute["error"].isEmpty ? null : attribute["error"];
  }

  @override
  Map<String, dynamic> serialize() {
    return {
      "key": key,
      "type": type.name,
      "modifiers": modifiers.map((key, value) => MapEntry(key.name, value)),
      if (status != null) "status": status!.name,
      if (error != null) "error": error,
    };
  }

  @override
  Attribute deserialize(Map<String, dynamic> data) {
    // TODO: implement deserialize
    throw UnimplementedError();
  }
}
