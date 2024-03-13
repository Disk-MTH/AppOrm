import "package:app_orm/src/identifiable.dart";
import "package:app_orm/src/orm.dart";
import "package:app_orm/src/permission.dart";
import "package:app_orm/src/repository.dart";
import "package:app_orm/src/utils/utils.dart";

import 'utils/enums.dart';

abstract class Entity<T> extends Identifiable<T> {
  @Orm(AttributeType.native)
  late final String databaseId;

  @Orm(AttributeType.native)
  late final String collectionId;

  @Orm(AttributeType.native, modifiers: {Modifier.array: true})
  final List<Permission> permissions = [];

  Entity.orm();

  Entity(Repository repository) {
    id = Utils.uniqueId();
    createdAt = DateTime.now().toIso8601String();
    updatedAt = createdAt;
    databaseId = repository.databaseId;
    collectionId = repository.id;
  }
}
