import "dart:convert";
import "dart:math";

import "package:app_orm/src/utils/serializable.dart";

import 'logger.dart';

class Utils {
  static AbstractLogger logger = DummyLogger();

  static final Random random = Random(DateTime.now().millisecondsSinceEpoch);
  static const String idCharset = "abcdefghijklmnopqrstuvwxyz0123456789";
  static const int idLength = 20;

  static const int stringMax = 1073741824;

  static const int intMin = -intMax;
  static const int intMax = 9223372036854775807;

  static const double floatMin = -floatMax;
  static const double floatMax = 1.7976931348623157e+308;

  static String uniqueId() {
    return List.generate(
      idLength,
      (_) => idCharset[random.nextInt(idCharset.length)],
    ).join();
  }

  static String beautify(dynamic input) {
    if (input is Serializable) {
      return "${input.runtimeType}\n${JsonEncoder.withIndent("  ").convert(input.serialize())}";
    } else if (input is List<Serializable>) {
      return "${input.runtimeType}\n${input.map((e) => beautify(e)).join("\n")}";
    } else if (input is Map<String, dynamic>) {
      return JsonEncoder.withIndent("  ").convert(input);
    } else if (input is List<Map<String, dynamic>>) {
      return input.map((e) => beautify(e)).join("\n");
    }
    return input.toString();
  }
}
