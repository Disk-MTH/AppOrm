import "package:app_orm/src/annotations.dart";
import "package:app_orm/src/identifiable.dart";
import "package:app_orm/src/utils.dart";

abstract class Entity extends Identifiable {
  Entity({
    required super.id,
  });

  //TODO: Test this method
  static T mutate<T extends Entity>(T entity, Map<String, dynamic> data) {
    final fields = Reflection.fieldsFromInstance(entity);

    fields.forEach((name, reflectedVariable) {
      if (data.containsKey(name)) reflectedVariable.value = data[name];
    });

    return entity;
  }
}

class Address extends Entity {
  @OrmString(maxLength: 20)
  String city;

  Address({
    required super.id,
    required this.city,
  });
}

class Usere extends Entity {
  String name;
  // Address? address;

  Usere({
    required super.id,
    required this.name,
    // required this.address,
  });
}
