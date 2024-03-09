import 'dart:core';
import 'dart:io';

import 'package:app_orm/src/app_orm.dart';
import 'package:app_orm/src/entity.dart';
import 'package:app_orm/src/enums.dart';
import 'package:app_orm/src/logger.dart';
import 'package:app_orm/src/orm.dart';
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

/*  final campuses = await appOrm.pull<Campus>();
  logger.debug(campuses);*/

  final test = await appOrm.pull<Address>();
  // logger.debug(test);

  // logger.log("Finished");
  exit(0);
}

class Address extends Entity<Address> {
  @Orm(AttributeType.string, modifiers: {
    Modifier.isRequired: true,
    Modifier.size: 100,
  })
  late String city;

  Address.empty() : super.empty();
}

class User extends Entity<User> {
  @Orm(AttributeType.string, modifiers: {
    Modifier.isRequired: true,
    Modifier.size: 100,
  })
  late String name;

  @Orm(AttributeType.entity)
  late Address home;

  @Orm(AttributeType.entity)
  late Campus campus;

  User.empty() : super.empty();
}

class Campus extends Entity<Campus> {
  @Orm(AttributeType.string, modifiers: {
    Modifier.defaultValue: 12,
  })
  late String name;

  @Orm(AttributeType.entity)
  late Address address;

  @Orm(AttributeType.entity, modifiers: {Modifier.isArray: true})
  List<User> users = [];

  Campus.empty() : super.empty();
}

class Test extends Entity<Test> {
  Test.empty() : super.empty();
}
