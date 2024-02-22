import "package:app_orm/src/utils.dart";
import "package:dart_appwrite/models.dart";

import "annotations.dart";

class Identifiable<M extends Model> implements Model {
  @OrmNative()
  late String id;

  @OrmNative()
  late String createdAt;

  @OrmNative()
  late String updatedAt;

  Identifiable(M model) {
    switch (model.runtimeType) {
      case const (Database):
        model as Database;
        id = model.$id;
        createdAt = model.$createdAt;
        updatedAt = model.$updatedAt;
        break;
      case const (Collection):
        model as Collection;
        id = model.$id;
        createdAt = model.$createdAt;
        updatedAt = model.$updatedAt;
        break;
      case const (Document):
        model as Document;
        id = model.$id;
        createdAt = model.$createdAt;
        updatedAt = model.$updatedAt;
        break;
      default:
        throw "Unsupported model type: \"${model.runtimeType}\"";
    }
  }

  @override
  Map<String, dynamic> toMap() {
    return Reflection.listInstanceFields(this).map((key, value) {
      if (value.value is Model) {
        return MapEntry(key, value.value.toMap());
      } else if (value.value is List<Model>) {
        return MapEntry(key, value.value.map((e) => e.toMap()).toList());
      }
      return MapEntry(key, value.value.toString());
    });
  }
}
