import "package:app_orm/src/utils/utils.dart";

import 'utils/enums.dart';

class Orm {
  final AttributeType type;
  final Map<Modifier, dynamic> modifiers;

  const Orm(
    this.type, {
    this.modifiers = const {},
  });

  void validate(String field) {
    final String notAllowed = "not allowed for \"$field\"";

    if (modifiers[Modifier.required] == true &&
        modifiers[Modifier.array] == true) {
      throw "[isRequired && isArray] $notAllowed";
    }

    if (modifiers[Modifier.defaultValue] != null &&
        (modifiers[Modifier.required] == true ||
            modifiers[Modifier.array] == true)) {
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
      } else if (size <= 0 || size > Utils.stringMax) {
        throw "[0 >= size > ${Utils.stringMax}] $notAllowed";
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
          } else if (min < Utils.intMin || min > Utils.intMax) {
            throw "[${Utils.intMin} >= min > ${Utils.intMax}] $notAllowed";
          }
        } else {
          if (min is! double) {
            throw "[min is! double] $notAllowed";
          } else if (min < Utils.floatMin || min > Utils.floatMax) {
            throw "[${Utils.floatMin} >= min > ${Utils.floatMax}] $notAllowed";
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
          } else if (max < Utils.intMin || max > Utils.intMax) {
            throw "[${Utils.intMin} >= max > ${Utils.intMax}]$notAllowed";
          }
        } else {
          if (max is! double) {
            throw "[max is! double] $notAllowed";
          } else if (max < Utils.floatMin || max > Utils.floatMax) {
            throw "[${Utils.floatMin} >= max > ${Utils.floatMax}] $notAllowed";
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
