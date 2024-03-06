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
      Permission.create(role.dart.any()),
      Permission.create(role.dart.user("exampleId")),
      Permission.create(role.dart.user("exampleId", "verified")),
      Permission.create(role.dart.user("exampleId", "unverified")),
      Permission.create(role.dart.users()),
      Permission.create(role.dart.users("verified")),
      Permission.create(role.dart.users("unverified")),
      Permission.create(role.dart.guests()),
      Permission.create(role.dart.team("exampleId")),
      Permission.create(role.dart.team("exampleId", "exampleRole")),
      Permission.create(role.dart.member("exampleId")),
      Permission.create(role.dart.label("exampleLabel")),
    ],
  ).then((value) => print(value.$permissions));*/

  final AbstractLogger logger = Logger();
  Utils.logger = logger;
  final AppOrm appOrm = AppOrm("65d4bcc6bfbefe3e6b61", databases);

  await appOrm.setup();

  final perm = [
    "create(\"any\")",
    "create(\"user:exampleId\")",
    "create(\"user:exampleId/verified\")",
    "create(\"user:exampleId/unverified\")",
    "create(\"users\")",
    "create(\"users/verified\")",
    "create(\"users/unverified\")",
    "create(\"guests\")",
    "create(\"team:exampleId\")",
    "create(\"team:exampleId/exampleRole\")",
    "create(\"member:exampleId\")",
    "create(\"label:exampleLabel\")",
  ];

  for (var p in perm) {
    logger.warn(p);
  }

  logger.warn("-------------------------------------------------");

  for (var repo in appOrm.repositories) {
    for (var permission in repo.permissions) {
      logger.warn(permission.toString());
    }
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
