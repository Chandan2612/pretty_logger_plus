import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

class PrettyLoggerPlus {
  static final bool _useColors = !kReleaseMode;

  static void log(String message, {LogLevel level = LogLevel.info}) {
    final emoji = _emojiForLevel(level);
    final colorCode = _colorForLevel(level);

    final output = _useColors
        ? "$colorCode$emoji ${level.name.toUpperCase()}: $message\x1B[0m"
        : "$emoji ${level.name.toUpperCase()}: $message";

    // print only in debug or always print errors
    if (!kReleaseMode || level == LogLevel.error) {
      // ignore: avoid_print
      print(output);
    }
  }

  static String _emojiForLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return "🐞";
      case LogLevel.info:
        return "ℹ️";
      case LogLevel.warning:
        return "⚠️";
      case LogLevel.error:
        return "❌";
    }
  }

  static String _colorForLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return "\x1B[34m"; // blue
      case LogLevel.info:
        return "\x1B[32m"; // green
      case LogLevel.warning:
        return "\x1B[33m"; // yellow
      case LogLevel.error:
        return "\x1B[31m"; // red
    }
  }
}
