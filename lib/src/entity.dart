import "package:app_orm/src/annotations.dart";

abstract class Entity {
  String id;
/*  String collectionId;
  String databaseId;
  DateTime createdAt;
  DateTime updatedAt;
  List permissions;*/

  Entity({
    required this.id,
  });

  Entity.none() : id = "";

  Entity empty();
}

class Address extends Entity {
  @StringAttribute(maxLength: 20)
  String city;

  Address({
    required super.id,
    required this.city,
  });

  @override
  Address empty() {
    return Address(id: "", city: "");
  }
}

class User extends Entity {
  String name;
  Address? address;

  User({
    required super.id,
    required this.name,
    required this.address,
  });

  @override
  User empty() {
    return User(id: "", name: "", address: null);
  }
}
