import 'dart:core';
import 'dart:io';

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

  final EntityManager entityManager = EntityManager(
    backend,
    "65d4bcc6bfbefe3e6b61",
  );
  final AbstractLogger logger = entityManager.logger;

  await entityManager.initialize([Address, User]);
  await entityManager.pull();

  entityManager.logger.log("Finished");
  exit(0);

/*  final Collection repository = entityManager.getRepository<AddressTest>();
  repository.list().then((value) {
    logger.log(value);
  });*/
}
