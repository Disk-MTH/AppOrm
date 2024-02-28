import 'dart:core';
import 'dart:io';

import 'package:app_orm/src/annotations.dart';
import 'package:app_orm/src/app_orm.dart';
import 'package:app_orm/src/entity.dart';
import 'package:app_orm/src/logger.dart';
import 'package:app_orm/src/serializable.dart';
import 'package:dart_appwrite/dart_appwrite.dart';

void main() async {
  final Map<String, String> envVars = Platform.environment;
  final backend = Client()
      .setEndpoint("https://backend.diskmth.fr/v1")
      .setProject(envVars["APPWRITE_PROJECT_ID"])
      .setKey(envVars["APPWRITE_API_KEY"]);

  final databases = Databases(backend);

  final AbstractLogger logger = Logger();
  Serializable.logger = logger;
  final AppOrm appOrm = AppOrm("65d4bcc6bfbefe3e6b61", databases);

  await appOrm.setup();

/*  final List<Address> addresses = await appOrm.list(ids: [
    // "65d5167ebb7ac240e08f",
    // "65d5e0e793d9f2e4c538",
  ]);*/

/*  for (var address in addresses) {
    address.debug();
  }*/

  final users = await appOrm.list<User>();

  for (var user in users) {
    logger.debug(user);
  }

  logger.log("Finished");
  exit(0);
}

class Address extends Entity<Address> {
  @OrmString(maxLength: 100)
  late String _city;

  Address.empty() : super.empty();

  Address(this._city) : super.empty();

  get city => _city;

  // set setCity(String value) => _city = value;
}

class User extends Entity<User> {
  @OrmString(isRequired: true, maxLength: 100)
  late String _name;

  @OrmEntity()
  late Address _home;

  @OrmEntity()
  late Address _work;

  @OrmEntities()
  final List<Address> _holidays = [];

  User.empty() : super.empty();

  get name => _name;

  get home => _home;

  get work => _work;

  get holidays => _holidays;
}
