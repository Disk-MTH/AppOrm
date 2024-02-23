import 'package:app_orm/src/utils.dart';

abstract class AbstractLogger {
  void debug(
    dynamic message, {
    List<dynamic> args = const [],
  });

  void log(
    dynamic message, {
    List<dynamic> args = const [],
  });

  void warn(
    dynamic message, {
    Exception? exception,
    List<dynamic> args = const [],
  });

  void error(
    dynamic message, {
    Exception? exception,
    List<dynamic> args = const [],
  });
}

class DummyLogger implements AbstractLogger {
  const DummyLogger();

  @override
  void debug(
    dynamic message, {
    List<dynamic> args = const [],
  }) {}

  @override
  void log(
    dynamic message, {
    List<dynamic> args = const [],
  }) {}

  @override
  void warn(
    dynamic message, {
    Exception? exception,
    List<dynamic> args = const [],
  }) {}

  @override
  void error(
    dynamic message, {
    Exception? exception,
    List<dynamic> args = const [],
  }) {}
}

class Logger implements AbstractLogger {
  static const String _reset = "\u001b[0m";
  static const String _cyan = "\u001b[36m";
  static const String _green = "\u001b[32m";
  static const String _yellow = "\u001b[33m";
  static const String _red = "\u001b[31m";

  LogLevel level;

  Logger({this.level = LogLevel.debug});

  @override
  void debug(
    dynamic message, {
    List<dynamic> args = const [],
  }) {
    if (level.index <= LogLevel.debug.index) {
      message = Utils.beautify(message);
      for (var arg in args) {
        message = message.replaceFirst("{}", arg.toString());
      }
      print("$_cyan${DateTime.now()} - DEBUG: $message$_reset");
    }
  }

  @override
  void log(
    dynamic message, {
    List<dynamic> args = const [],
  }) {
    if (level.index <= LogLevel.log.index) {
      message = Utils.beautify(message);
      for (var arg in args) {
        message = message.replaceFirst("{}", arg.toString());
      }
      print("$_green${DateTime.now()} - LOG: $message$_reset");
    }
  }

  @override
  void warn(
    dynamic message, {
    Exception? exception,
    List<dynamic> args = const [],
  }) {
    if (level.index <= LogLevel.warn.index) {
      message = Utils.beautify(message);
      for (var arg in args) {
        message = message.replaceFirst("{}", arg.toString());
      }
      print("$_yellow${DateTime.now()} - WARN: $message$_reset");
      if (exception != null) {
        print("$_yellow$exception$_reset");
      }
    }
  }

  @override
  void error(
    dynamic message, {
    Exception? exception,
    List<dynamic> args = const [],
  }) {
    if (level.index <= LogLevel.error.index) {
      message = Utils.beautify(message);
      for (var arg in args) {
        message = message.replaceFirst("{}", arg.toString());
      }
      print("$_red${DateTime.now()} - ERROR: $message$_reset");
      if (exception != null) {
        print("$_red$exception$_reset");
      }
    }
  }
}

enum LogLevel { debug, log, warn, error }
