abstract class Serializable<T> {
  Map<String, dynamic> serialize();
  T deserialize(Map<String, dynamic> data);
}
