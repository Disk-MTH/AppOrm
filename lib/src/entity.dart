import "package:app_orm/src/annotations.dart";
import "package:app_orm/src/identifiable.dart";
import "package:app_orm/src/utils.dart";
import "package:dart_appwrite/models.dart";

abstract class Entity extends Identifiable<Document> {
/*  Entity({
    required super.id,
  });*/

  Entity(Document document) : super(document) {
    //fill this entity with data from document
    final fields = Reflection.listClassFields(runtimeType);

    fields.forEach((name, mirror) {
      final value = document.data[name];

      //TODO: add support for null/non-nullable fields
      if (value != null) {
        Reflection.setFieldValue(this, mirror, value);
      }
    });
  }

  //TODO: Test this method
  static T mutate<T extends Entity>(T entity, Map<String, dynamic> data) {
    final fields = Reflection.listInstanceFields(entity);

    fields.forEach((name, reflectedVariable) {
      if (data.containsKey(name)) reflectedVariable.value = data[name];
    });

    return entity;
  }
}

class Address extends Entity {
  @OrmString(maxLength: 100)
  late String city;

  Address(super.document);

  /*Address({
    required super.id,
    required this.city,
  });*/
}

class User extends Entity {
  @OrmString(maxLength: 100)
  late String name;

  Address? address;

  User(super.model);

  /*User({
    required super.id,
    required this.name,
    required this.address,
  });*/
}
