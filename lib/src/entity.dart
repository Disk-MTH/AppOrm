import "dart:mirrors";

import "package:app_orm/src/annotations.dart";
import "package:app_orm/src/identifiable.dart";
import "package:app_orm/src/utils.dart";
import "package:dart_appwrite/models.dart";

abstract class Entity extends Identifiable<Document> {
  Entity(Document document) : super(document) {
    Reflection.listClassFields(runtimeType).forEach((name, mirror) {
      final InstanceMirror? metadata =
          mirror.metadata.where((e) => e.reflectee is OrmAttribute).firstOrNull;

      if (metadata == null) return;

      final OrmAttribute annotation = metadata.reflectee;
      annotation.validate();

      final value =
          document.data[annotation.runtimeType == OrmNative ? "\$$name" : name];

      if (annotation.runtimeType != OrmNative &&
          annotation.runtimeType != OrmEntity) {
        if (value == null && (annotation.isRequired || annotation.isArray)) {
          throw "Field \"$name\" is not nullable";
        }
        Reflection.setFieldValue(this, mirror, value);
      }
    });
  }

//TODO: Test this method
/*  static T mutate<T extends Entity>(T entity, Map<String, dynamic> data) {
    final fields = Reflection.listInstanceFields(entity);

    fields.forEach((name, reflectedVariable) {
      if (data.containsKey(name)) reflectedVariable.value = data[name];
    });

    return entity;
  }*/
}

class Address extends Entity {
  @OrmString(maxLength: 100)
  late String city;

  Address(super.document);
}

class User extends Entity {
  @OrmString(isRequired: true, maxLength: 100)
  late String name;

  @OrmEntity(type: Address)
  late Address address;

  User(super.model);
}
