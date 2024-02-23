import 'dart:core';
import 'dart:io';

import 'package:app_orm/src/annotations.dart';
import 'package:app_orm/src/entity.dart';
import 'package:app_orm/src/entity_manager.dart';
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
  final EntityManager entityManager = await EntityManager.create(
    databases,
    "65d4bcc6bfbefe3e6b61",
    logger,
  );

  print(entityManager.toMap());

  final addressRepo = await entityManager.getRepository<Address>();
  final userRepo = await entityManager.getRepository<User>();

  addressRepo.list().then((value) => print(value));

  logger.log("Finished");
  exit(0);
}

class Address extends Entity {
  @OrmString(maxLength: 100)
  late String _city;
  get city => _city;

  Address(super.document);
}

class User extends Entity {
  @OrmString(isRequired: true, maxLength: 100)
  late String _name;
  get name => _name;

  @OrmEntity(type: Address)
  late Address _address;
  get address => _address;

  User(super.model);
}
