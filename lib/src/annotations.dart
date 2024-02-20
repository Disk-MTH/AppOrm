abstract class _Attribute {
  final bool required;
  final bool isArray;

  const _Attribute({
    this.required = false,
    this.isArray = false,
  });
}

class StringAttribute extends _Attribute {
  final int maxLength;

  const StringAttribute({
    super.required,
    super.isArray,
    required this.maxLength,
  });
}
