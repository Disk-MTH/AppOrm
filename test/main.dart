import 'dart:core';
import 'dart:io';

import 'package:app_orm/src/annotations.dart';
import 'package:app_orm/src/app_orm.dart';
import 'package:app_orm/src/entity.dart';
import 'package:app_orm/src/logger.dart';
import 'package:app_orm/src/utils.dart';
import 'package:dart_appwrite/dart_appwrite.dart';

void main() async {
  final Map<String, String> envVars = Platform.environment;
  final backend = Client()
      .setEndpoint("https://backend.diskmth.fr/v1")
      .setProject(envVars["APPWRITE_PROJECT_ID"])
      .setKey(envVars["APPWRITE_API_KEY"]);

  final databases = Databases(backend);

/*  await databases.updateCollection(
    databaseId: "65d4bcc6bfbefe3e6b61",
    collectionId: "65d4e66e94ab54bff4bf",
    name: "Address",
    permissions: [
      Permission.create(Role.any()),
      Permission.create(Role.user("exampleId")),
      Permission.create(Role.user("exampleId", "verified")),
      Permission.create(Role.user("exampleId", "unverified")),
      Permission.create(Role.users()),
      Permission.create(Role.users("verified")),
      Permission.create(Role.users("unverified")),
      Permission.create(Role.guests()),
      Permission.create(Role.team("exampleId")),
      Permission.create(Role.team("exampleId", "exampleRole")),
      Permission.create(Role.member("exampleId")),
      Permission.create(Role.label("exampleLabel")),
    ],
  ).then((value) => print(value.toMap()));*/

  final AbstractLogger logger = Logger();
  Utils.logger = logger;
  final AppOrm appOrm = AppOrm("65d4bcc6bfbefe3e6b61", databases);

  await appOrm.setup();

  for (var repo in appOrm.repositories) {
    logger.warn(repo.permissions);
  }

/*  final List<Address> addresses = await appOrm.pull();
  logger.debug(addresses);

  logger.log("-----------------------------------------\n");

  final users = await appOrm.pull<User>();
  logger.debug(users);

  logger.log("-----------------------------------------\n");

  final campuses = await appOrm.pull<Campus>();
  logger.debug(campuses);*/

  // logger.log("Finished");
  exit(0);
}

class Address extends Entity<Address> {
  @OrmString(maxLength: 100)
  late String city;

  Address.empty() : super.empty();
}

class User extends Entity<User> {
  @OrmString(isRequired: true, maxLength: 100)
  late String name;

  @OrmEntity()
  late Address home;

  @OrmEntity()
  late Campus campus;

  User.empty() : super.empty();
}

class Campus extends Entity<Campus> {
  @OrmString(isRequired: true, maxLength: 100)
  late String name;

  @OrmEntity()
  late Address address;

  @OrmEntities()
  List<User> users = [];

  Campus.empty() : super.empty();
}
