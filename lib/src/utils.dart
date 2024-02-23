import "dart:convert";
import "dart:math";
import "dart:mirrors";

import "package:app_orm/src/reflected_variable.dart";
import "package:dart_appwrite/models.dart";

class Utils {
  static final Random random = Random(DateTime.now().millisecondsSinceEpoch);
  static const String idCharset = "abcdefghijklmnopqrstuvwxyz0123456789";

  static String uniqueId() {
    return List.generate(20, (_) => idCharset[random.nextInt(idCharset.length)])
        .join();
  }

  static String beautify(dynamic input) {
    if (input is Model) input = input.toMap();
    if (input is List<Model>) input = input.map((e) => e.toMap()).toList();

    return input is Map<String, dynamic> || input is List<Map<String, dynamic>>
        ? "\n${JsonEncoder.withIndent("  ").convert(input)}"
        : input.toString();
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

  static Map<String, VariableMirror> listClassFields(Type type) {
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

  static Map<String, ReflectedVariable> listInstanceFields(Object instance) {
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

  static void setFieldValue(
    Object instance,
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

  static I instantiate<I>({
    String constructor = "",
    List<dynamic> args = const [],
  }) {
    return reflectClass(I).newInstance(Symbol(constructor), args).reflectee;
  }
}
