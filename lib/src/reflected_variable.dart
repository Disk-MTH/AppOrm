import 'dart:mirrors';

class ReflectedVariable {
  final VariableMirror variableMirror;
  final dynamic value;

  const ReflectedVariable(this.variableMirror, this.value);
}
