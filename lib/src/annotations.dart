abstract class OrmAttribute {
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
  }
}

class OrmString extends OrmAttribute {
  final int maxLength;

  const OrmString({
    super.isRequired,
    super.isArray,
    super.defaultValue,
    required this.maxLength,
  });
}

class OrmEntity extends OrmAttribute {
  final Type type;

  const OrmEntity({
    super.isRequired = true,
    required this.type,
  });
}
