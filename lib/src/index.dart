import "package:app_orm/src/utils/enums.dart";
import "package:app_orm/src/utils/serializable.dart";

class Index with Serializable {
  late String key;
  late IndexType type;
  late Map<String, SortOrder> attributes;
  late Status status;
  late String? error;

  Index(this.key, this.type, this.attributes)
      : status = Status.available,
        error = null {
    _checkValidity();
  }

  Index.fromModel(Map<String, dynamic> index) {
    key = index["key"];

    type = IndexType.values.firstWhere(
      (e) => e.toString().split('.').last == index["type"],
    );

    List<String> attributesList = List<String>.from(index["attributes"]);
    List<String> ordersList = List<String>.from(index["orders"]);

    attributes = {};
    for (int i = 0; i < attributesList.length; i++) {
      attributes[attributesList[i]] = SortOrder.values.firstWhere(
        (e) => e.name == ordersList[i].toLowerCase(),
      );
    }

    status = Status.values.firstWhere(
      (e) => e.name == index["status"],
    );

    error = index["error"].isEmpty ? null : index["error"];

    _checkValidity();
  }

  @override
  Map<String, dynamic> serialize() {
    return {
      "key": key,
      "type": type.name,
      "attributes": attributes.map((key, value) => MapEntry(key, value.name)),
      "status": status.name,
      "error": error,
    };
  }

  @override
  Index deserialize(Map<String, dynamic> data) {
    key = data["key"];
    type = IndexType.values.firstWhere((e) => e.name == data["type"]);
    attributes = {};
    data["attributes"].forEach((key, value) {
      attributes[key] = SortOrder.values.firstWhere(
        (e) => e.name == value.toLowerCase(),
      );
    });
    status = Status.values.firstWhere((e) => e.name == data["status"]);
    error = data["error"];
    _checkValidity();
    return this;
  }

  void _checkValidity() {
    if (key.isEmpty) {
      throw "Index key cannot be empty";
    }

    if (attributes.isEmpty) {
      throw "Index modifiers cannot be empty";
    }
  }
}
