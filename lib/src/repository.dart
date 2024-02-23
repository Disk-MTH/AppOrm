import 'dart:mirrors';

import 'package:app_orm/src/app_orm.dart';
import 'package:app_orm/src/entity.dart';
import 'package:app_orm/src/identifiable.dart';
import 'package:app_orm/src/utils.dart';
import 'package:dart_appwrite/models.dart';

import 'annotations.dart';

class Repository<T extends Entity> extends Identifiable<Collection> {
  @OrmNative()
  late final String databaseId;

  @OrmNative()
  late final String name;

  @OrmNative()
  late final bool enabled;

  @OrmNative()
  late final bool documentSecurity;

  //TODO: review this
  @OrmNative()
  late final List<Index> indexes;

  //TODO: review this
  @OrmNative($prefix: true)
  late final List permissions;

  final Type type = T;
  late final AppOrm appOrm;

  Future<List<T>> list() async {
    appOrm.logger.debug("Listing entities: $name");
    final List<T> entities = [];

    final List<Document> documents = await appOrm.databases
        .listDocuments(
          collectionId: id,
          databaseId: databaseId,
        )
        .then((value) => value.documents);

    for (var document in documents) {
      final T entity = Reflection.instantiate<T>(
        args: [document],
      );

      print('@@@@@');
      final fields = Reflection.listClassFields(T);
      for (var name in fields.keys) {
        final mirror = fields[name]!;

        final InstanceMirror? metadata = mirror.metadata
            .where(
              (e) => e.reflectee is OrmAttribute && e.reflectee is OrmEntity,
            )
            .firstOrNull;

        if (metadata == null) continue;

        final OrmEntity annotation = metadata.reflectee;
        annotation.validate();

        name = "orm${mirror.type.reflectedType}Id";
        final refDocId = document.data[name];

        //TODO: Specials case with OneToOne, OneToMany, ManyToOne, ManyToMany ...
        if (refDocId == null) {
          print("refDocId is null");
          continue;
        }

        print(refDocId);

        //TODO: Get the id of the right collection
        final Document refDoc = await appOrm.databases.getDocument(
          databaseId: databaseId,
          collectionId: ,
          documentId: refDocId,
        );

        print(refDoc.toMap());

        print("tttttt");
      }

      print("#####");
      entities.add(entity);
    }

    return entities;
  }

  // void add(T entity) {
  //   _entities.add(entity);
  // }
}
