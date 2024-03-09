import 'dart:core';
import 'dart:io';

import 'package:app_orm/src/annotations.dart';
import 'package:app_orm/src/app_orm.dart';
import 'package:app_orm/src/entity.dart';
import 'package:app_orm/src/enums.dart';
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

  final AbstractLogger logger = Logger();
  Utils.logger = logger;
  final AppOrm appOrm = AppOrm("65d4bcc6bfbefe3e6b61", databases);

  await appOrm.setup();

  logger.warn("-------------------------------------------------");

  for (var repo in appOrm.repositories) {
    // logger.debug(repo.attributes);
  }

/*  final List<Address> addresses = await appOrm.pull();
  logger.debug(addresses);

  logger.log("-----------------------------------------\n");

  final users = await appOrm.pull<User>();
  logger.debug(users);

  logger.log("-----------------------------------------\n");

  final campuses = await appOrm.pull<Campus>();
  logger.debug(campuses);*/

  final users = await appOrm.pull<User>();
  logger.debug(users);

  // logger.log("Finished");
  exit(0);
}

class Address extends Entity<Address> {
  @OrmTest(AttributeType.string, modifiers: {
    Modifier.required: true,
    Modifier.size: 100,
  })
  late String city;

  Address.empty() : super.empty();
}

class User extends Entity<User> {
  @OrmTest(AttributeType.string, modifiers: {
    Modifier.required: true,
    Modifier.size: 100,
  })
  late String name;

  @OrmTest(AttributeType.entity)
  late Address home;

  @OrmTest(AttributeType.entity)
  late Campus campus;

  User.empty() : super.empty();
}

class Campus extends Entity<Campus> {
  @OrmTest(AttributeType.string)
  late String name;

  @OrmTest(AttributeType.entity)
  late Address address;

  @OrmTest(AttributeType.entity, modifiers: {
    Modifier.array: true,
  })
  List<User> users = [];

  Campus.empty() : super.empty();
}

class Test extends Entity<Test> {
  @OrmString(isRequired: true, maxLength: 100)
  late String string_1;

  @OrmString(maxLength: 100)
  late String string_2;

  @OrmString(maxLength: 100, defaultValue: "test")
  late String string_3;

  @OrmTest(AttributeType.string)
  late String string_4;

  Test.empty() : super.empty();
}
