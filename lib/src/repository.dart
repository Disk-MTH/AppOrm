import 'package:app_orm/src/app_orm.dart';
import 'package:app_orm/src/entity.dart';
import 'package:app_orm/src/identifiable.dart';
import 'package:dart_appwrite/models.dart';

import 'annotations.dart';

class Repository<T extends Entity> extends Identifiable {
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
  final List<T> _entities = [];
  late final AppOrm appOrm;

  Repository() : super.construct();

  /*Future<List<T>> list() async {
    appOrm.logger.debug("Listing entities: $name");

    _entities.clear();

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

      Reflection.listClassFields(T).forEach((name, mirror) {
        final InstanceMirror? metadata = mirror.metadata
            .where(
              (e) => e.reflectee is OrmAttribute && e.reflectee is OrmEntity,
            )
            .firstOrNull;

        if (metadata == null) return;

        final OrmEntity annotation = metadata.reflectee;
        annotation.validate();

        name = "orm${mirror.type.reflectedType}Id";
        final refDocId = document.data[name];

      _entities.add(entity);
    });
    
    return _entities;
    */ /*appOrm.logger.debug("Listing entities: $name");
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
        if (refDocId == null) continue;

        print(refDocId);

        print(mirror.type.reflectedType);

        //TODO: Get the id of the right collection
        final Document refDoc = await appOrm.databases.getDocument(
          databaseId: databaseId,
          collectionId: "",
          documentId: refDocId,
        );

        print(refDoc.toMap());

        print("tttttt");
      }

      print("#####");
      entities.add(entity);
    }

    return entities;*/ /*
  }*/

  // void add(T entity) {
  //   _entities.add(entity);
  // }

  /*Future<T> persist(T entity) async {
    appOrm.logger.debug("Persisting entity: $name");

    final Map<String, dynamic> data = {};

    final Document document = await appOrm.databases.createDocument(
      databaseId: databaseId,
      collectionId: id,
      documentId: '',
      data: entity.toMap(),
    );

    return Reflection.instantiate<T>(
      args: [document],
    );
  }*/
}
