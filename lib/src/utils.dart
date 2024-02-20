import "dart:mirrors";

import "../app_orm.dart";

class Utils {
  static bool isSubtype<T>(Type type) {
    ClassMirror cm = reflectClass(type);

    while (cm.superclass != null && cm.superclass != reflectClass(Object)) {
      cm = cm.superclass!;
      if (cm == reflectClass(T)) {
        return true;
      }
    }

    return false;
  }

  static Map<String, VariableMirror> fieldsFromClass(Type type) {
    final Map<String, VariableMirror> fields = {};
    ClassMirror? cm = reflectClass(type);

    while (cm != null && cm != reflectClass(Object)) {
      cm.declarations.forEach((key, value) {
        if (value is VariableMirror) fields[MirrorSystem.getName(key)] = value;
      });
      cm = cm.superclass;
    }

    return fields;
  }

  static Map<String, ReflectedVariable> fieldsFromInstance(Object instance) {
    final Map<String, ReflectedVariable> fields = {};
    final classFields = fieldsFromClass(instance.runtimeType);
    final im = reflect(instance);

    classFields.forEach((name, variableMirror) {
      fields[name] = ReflectedVariable(
        variableMirror,
        im.getField(variableMirror.simpleName).reflectee,
      );
    });

    return fields;
  }
}
