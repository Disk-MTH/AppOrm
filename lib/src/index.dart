import 'package:app_orm/src/utils/enums.dart';
import 'package:app_orm/src/utils/serializable.dart';

class Index with Serializable<Index> {
  late String key;
  late IndexType type;
  late Map<String, SortOrder> attributes;
  late Status? status;
  late String? error;

  Index(this.key, this.type, this.attributes)
      : status = null,
        error = null;

  Index.empty();

  Index.fromModel(Map<String, dynamic> index) {
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

  //TODO: test
  @override
  Map<String, dynamic> serialize() {
    return {
      "key": key,
      "type": type.name,
      "attributes": attributes.map((key, value) => MapEntry(key, value.name)),
    };
  }

  //TODO: test
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

  @override
  bool equals(Serializable other) {
    return other is Index &&
        other.key == key &&
        other.type == type &&
        other.attributes.length == attributes.length &&
        !other.attributes.entries.any((o) => !attributes.entries
            .any((e) => o.key == e.key && o.value == e.value));
  }
}
