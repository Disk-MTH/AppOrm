import 'package:app_orm/src/entity.dart';
import 'package:app_orm/src/entity_manager.dart';
import 'package:app_orm/src/identifiable.dart';
import 'package:app_orm/src/utils.dart';
import 'package:dart_appwrite/models.dart';

import 'annotations.dart';

class Repository<T extends Entity> extends Identifiable<Collection> {
  final EntityManager entityManager;

  @OrmNative()
  late final String databaseId;

  @OrmNative()
  late final String name;

  @OrmNative()
  late final bool enabled;

  @OrmNative()
  late final bool documentSecurity;

  //TODO: review this
  /*@OrmNative()
  late final List<Index> indexes;*/

  @OrmNative($prefix: true)
  late final List permissions;

  final Type type = T;

  Repository(this.entityManager, Collection collection) : super(collection);

  Future<List<T>> list() async {
    entityManager.logger.log("Listing ${T.toString()}");

    final List<T> entities = [];

    final List<Document> documents = await entityManager.databases
        .listDocuments(databaseId: databaseId, collectionId: id)
        .then((value) => value.documents);

    for (var document in await entityManager.databases
        .listDocuments(databaseId: databaseId, collectionId: id)
        .then((value) => value.documents)) {
      entities.add(Reflection.instantiate<T>(args: [entityManager, document]));
    }

    return entities;
  }
}
