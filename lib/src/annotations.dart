abstract class _OrmAttribute {
  final bool required;
  final bool isArray;

  const _OrmAttribute({
    this.required = false,
    this.isArray = false,
  });
}

class OrmString extends _OrmAttribute {
  final int maxLength;

  const OrmString({
    super.required,
    super.isArray,
    required this.maxLength,
  });
}
