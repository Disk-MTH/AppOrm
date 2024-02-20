import 'package:app_orm/src/entity.dart';
import 'package:app_orm/src/identifiable.dart';

import 'entity_manager.dart';

class Repository<T extends Entity> extends Identifiable {
  final EntityManager entityManager;
  final String name;

  Repository(
    this.entityManager, {
    required super.id,
    required this.name,
  });

  Future<List<T>> list() {
    return Future.value([]);
  }

/*  Future<T> create(T entity);
  Future<T> read(String id);
  Future<T> update(T entity);
  Future<T> delete(String id);*/
}
