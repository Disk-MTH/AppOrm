import "package:app_orm/src/repository.dart";

import "entity.dart";

abstract class DataStorage {
  // void initialize(List<Repository> types);

  void registerRepo(Repository repository);

  Repository<T> getRepo<T extends Entity>();

  /* List<T> list<T extends Entity>();

  void add<T extends Entity>(T entity);

  void remove<T extends Entity>(T entity);*/
}

class Memory extends DataStorage {
  final List<Repository> _repositories = [];

/*  @override
  void initialize(List<Repository> types) {
    _repositories.addAll(types);
  }*/

  @override
  void registerRepo(Repository repository) {
    _repositories.add(repository);
  }

  @override
  Repository<T> getRepo<T extends Entity>() {
    final Repository<T>? repo =
        _repositories.where((e) => e.type == T).firstOrNull as Repository<T>?;

    if (repo == null) {
      throw "Repository not found for type \"$T\"";
    }

    return repo;
  }

  /*@override
  List<T> list<T extends Entity>() {
    return _repositories.whereType<T>().toList();
  }

  @override
  void add<T extends Entity>(T entity) {
    _repositories.add(entity);
  }

  @override
  void remove<T extends Entity>(T entity) {
    _repositories.remove(entity);
  }*/
}
