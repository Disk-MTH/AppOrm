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

  static const int intMin = -(intMax + 1);
  static const int intMax = 9223372036854775807;

  static const double doubleMin = -doubleMax;
  static const double doubleMax = 1.7976931348623157e+308;

  static String uniqueId() {
    return List.generate(
      idLength,
      (_) => idCharset[random.nextInt(idCharset.length)],
    ).join();
  }

  static String beautify(dynamic input) {
    if (input is String) {
      return input;
    } else if (input is Serializable) {
      return "${input.runtimeType}\n${JsonEncoder.withIndent("  ").convert(input.serialize())}";
    } else if (input is List<Serializable>) {
      return "${input.runtimeType}\n${input.map((e) => beautify(e)).join("\n")}";
    }

    try {
      return "\n${JsonEncoder.withIndent("  ").convert(input)}";
    } catch (e) {
      return input.toString();
    }
  }
}
