import 'package:app_orm/src/entity.dart';
import 'package:app_orm/src/identifiable.dart';
import 'package:dart_appwrite/models.dart';

class Repository extends Identifiable {
  final Type type;
  final List<Entity> _entities = [];

  Repository(this.type, Collection collection) : super(collection) {}

  List<Entity> list() {
    return _entities;
  }

  void add(Entity entity) {
    if (entity.runtimeType != type) {
      throw "Invalid entity type: ${entity.runtimeType} for repository: $type";
    }

    _entities.add(entity);
  }

  void remove(Entity entity) {
    _entities.remove(entity);
  }

/*  Future<T> create(T entity);
  Future<T> read(String id);
  Future<T> update(T entity);
  Future<T> delete(String id);*/
}
