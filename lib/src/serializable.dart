import "logger.dart";

abstract class Serializable<T> {
  static AbstractLogger logger = DummyLogger();

  Map<String, dynamic> serialize();
  T deserialize(Map<String, dynamic> data);
}
