import 'dart:core';
import 'dart:io';

import 'package:app_orm/src/annotations.dart';
import 'package:app_orm/src/app_orm.dart';
import 'package:app_orm/src/entity.dart';
import 'package:app_orm/src/logger.dart';
import 'package:app_orm/src/repository.dart';
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
    // Memory(),
    logger: logger,
  );

  await appOrm.setup([
    Repository<Address>(),
    Repository<User>(),
  ]);

  final Repository<Address> addressRepo = appOrm.getRepository<Address>();
  final List<Address> addresses = await addressRepo.list();

  for (var address in addresses) {
    print(address.toMap());
  }

  final Repository<User> userRepo = appOrm.getRepository<User>();
  final List<User> users = await userRepo.list();

  for (var user in users) {
    print(user.toMap());
  }

  logger.log("Finished");
  exit(0);
}

class Address extends Entity {
  @OrmString(maxLength: 100)
  late String _city;

  Address(super.document);

  get city => _city;
}

class User extends Entity {
  @OrmString(isRequired: true, maxLength: 100)
  late String _name;

  @OrmEntity(type: Address)
  late Address _address;

  User(super.document);

  get name => _name;
  get address => _address;
}
