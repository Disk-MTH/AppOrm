import "package:app_orm/src/utils.dart";

import "logger.dart";

mixin Serializable<T> {
  final AbstractLogger logger = Utils.logger;

  Map<String, dynamic> serialize();
  T deserialize(Map<String, dynamic> data);
}
