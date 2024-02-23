import "dart:mirrors";

import "package:app_orm/src/annotations.dart";
import "package:app_orm/src/entity_manager.dart";
import "package:app_orm/src/identifiable.dart";
import "package:app_orm/src/utils.dart";
import "package:dart_appwrite/models.dart";

abstract class Entity extends Identifiable<Document> {
  final EntityManager entityManager;

  @OrmNative($prefix: true)
  late final String databaseId;

  @OrmNative($prefix: true)
  late final String collectionId;

  @OrmNative($prefix: true)
  late final List permissions;

  Entity(this.entityManager, Document document) : super(document) {
    Reflection.listClassFields(runtimeType).forEach((name, mirror) async {
      final InstanceMirror? metadata = mirror.metadata
          .where(
            (e) => e.reflectee is OrmAttribute && e.reflectee is! OrmNative,
          )
          .firstOrNull;

      if (metadata == null) return;

      final OrmAttribute annotation = metadata.reflectee;
      annotation.validate();

      name = name.substring(1);
      final value = document.data[name];

      if (annotation.runtimeType != OrmEntity) {
        if (value == null && (annotation.isRequired || annotation.isArray)) {
          throw "Field \"$name\" is not nullable";
        }
        Reflection.setFieldValue(this, mirror, value);
      } else {
        final repository = await entityManager.getRepository<T>();
        final entities = await repository.list();
        return entities.firstWhere((entity) => entity.id == id);
      }
    });
  }

//TODO: Test this method
/*  static T mutate<T extends Entity>(T entity, Map<String, dynamic> data) {
    final fields = Reflection.listInstanceFields(entity);

    fields.forEach((name, reflectedVariable) {
      if (data.containsKey(name)) reflectedVariable.value = data[name];
    });

    return entity;
  }*/
}
