import 'package:app_orm/src/utils/serializable.dart';

import 'utils/enums.dart';

class Attribute with Serializable<Attribute> {
  static const Map<Modifier, dynamic> defaultModifiers = {
    Modifier.required: false,
    Modifier.array: false,
    Modifier.defaultValue: null,
  };

  late String key;
  late AttributeType type;
  late Map<Modifier, dynamic> modifiers;
  late Status? status;
  late String? error;

  Attribute(
    this.key,
    this.type, {
    this.modifiers = defaultModifiers,
  })  : status = null,
        error = null {
    defaultModifiers.forEach((key, value) {
      if (!modifiers.containsKey(key)) modifiers[key] = value;
    });
  }

  Attribute.empty();

  Attribute.fromModel(Map<String, dynamic> attribute) {
    attribute["defaultValue"] = attribute.remove("default");

    key = attribute["key"];

    for (var type in AttributeType.values) {
      if (type.name == attribute["format"] || type.name == attribute["type"]) {
        this.type = type;
      }
    }

    modifiers = Map.from(defaultModifiers);
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
      "status": status?.name,
      "error": error,
    };
  }

  @override
  Attribute deserialize(Map<String, dynamic> data) {
    key = data["key"];
    type = AttributeType.values.firstWhere((e) => e.name == data["type"]);
    modifiers = Map.from(defaultModifiers);
    data["modifiers"].forEach((key, value) {
      modifiers[Modifier.values.firstWhere((e) => e.name == key)] = value;
    });
    status = Status.values.where((e) => e.name == data["status"]).firstOrNull;
    error = data["error"];
    return this;
  }

  @override
  bool equals(Serializable other) {
    return other is Attribute &&
        other.key == key &&
        other.type == type &&
        other.modifiers.length == modifiers.length &&
        !other.modifiers.entries.any((o) => !modifiers.entries
            .any((e) => o.key == e.key && o.value == e.value));
  }
}
