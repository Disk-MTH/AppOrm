import "dart:mirrors";

import "package:app_orm/src/reflected_variable.dart";

class Reflection {
  static bool isSubtype(Type type, Type parent) {
    return reflectClass(type).isSubclassOf(reflectClass(parent));
  }

  static Map<String, VariableMirror> listClassFields(
    Type type, {
    Type? annotation,
  }) {
    final fields = <String, VariableMirror>{};
    ClassMirror? cm = reflectClass(type);

    while (cm != null && cm != reflectClass(Object)) {
      cm.declarations.forEach((key, value) {
        if (value is VariableMirror) fields[MirrorSystem.getName(key)] = value;
      });
      cm = cm.superclass;
    }

    fields.removeWhere((key, value) {
      return annotation != null &&
          value.metadata
              .where((e) => e.type.reflectedType == annotation)
              .isEmpty;
    });

    return fields;
  }

  static Map<String, ReflectedVariable> listInstanceFields(dynamic instance) {
    final fields = <String, ReflectedVariable>{};
    final InstanceMirror im = reflect(instance);

    listClassFields(instance.runtimeType).forEach((name, variableMirror) {
      fields[name] = ReflectedVariable(
        variableMirror,
        im.getField(variableMirror.simpleName).reflectee,
      );
    });

    return fields;
  }

  static dynamic getField(dynamic instance, String name) {
    return reflect(instance).getField(Symbol(name)).reflectee;
  }

  static void setFieldValue(
    dynamic instance,
    dynamic value, {
    String? name,
    VariableMirror? mirror,
  }) {
    if ((name == null && mirror == null) || (name != null && mirror != null)) {
      throw "You must provide a field OR a variable mirror";
    }

    reflect(instance).setField(
      name != null ? Symbol(name) : mirror!.simpleName,
      value,
    );
  }

  static dynamic instantiate(
    Type type, {
    String constructor = "",
    List<dynamic> args = const [],
  }) {
    return reflectClass(type).newInstance(Symbol(constructor), args).reflectee;
  }

  static Type typeByName(String typeName) {
    return MirrorSystem.getSymbol(typeName).runtimeType;
  }
}
