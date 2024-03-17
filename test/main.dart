import "dart:core";
import "dart:io";

import "package:app_orm/src/appwrite_orm.dart";
import "package:app_orm/src/entity.dart";
import "package:app_orm/src/index.dart";
import "package:app_orm/src/orm.dart";
import "package:app_orm/src/permission.dart" as permission;
import "package:app_orm/src/repository.dart";
import "package:app_orm/src/utils/enums.dart" as enums;
import "package:app_orm/src/utils/enums.dart";
import "package:app_orm/src/utils/logger.dart";
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

  final AppwriteOrm appOrm = AppwriteOrm(databases);
  await appOrm.setup(
    "65d4bcc6bfbefe3e6b61",
    [
      AddressRepository(),
      Repository<User>(),
    ],
    sync: true,
  );

  /*final addressRepository = appOrm.getRepository<AddressRepository>()!;

  final addressRepositorySerialized = addressRepository.serialize();

  final addressRepositoryDeserialized =
      AddressRepository.fromMap(addressRepositorySerialized);

  logger.log(addressRepositoryDeserialized);*/

  final aRepo = appOrm.getRepository<AddressRepository>()!;
  final uRepo = appOrm.getRepository<Repository<User>>()!;

  final a = aRepo.instantiate(Address("Paris"));
  final a2 = aRepo.instantiate(Address("Lyon"));

  final u = uRepo.instantiate(User("John", [a, a2]));

  logger.log(u);

  exit(0);
}

class Address extends Entity {
  @Orm(AttributeType.string, modifiers: {
    Modifier.required: true,
    Modifier.size: 100,
  })
  late String city;

  @Orm(AttributeType.entity)
  Address(this.city);
}

class AddressRepository extends Repository<Address> {
  AddressRepository()
      : super(
          documentSecurity: true,
          enabled: false,
          permissions: [
            permission.Permission(Crud.create, enums.Role.any),
            permission.Permission(Crud.create, enums.Role.user,
                id: "exampleId"),
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
            permission.Permission(Crud.create, enums.Role.team,
                id: "exampleId"),
            permission.Permission(
              Crud.create,
              enums.Role.team,
              id: "exampleId",
              resource: "exampleRole",
            ),
            permission.Permission(Crud.create, enums.Role.member,
                id: "exampleId"),
            permission.Permission(
              Crud.create,
              enums.Role.label,
              id: "exampleLabel",
            ),
          ],
          indexes: [
            Index("test_index", IndexType.key, {"city": SortOrder.asc}),
          ],
        );

  AddressRepository.fromMap(super.data) : super.fromMap();

  void test() {
    print('test');
  }
}

class User extends Entity {
  @Orm(AttributeType.string, modifiers: {
    Modifier.required: true,
    Modifier.size: 100,
  })
  late String name;

  @Orm(AttributeType.entity, modifiers: {Modifier.array: true})
  late List<Address> addresses;

  User(this.name, this.addresses);
}
