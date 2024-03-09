import "enums.dart";

class Orm {
  static const int stringMax = 1073741824;

  static const int intMin = -intMax;
  static const int intMax = 9223372036854775807;

  static const double floatMin = -floatMax;
  static const double floatMax = 1.7976931348623157e+308;

  final AttributeType type;
  final Map<Modifier, dynamic> modifiers;

  const Orm(
    this.type, {
    this.modifiers = const {},
  });

  void validate() {
    if (modifiers[Modifier.isRequired] == true &&
        modifiers[Modifier.isArray] == true) {
      throw "[isRequired && isArray] not allowed";
    }

    if (modifiers[Modifier.defaultValue] != null &&
        (modifiers[Modifier.isRequired] == true ||
            modifiers[Modifier.isArray] == true)) {
      throw "[defaultValue && (isRequired || isArray)] not allowed";
    }

    if (modifiers[Modifier.defaultValue] != null) {
      if (type == AttributeType.native || type == AttributeType.entity) {
        throw "[defaultValue && (type == AttributeType.native || type == AttributeType.entity)] not allowed";
      } else if (modifiers[Modifier.defaultValue].runtimeType != type.type) {
        throw "[defaultValue.runtimeType != ${type.type}] not allowed";
      }
    }

    if (modifiers[Modifier.size] != null) {
      final size = modifiers[Modifier.size];

      if (type != AttributeType.string) {
        throw "[size != null && type != AttributeType.string] not allowed";
      } else if (size is! int) {
        throw "[size is! int] not allowed";
      } else if (size <= 0 || size > stringMax) {
        throw "[0 >= size > $stringMax] not allowed";
      }
    }

    if (modifiers[Modifier.min] != null) {
      final min = modifiers[Modifier.min];

      if (type != AttributeType.integer && type != AttributeType.double) {
        throw "[min != null && (type != AttributeType.integer && type != AttributeType.double)] not allowed";
      } else {
        if (type == AttributeType.integer) {
          if (min is! int) {
            throw "[min is! int] not allowed";
          } else if (min < intMin || min > intMax) {
            throw "[$intMin >= min > $intMax] not allowed";
          }
        } else {
          if (min is! double) {
            throw "[min is! double] not allowed";
          } else if (min < floatMin || min > floatMax) {
            throw "[$floatMin >= min > $floatMax] not allowed";
          }
        }
      }
    }

    if (modifiers[Modifier.max] != null) {
      final max = modifiers[Modifier.max];

      if (type != AttributeType.integer && type != AttributeType.double) {
        throw "[max != null && (type != AttributeType.integer && type != AttributeType.double)] not allowed";
      } else {
        if (type == AttributeType.integer) {
          if (max is! int) {
            throw "[max is! int] not allowed";
          } else if (max < intMin || max > intMax) {
            throw "[$intMin >= max > $intMax] not allowed";
          }
        } else {
          if (max is! double) {
            throw "[max is! double] not allowed";
          } else if (max < floatMin || max > floatMax) {
            throw "[$floatMin >= max > $floatMax] not allowed";
          }
        }
      }
    }

    if (modifiers[Modifier.elements] != null) {
      if (type != AttributeType.enumeration) {
        throw "[elements != null && type != AttributeType.enumeration] not allowed";
      } else if (modifiers[Modifier.elements] is! List<String>) {
        throw "[elements is! List<String>] not allowed";
      }
    }
  }
}
