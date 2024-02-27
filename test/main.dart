import 'dart:core';
import 'dart:io';

import 'package:app_orm/src/annotations.dart';
import 'package:app_orm/src/app_orm.dart';
import 'package:app_orm/src/entity.dart';
import 'package:app_orm/src/logger.dart';
import 'package:dart_appwrite/dart_appwrite.dart';

void main() async {
  final Map<String, String> envVars = Platform.environment;
  final backend = Client()
      .setEndpoint("https://backend.diskmth.fr/v1")
      .setProject(envVars["APPWRITE_PROJECT_ID"])
      .setKey(envVars["APPWRITE_API_KEY"]);

  final databases = Databases(backend);

  final AbstractLogger logger = Logger();
  final AppOrm appOrm = AppOrm(
    "65d4bcc6bfbefe3e6b61",
    databases,
    logger: logger,
  );

  await appOrm.setup();

  final List<Address> addresses = await appOrm.list(ids: [
    // "65d5167ebb7ac240e08f",
    // "65d5e0e793d9f2e4c538",
  ]);

  for (var address in addresses) {
    // print(address.serialize());
    address.debug();
  }

  final List<User> users = await appOrm.list();

  for (var user in users) {
    // print(user.serialize());
    user.debug();
  }

  /*final Repository<Address> addressRepo = appOrm.getRepository<Address>();
  final List<Address> addresses = await addressRepo.list();

  for (var address in addresses) {
    print(address.toMap());
  }

  final Repository<User> userRepo = appOrm.getRepository<User>();
  final List<User> users = await userRepo.list();

  for (var user in users) {
    print(user.toMap());
  }*/

/*  final Map<String, dynamic> data = await databases
      .getDocument(
        databaseId: "65d4bcc6bfbefe3e6b61",
        collectionId: "65d4e66e94ab54bff4bf",
        documentId: "65d5e0e793d9f2e4c538",
      )
      .then((value) => value.data);

  final Address identifiable = Address.empty().deserialize(data);

  final Address identifiable = Address("Test");

  print(identifiable.serialize());*/

  logger.log("Finished");
  exit(0);
}

class Address extends Entity<Address> {
  @OrmString(maxLength: 100)
  late String _city;

  Address.empty() : super.empty();

  Address(this._city) : super.empty();

  get city => _city;

  set setCity(String value) => _city = value;
}

class User extends Entity<User> {
  @OrmString(isRequired: true, maxLength: 100)
  late String _name;

  @OrmEntity(type: Address)
  late Address _home;

  User.empty() : super.empty();

  // User.construct() : super.construct();

  get name => _name;

  get address => _home;
}
