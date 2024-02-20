import "dart:io";

import "package:app_orm/app_orm.dart";
import "package:dart_appwrite/dart_appwrite.dart";

void main() {
  final Map<String, String> envVars = Platform.environment;
  final backend = Client()
      .setEndpoint("https://backend.diskmth.fr/v1")
      .setProject(envVars["APPWRITE_PROJECT_ID"])
      .setKey(envVars["APPWRITE_API_KEY"]);

  final EntityManager entityManager = EntityManager(backend);

  entityManager.pushModel([Address]);
}
