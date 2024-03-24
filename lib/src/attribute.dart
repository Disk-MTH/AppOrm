import "package:app_orm/src/utils/serializable.dart";
import "package:app_orm/src/utils/utils.dart";

import "utils/enums.dart";

class Attribute with Serializable {
  static const Map<Modifier, dynamic> defaultModifiers = {
    Modifier.required: false,
    Modifier.array: false,
    Modifier.defaultValue: null,
  };

  static const Map<AttributeType, List<Modifier>> validModifiers = {
    AttributeType.native: [],
    AttributeType.entity: [Modifier.size, Modifier.min, Modifier.max],
    AttributeType.string: [Modifier.size],
    AttributeType.integer: [Modifier.min, Modifier.max],
    AttributeType.double: [Modifier.min, Modifier.max],
    AttributeType.boolean: [],
    AttributeType.datetime: [],
    AttributeType.email: [],
    AttributeType.ip: [],
    AttributeType.url: [],
    AttributeType.enumeration: [Modifier.elements],
  };

  late String key;
  late AttributeType type;
  late Map<Modifier, dynamic> modifiers;
  late Status status;
  late String? error;

  Attribute(
    this.key,
    this.type, {
    this.modifiers = defaultModifiers,
  })  : status = Status.available,
        error = null {
    defaultModifiers.forEach((key, value) {
      if (!modifiers.containsKey(key)) modifiers[key] = value;
    });

    if (type == AttributeType.entity) modifiers[Modifier.size] = 20;

    _checkValidity();
  }

  Attribute.fromModel(Map<String, dynamic> attribute) {
    attribute["defaultValue"] = attribute.remove("default");

    key = attribute["key"];

    for (var type in AttributeType.values) {
      if (type.name == attribute["format"] || type.name == attribute["type"]) {
        this.type = type;
      }
    }

    if (key.contains("_ORM_ENTITY") && type == AttributeType.string) {
      type = AttributeType.entity;
      key = key.replaceAll("_ORM_ENTITY", "");
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

    _checkValidity();
  }

  @override
  Map<String, dynamic> serialize() {
    return {
      "key": key,
      "type": type.name,
      "modifiers": modifiers.map((key, value) => MapEntry(key.name, value)),
      "status": status.name,
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
    status = Status.values.firstWhere((e) => e.name == data["status"]);
    error = data["error"];
    _checkValidity();
    return this;
  }

  void _checkValidity() {
    if (key.isEmpty) {
      throw "Attribute key cannot be empty";
    }

    //TODO: Check if key is valid
    if (type == AttributeType.native) {
      throw "Attribute type cannot be native on \"$key\"";
    }

    for (var modifier in modifiers.keys) {
      if (modifier != Modifier.required &&
          modifier != Modifier.array &&
          modifier != Modifier.defaultValue &&
          !validModifiers[type]!.contains(modifier)) {
        throw "Attribute modifier \"${modifier.name}\" is not valid for type \"${type.name}\" on \"$key\"";
      }
    }

    if (type == AttributeType.entity) {
      if (modifiers[Modifier.size] != 20) {
        logger.warn(
          "Do not use the \"size\" modifier on \"entity\" type (\"$key\" attribute). It's a system value",
        );
        modifiers[Modifier.size] = 20;
      }
    }

    if (type == AttributeType.string) {
      if (modifiers.containsKey(Modifier.size)) {
        if (modifiers[Modifier.size] < 1) {
          throw "Attribute modifier \"size\" must be greater than 0 on \"$key\"";
        } else if (modifiers[Modifier.size] > Utils.stringMax) {
          throw "Attribute modifier \"size\" must be less than ${Utils.stringMax + 1} on \"$key\"";
        }
      } else {
        modifiers[Modifier.size] = Utils.stringMax;
      }
    }

    if (type == AttributeType.integer) {
      if (modifiers.containsKey(Modifier.min)) {
        if (modifiers[Modifier.min] < Utils.intMin) {
          throw "Attribute modifier \"min\" must greater than ${Utils.intMin - 1} on \"$key\"";
        }
      } else {
        modifiers[Modifier.min] = Utils.intMin;
      }

      if (modifiers.containsKey(Modifier.max)) {
        if (modifiers[Modifier.max] > Utils.intMax) {
          throw "Attribute modifier \"max\" must be less than ${Utils.intMax + 1} on \"$key\"";
        }
      } else {
        modifiers[Modifier.max] = Utils.intMax;
      }
    }

    if (type == AttributeType.double) {
      if (modifiers.containsKey(Modifier.min)) {
        if (modifiers[Modifier.min] < Utils.doubleMin) {
          throw "Attribute modifier \"min\" must greater than ${Utils.doubleMin - 1} on \"$key\"";
        }
      } else {
        modifiers[Modifier.min] = Utils.doubleMin;
      }

      if (modifiers.containsKey(Modifier.max)) {
        if (modifiers[Modifier.max] > Utils.doubleMax) {
          throw "Attribute modifier \"max\" must be less than ${Utils.doubleMax + 1} on \"$key\"";
        }
      } else {
        modifiers[Modifier.max] = Utils.doubleMax;
      }
    }

    if (type == AttributeType.integer || type == AttributeType.double) {
      if (modifiers[Modifier.min] > modifiers[Modifier.max]) {
        throw "Attribute modifier \"min\" must be less than \"max\" on \"$key\"";
      }
    }

    if (type == AttributeType.enumeration) {
      if (modifiers[Modifier.elements]?.isEmpty ?? true) {
        throw "Attribute modifier \"elements\" cannot be empty on \"$key\"";
      }
    }
  }
}
