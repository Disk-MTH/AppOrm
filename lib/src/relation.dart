import "entity.dart";

abstract class Relation<S extends Entity, D> {
  S? _source;
  D? _destination;
  String _fieldName = "";

  Relation({
    S? source,
    D? destination,
    String fieldName = "",
  })  : _source = source,
        _destination = destination,
        _fieldName = fieldName;
}

class OneToOne<S extends Entity, D extends Entity> extends Relation<S, D> {
  OneToOne({
    S? source,
    D? destination,
    String fieldName = "",
  }) : super(
          source: source,
          destination: destination,
          fieldName: fieldName,
        );
}
