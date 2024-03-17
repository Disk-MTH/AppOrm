import "package:app_orm/src/utils/utils.dart";

import "logger.dart";

mixin Serializable {
  final AbstractLogger logger = Utils.logger;

  Map<String, dynamic> serialize();
  Serializable deserialize(Map<String, dynamic> data);
  bool equals(Serializable other);
}
