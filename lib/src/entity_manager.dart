import "package:app_orm/src/entity.dart";
import "package:app_orm/src/utils.dart";
import "package:dart_appwrite/dart_appwrite.dart";

class EntityManager {
  final Client _client;
  final Databases _databases;

  EntityManager(this._client) : _databases = Databases(_client);

  void pushModel(List<Type> entities) {
    for (var type in entities) {
      if (!Utils.isSubtype<Entity>(type)) throw "Type is not an Entity";

/*      var a = Utils.fieldsFromClass(type);
      a.forEach((key, value) {
        print("## Key: $key, Type: ${value.type.reflectedType}");
      });*/

      var i = Address(id: "aaaaa", city: "dddd");
      var b = Utils.fieldsFromInstance(i);
      b.forEach((key, value) {
        print("@@ Key: $key, Value: ${value.value}");
      });

      /*ClassMirror cm = reflectClass(type);
      cm.declarations.forEach((key, value) {
        if (value is VariableMirror) {
          final fieldName = MirrorSystem.getName(key);
          final fieldType = value.type.reflectedType;

          var metadata = value.metadata;
          */ /*var hasSomeAnnotation =
              metadata.any((m) => m.reflectee is SomeAnnotation);*/ /*

          print(
              "Field: $fieldName, Type: $fieldType, Annotation: $hasSomeAnnotation");
        }
      });*/
    }
  }
}
