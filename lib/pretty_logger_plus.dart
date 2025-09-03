import 'dart:convert';
import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, success, warning, error }

enum TimeStyle { none, clock, dateClock }

class PrettyLoggerPlus {
  static final bool _useAnsiColors = !kReleaseMode && !kIsWeb;

  static TimeStyle _timeStyle = TimeStyle.clock;
  static bool _useLocalTime = true;
  static bool _showMillis = false;

  static Set<LogLevel> _consoleLevelsDebug = {
    LogLevel.debug,
    LogLevel.info,
    LogLevel.success,
    LogLevel.warning,
    LogLevel.error,
  };
  static Set<LogLevel> _consoleLevelsRelease = {LogLevel.error};

  static Set<LogLevel> _shortLabelConsole = Set<LogLevel>.from(LogLevel.values);

  static void configureConsoleLevels({
    Set<LogLevel>? debugLevels,
    Set<LogLevel>? releaseLevels,
  }) {
    if (debugLevels != null) _consoleLevelsDebug = debugLevels;
    if (releaseLevels != null) _consoleLevelsRelease = releaseLevels;
  }

  static void configureConsoleStyle({Set<LogLevel>? shortLabelFor}) {
    if (shortLabelFor != null) _shortLabelConsole = shortLabelFor;
  }

  static void configureTime({
    TimeStyle? style,
    bool? local,
    bool? showMillis,
  }) {
    if (style != null) _timeStyle = style;
    if (local != null) _useLocalTime = local;
    if (showMillis != null) _showMillis = showMillis;
  }

  static Future<void> drain() async {}
  static Future<void> dispose() async {}

  static void log(
    String message, {
    LogLevel level = LogLevel.info,
    String module = "GENERAL",
    bool json = false,
  }) {
    final now = _useLocalTime ? DateTime.now() : DateTime.now().toUtc();
    final prettyTs = _fmtTime(now);
    final isoTs = now.toIso8601String();
    final emoji = _emojiForLevel(level);
    final label = level.name.toUpperCase();

    final shouldPrint = !kReleaseMode ? _consoleLevelsDebug.contains(level) : _consoleLevelsRelease.contains(level);
    if (!shouldPrint) return;

    String prefix = '';
    if (_timeStyle != TimeStyle.none) prefix = '[$prettyTs] ';

    String line;
    if (json) {
      final obj = {
        "ts": isoTs,
        "prettyTs": prettyTs,
        "module": module,
        "level": label,
        "msg": message,
      };
      final payload = jsonEncode(obj);
      line = _shortLabelConsole.contains(level) ? "$prefix$emoji $payload" : "$prefix$label $emoji $payload";
    } else {
      final core = _shortLabelConsole.contains(level)
          ? "$prefix[$module] $emoji: $message"
          : "$prefix[$module] $label $emoji: $message";
      line = _useAnsiColors ? "${_colorForLevel(level)}$core\x1B[0m" : core;
    }

    print(line);
  }

  static String _fmtTime(DateTime dt) {
    if (_timeStyle == TimeStyle.none) return "";
    final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    final y = dt.year;
    final m = months[dt.month - 1];
    final d = _pad2(dt.day);
    int h = dt.hour;
    final min = _pad2(dt.minute);
    final sec = _pad2(dt.second);
    final ms = _pad3(dt.millisecond);

    String period = "AM";
    int h12 = h;
    if (h == 0) {
      h12 = 12;
      period = "AM";
    } else if (h < 12) {
      h12 = h;
      period = "AM";
    } else if (h == 12) {
      h12 = 12;
      period = "PM";
    } else {
      h12 = h - 12;
      period = "PM";
    }

    final clock = _showMillis ? "${h12}:${min}:${sec}.${ms} ${period}" : "${h12}:${min}:${sec} ${period}";

    if (_timeStyle == TimeStyle.clock) return clock;

    return "$d $m $y $clock";
  }

  static String _pad2(int n) => n.toString().padLeft(2, '0');
  static String _pad3(int n) => n.toString().padLeft(3, '0');

  static String _emojiForLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return "🐞";
      case LogLevel.info:
        return "ℹ️";
      case LogLevel.success:
        return "✅";
      case LogLevel.warning:
        return "⚠️";
      case LogLevel.error:
        return "❌";
    }
  }

  static String _colorForLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return "\x1B[34m";
      case LogLevel.info:
        return "\x1B[32m";
      case LogLevel.success:
        return "\x1B[92m";
      case LogLevel.warning:
        return "\x1B[33m";
      case LogLevel.error:
        return "\x1B[31m";
    }
  }
}
