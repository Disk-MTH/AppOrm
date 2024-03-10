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

  void validate(String field) {
    final String notAllowed = "not allowed for \"$field\"";

    if (modifiers[Modifier.isRequired] == true &&
        modifiers[Modifier.isArray] == true) {
      throw "[isRequired && isArray] $notAllowed";
    }

    if (modifiers[Modifier.defaultValue] != null &&
        (modifiers[Modifier.isRequired] == true ||
            modifiers[Modifier.isArray] == true)) {
      throw "[defaultValue && (isRequired || isArray)] $notAllowed";
    }

    if (modifiers[Modifier.defaultValue] != null) {
      if (type == AttributeType.native || type == AttributeType.entity) {
        throw "[defaultValue && (type == AttributeType.native || type == AttributeType.entity)] $notAllowed";
      } else if (modifiers[Modifier.defaultValue].runtimeType != type.type) {
        throw "[defaultValue.runtimeType != ${type.type}] $notAllowed";
      }
    }

    if (modifiers[Modifier.size] != null) {
      final size = modifiers[Modifier.size];

      if (type != AttributeType.string) {
        throw "[size != null && type != AttributeType.string] $notAllowed";
      } else if (size is! int) {
        throw "[size is! int] $notAllowed";
      } else if (size <= 0 || size > stringMax) {
        throw "[0 >= size > $stringMax] $notAllowed";
      }
    }

    if (modifiers[Modifier.min] != null) {
      final min = modifiers[Modifier.min];

      if (type != AttributeType.integer && type != AttributeType.double) {
        throw "[min != null && (type != AttributeType.integer && type != AttributeType.double)] $notAllowed";
      } else {
        if (type == AttributeType.integer) {
          if (min is! int) {
            throw "[min is! int] $notAllowed";
          } else if (min < intMin || min > intMax) {
            throw "[$intMin >= min > $intMax] $notAllowed";
          }
        } else {
          if (min is! double) {
            throw "[min is! double] $notAllowed";
          } else if (min < floatMin || min > floatMax) {
            throw "[$floatMin >= min > $floatMax] $notAllowed";
          }
        }
      }
    }

    if (modifiers[Modifier.max] != null) {
      final max = modifiers[Modifier.max];

      if (type != AttributeType.integer && type != AttributeType.double) {
        throw "[max != null && (type != AttributeType.integer && type != AttributeType.double)] $notAllowed";
      } else {
        if (type == AttributeType.integer) {
          if (max is! int) {
            throw "[max is! int] $notAllowed";
          } else if (max < intMin || max > intMax) {
            throw "[$intMin >= max > $intMax]$notAllowed";
          }
        } else {
          if (max is! double) {
            throw "[max is! double] $notAllowed";
          } else if (max < floatMin || max > floatMax) {
            throw "[$floatMin >= max > $floatMax] $notAllowed";
          }
        }
      }
    }

    if (modifiers[Modifier.elements] != null) {
      if (type != AttributeType.enumeration) {
        throw "[elements != null && type != AttributeType.enumeration] $notAllowed";
      } else if (modifiers[Modifier.elements] is! List<String>) {
        throw "[elements is! List<String>] $notAllowed";
      }
    }
  }
}
