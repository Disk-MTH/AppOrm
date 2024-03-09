import "package:app_orm/src/enums.dart";
import "package:app_orm/src/serializable.dart";

class Index implements Serializable<Index> {
  late String key;
  late IndexType type;
  late Map<String, SortOrder> attributes;
  late final Status? status;
  late final String? error;

  Index(this.key, this.type, this.attributes)
      : status = null,
        error = null;

  Index.empty();

  Index.fromMap(Map<String, dynamic> index) {
    key = index["key"];

    type = IndexType.values.firstWhere(
      (e) => e.toString().split('.').last == index["type"],
    );

    //TODO: check if we can reduce this
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
  }

  @override
  Map<String, dynamic> serialize() {
    return {
      "key": key,
      "type": type.name,
      "attributes": attributes.map((key, value) => MapEntry(key, value.name)),
      if (status != null) "status": status!.name,
      if (error != null) "error": error,
    };
  }

  @override
  Index deserialize(Map<String, dynamic> data) {
    key = data["key"];
    type = IndexType.values.firstWhere((e) => e.name == data["type"]);
    attributes = data["attributes"].map((key, value) => MapEntry(
          key,
          SortOrder.values.firstWhere((e) => e.name == value.toLowerCase()),
        ));
    status = Status.values.where((e) => e.name == data["status"]).firstOrNull;
    error = data["error"];
    return this;
  }
}
