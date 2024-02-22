abstract class OrmAttribute<T> {
  final bool isRequired;
  final bool isArray;
  final dynamic defaultValue;

  const OrmAttribute({
    this.isRequired = false,
    this.isArray = false,
    this.defaultValue,
  });

  void validate() {
    if (isRequired && isArray) {
      throw "Field cannot be required and an array at the same time";
    }

    if (isRequired && defaultValue != null) {
      throw "Required field cannot have a default value";
    }

    if (isArray && defaultValue != null) {
      throw "Array field cannot have a default value";
    }

    if (defaultValue != null && defaultValue is! T) {
      throw "Default value must be of type $T";
    }
  }
}

abstract class OrmNumber<T extends num> extends OrmAttribute<T> {
  final num min;
  final num max;

  const OrmNumber({
    super.isRequired = true,
    super.isArray = false,
    super.defaultValue,
    required this.min,
    required this.max,
  });

  @override
  void validate() {
    super.validate();

    if (T is! int && T is! double) {
      throw "Unsupported number type";
    }

    if (min > max) {
      throw "Min must be less than max";
    }
  }
}

class OrmNative extends OrmAttribute {
  const OrmNative({
    super.isRequired = true,
  });
}

class OrmEntity extends OrmAttribute {
  final Type type;

  const OrmEntity({
    super.isRequired = true,
    required this.type,
  });
}

class OrmString extends OrmAttribute<String> {
  static const int stringMax = 1073741824;

  final int maxLength;

  const OrmString({
    super.isRequired,
    super.isArray,
    super.defaultValue,
    this.maxLength = stringMax,
  });

  @override
  void validate() {
    super.validate();
    if (maxLength < 1 || maxLength > stringMax) {
      throw "Max length must be between 1 and $stringMax";
    }
  }
}

class OrmInteger extends OrmNumber<int> {
  static const int intMin = -intMax;
  static const int intMax = 9223372036854775807;

  const OrmInteger({
    super.isRequired = true,
    super.isArray = false,
    super.defaultValue,
    super.min = intMin,
    super.max = intMax,
  });

  @override
  void validate() {
    super.validate();
    if (min < intMin || max > intMax) {
      throw "Min and max must be between $intMin and $intMax";
    }
  }
}

class OrmFloat extends OrmNumber<double> {
  static const double floatMin = -floatMax;
  static const double floatMax = 1.7976931348623157e+308;

  const OrmFloat({
    super.isRequired = true,
    super.isArray = false,
    super.defaultValue,
    super.min = floatMin,
    super.max = floatMax,
  });

  @override
  void validate() {
    super.validate();
    if (min < floatMin || max > floatMax) {
      throw "Min and max must be between $floatMin and $floatMax";
    }
  }
}

class OrmBoolean extends OrmAttribute<bool> {
  const OrmBoolean({
    super.isRequired = true,
    super.isArray = false,
    super.defaultValue,
  });
}
