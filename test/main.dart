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

  final AppwriteOrm appOrm = AppwriteOrm(databases, "Data");
  await appOrm.setup(
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

  /*final aRepo = appOrm.getRepository<AddressRepository>()!;
  final uRepo = appOrm.getRepository<Repository<User>>()!;

  final a = aRepo.init(Address("Paris"));
  final a2 = aRepo.init(Address("Lyon"));

  final u = uRepo.init(User("John", ["Doe", "X"], a, [a, a2]));
  logger.log(u);

  final uS = u.serialize();

  final uD = User.orm(uS);
  logger.log(uD);*/

  exit(0);
}

class Address extends Entity {
  @Orm(AttributeType.string, modifiers: {
    Modifier.required: true,
    Modifier.size: 100,
  })
  late String city;

  Address(this.city);

  Address.orm(super.data) : super.orm();
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
              resource: permission.Permission.verified,
            ),
            permission.Permission(
              Crud.create,
              enums.Role.user,
              id: "exampleId",
              resource: permission.Permission.unverified,
            ),
            permission.Permission(Crud.create, enums.Role.users),
            permission.Permission(
              Crud.create,
              enums.Role.users,
              resource: permission.Permission.verified,
            ),
            permission.Permission(
              Crud.create,
              enums.Role.users,
              resource: permission.Permission.unverified,
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

  AddressRepository.orm(super.data) : super.orm();

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

  @Orm(AttributeType.string, modifiers: {
    Modifier.array: true,
  })
  List<String> names = [];

  @Orm(AttributeType.entity)
  late Address address;

  @Orm(AttributeType.entity, modifiers: {Modifier.array: true})
  List<Address> addresses = [];

  User(this.name, this.names, this.address, this.addresses);

  User.orm(super.data) : super.orm();
}
