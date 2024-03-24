import "package:app_orm/src/utils/utils.dart";
import "package:collection/collection.dart";

import "logger.dart";

mixin Serializable {
  final AbstractLogger logger = Utils.logger;

  Map<String, dynamic> serialize();

  Serializable deserialize(Map<String, dynamic> data);

  @override
  bool operator ==(Object other) {
    if (other is! Serializable) return false;
    return DeepCollectionEquality.unordered()
        .equals(serialize(), other.serialize());
  }
}
