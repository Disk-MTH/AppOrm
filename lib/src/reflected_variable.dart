import "dart:mirrors";

class ReflectedVariable {
  final VariableMirror variableMirror;
  dynamic value;

  ReflectedVariable(this.variableMirror, this.value);
}
