import "package:app_orm/src/annotations.dart";
import "package:app_orm/src/identifiable.dart";

abstract class Entity<T> extends Identifiable<T> {
  @OrmNative($prefix: true)
  late String? databaseId;

  @OrmNative($prefix: true)
  late String? collectionId;

  //TODO: review this
  @OrmNative($prefix: true)
  late List? permissions;

  Entity.empty() : super.empty();

//TODO: Test this method
/*  static T mutate<T extends Entity>(T entity, Map<String, dynamic> data) {
    final fields = Reflection.listInstanceFields(entity);

    fields.forEach((name, reflectedVariable) {
      if (data.containsKey(name)) reflectedVariable.value = data[name];
    });

    return entity;
  }*/
}
