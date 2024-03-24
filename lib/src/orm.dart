import "utils/enums.dart";

class Orm {
  final AttributeType type;
  final Map<Modifier, dynamic> modifiers;

  const Orm(
    this.type, {
    this.modifiers = const {},
  });
}
