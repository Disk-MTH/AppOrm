import "package:app_orm/src/identifiable.dart";
import "package:app_orm/src/orm.dart";
import "package:app_orm/src/permission.dart";

import 'utils/enums.dart';

abstract class Entity extends Identifiable {
  @Orm(AttributeType.native)
  late final String databaseId;

  @Orm(AttributeType.native)
  late final String collectionId;

  @Orm(AttributeType.native, modifiers: {Modifier.array: true})
  final List<Permission> permissions = [];

  Entity();

  Entity.orm(super.data) : super.orm();
}
