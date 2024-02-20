import "dart:math";
import "dart:mirrors";

import "package:app_orm/src/reflected_variable.dart";

class Utils {
  static final Random random = Random(DateTime.now().millisecondsSinceEpoch);
  static const String idCharset = "abcdefghijklmnopqrstuvwxyz0123456789";

  static String uniqueId() {
    return List.generate(20, (_) => idCharset[random.nextInt(idCharset.length)])
        .join();
  }

  static String camelCaseToSnakeCase(String input) {
    return input
        .replaceAllMapped(
          RegExp(r"(?<=[a-z])[A-Z]"),
          (Match match) => "_${match.group(0)!.toLowerCase()}",
        )
        .toLowerCase();
  }
}

class Reflection {
  static bool isSubtype<T>(Type type) {
    ClassMirror? cm = reflectClass(type);

    while (cm != null && cm != reflectClass(Object)) {
      if (cm == reflectClass(T)) {
        return true;
      }
      cm = cm.superclass;
    }

    return false;
  }

  static Map<String, VariableMirror> fieldsFromClass(Type type) {
    final fields = <String, VariableMirror>{};
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
    final fields = <String, ReflectedVariable>{};
    final classFields = fieldsFromClass(instance.runtimeType);
    final InstanceMirror im = reflect(instance);

    classFields.forEach((name, variableMirror) {
      fields[name] = ReflectedVariable(
        variableMirror,
        im.getField(variableMirror.simpleName).reflectee,
      );
    });

    return fields;
  }
}
