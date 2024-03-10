import "package:app_orm/src/identifiable.dart";
import "package:app_orm/src/orm.dart";
import "package:app_orm/src/permission.dart";

import 'utils/enums.dart';

abstract class Entity<T> extends Identifiable<T> {
  @Orm(AttributeType.native)
  String databaseId = "";

  @Orm(AttributeType.native)
  String collectionId = "";

  @Orm(AttributeType.native, modifiers: {Modifier.array: true})
  List<Permission> permissions = [];

  Entity.empty() : super.empty();
}
