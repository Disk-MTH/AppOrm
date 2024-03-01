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

  final List<Address> addresses = await appOrm.pull();
  logger.debug(addresses);

  logger.log("-----------------------------------------\n");

  final users = await appOrm.pull<User>();
  logger.debug(users);

  logger.log("-----------------------------------------\n");

  final campuses = await appOrm.pull<Campus>();
  logger.debug(campuses);

  logger.log("Finished");
  exit(0);
}

class Address extends Entity<Address> {
  @OrmString(maxLength: 100)
  late String _city;

  Address.empty() : super.empty();

  get city => _city;
}

class User extends Entity<User> {
  @OrmString(isRequired: true, maxLength: 100)
  late String _name;

  @OrmEntity()
  late Address _home;

  @OrmEntity()
  late Campus _campus;

  User.empty() : super.empty();

  get name => _name;

  get home => _home;

  get campus => _campus;
}

class Campus extends Entity<Campus> {
  @OrmString(isRequired: true, maxLength: 100)
  late String _name;

  @OrmEntity()
  late Address _address;

  @OrmEntities()
  final List<User> _users = [];

  Campus.empty() : super.empty();

  get name => _name;

  get address => _address;

  get users => _users;
}
