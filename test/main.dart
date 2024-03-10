import "dart:core";
import "dart:io";

import "package:app_orm/src/appwrite_orm.dart";
import "package:app_orm/src/entity.dart";
import "package:app_orm/src/index.dart";
import "package:app_orm/src/orm.dart";
import "package:app_orm/src/permission.dart" as permission;
import "package:app_orm/src/repository.dart";
import 'package:app_orm/src/utils/enums.dart' as enums;
import 'package:app_orm/src/utils/enums.dart';
import 'package:app_orm/src/utils/logger.dart';
import "package:app_orm/src/utils/utils.dart";
import "package:dart_appwrite/dart_appwrite.dart";

void main() async {
  final Map<String, String> envVars = Platform.environment;
  final backend = Client()
      .setEndpoint("https://backend.diskmth.fr/v1")
      .setProject(envVars["APPWRITE_PROJECT_ID"])
      .setKey(envVars["APPWRITE_API_KEY"]);

  final databases = Databases(backend);

  final AbstractLogger logger = Logger();
  Utils.logger = logger;

  final AppwriteOrm appOrm = AppwriteOrm("65d4bcc6bfbefe3e6b61", databases);
  await appOrm.setup([
    Repository<Teste>(
      documentSecurity: true,
      enabled: false,
      permissions: [
        permission.Permission(Crud.create, enums.Role.any),
        permission.Permission(Crud.create, enums.Role.user, id: "exampleId"),
        permission.Permission(
          Crud.create,
          enums.Role.user,
          id: "exampleId",
          resource: Verification.verified,
        ),
        permission.Permission(
          Crud.create,
          enums.Role.user,
          id: "exampleId",
          resource: Verification.unverified,
        ),
        permission.Permission(Crud.create, enums.Role.users),
        permission.Permission(
          Crud.create,
          enums.Role.users,
          resource: Verification.verified,
        ),
        permission.Permission(
          Crud.create,
          enums.Role.users,
          resource: Verification.unverified,
        ),
        permission.Permission(Crud.create, enums.Role.guests),
        permission.Permission(Crud.create, enums.Role.team, id: "exampleId"),
        permission.Permission(
          Crud.create,
          enums.Role.team,
          id: "exampleId",
          resource: "exampleRole",
        ),
        permission.Permission(Crud.create, enums.Role.member, id: "exampleId"),
        permission.Permission(
          Crud.create,
          enums.Role.label,
          id: "exampleLabel",
        ),
      ],
      indexes: [
        Index("test_index", IndexType.key, {"test": SortOrder.asc}),
      ],
    ),
  ], sync: true);

  // await appOrm.loadSkeleton([]);

  logger.warn("-------------------------------------------------");

  // logger.log(appOrm.skeleton);

/*  logger.log(appOrm.getRepository(typeName: "User").permissions);
  final users = await appOrm.pull<User>();
  logger.log(users.first.permissions);*/

/*  for (var repo in appOrm.repositories) {
    logger.debug(repo.attributes);
  }*/

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

  // final test = await appOrm.pull<Address>();
  // logger.debug(test);

  // logger.log("Finished");
  exit(0);
}

class Address extends Entity<Address> {
  @Orm(AttributeType.string, modifiers: {
    Modifier.required: true,
    Modifier.size: 100,
  })
  late String city;

  Address.empty() : super.empty();
}

class User extends Entity<User> {
  @Orm(AttributeType.string, modifiers: {
    Modifier.required: true,
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
    Modifier.required: true,
  })
  late String name;

  @Orm(AttributeType.entity)
  late Address address;

  @Orm(AttributeType.entity, modifiers: {Modifier.array: true})
  List<User> users = [];

  Campus.empty() : super.empty();
}

class Teste extends Entity<Teste> {
  @Orm(AttributeType.string, modifiers: {
    Modifier.required: true,
    Modifier.size: 100,
  })
  late String test;

  Teste.empty() : super.empty();
}
