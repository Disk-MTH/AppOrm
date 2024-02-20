import "annotations.dart";

class Identifiable/*<M extends Model>*/ {
  // M? _model;

  @OrmString(maxLength: 20)
  String id;

  Identifiable({required this.id});

/*  T setModel<T extends Identifiable<M>>(M model) {
    _model = model;
    return this as T;
  }*/
}
