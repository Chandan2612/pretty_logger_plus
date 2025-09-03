// 🧪 PrettyLoggerPlus (console-only) tests — UPDATED to strip ANSI colors
// Run: flutter test -r expanded

import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

// ⬇️ Change this import if your path/package is different.
import 'package:pretty_logger_plus/pretty_logger_plus.dart';

/// Remove ANSI color codes so assertions see plain text.
/// (Debug builds add \x1B[...m color codes at the start of lines.)
String _stripAnsi(String s) => s.replaceAll(RegExp(r'\x1B\[[0-9;]*m'), '');

/// Capture everything printed during [body] and return sanitized lines.
Future<List<String>> _capturePrints(FutureOr<void> Function() body) async {
  final lines = <String>[];
  final spec = ZoneSpecification(
    print: (_, __, ___, String msg) => lines.add(_stripAnsi(msg)),
  );
  await Zone.current.fork(specification: spec).run(body);
  return lines;
}

void main() {
  // Reset to known baseline before each test (matches defaults in example)
  setUp(() {
    // 🕒 Easy-to-read time: [12:34:56 PM] (local, no ms)
    PrettyLoggerPlus.configureTime(
      style: TimeStyle.clock,
      local: true,
      showMillis: false,
    );
    // 🔊 All levels in debug by default
    PrettyLoggerPlus.configureConsoleLevels(
      debugLevels: { for (final l in LogLevel.values) l },
      // releaseLevels not relevant in debug-mode tests
    );
    // 🎭 Console tidy: emoji-only labels (no UPPERCASE) by default
    PrettyLoggerPlus.configureConsoleStyle(
      shortLabelFor: { for (final l in LogLevel.values) l },
    );
  });

  test('default: readable timestamp + emoji-only label', () async {
    final out = await _capturePrints(() async {
      PrettyLoggerPlus.log("Booting…", level: LogLevel.info, module: "Demo");
    });
    expect(out.length, 1);
    final line = out.first;

    // 🕒 Starts with bracketed time like: [12:34:56 PM]
    expect(line.startsWith('['), isTrue);

    // 🏷️ Has module and emoji, message present
    expect(line.contains('[Demo]'), isTrue);
    expect(line.contains('ℹ️: Booting…'), isTrue);

    // 🙈 INFO (uppercase) hidden (emoji-only style)
    expect(line.contains('INFO '), isFalse);
  });

  test('show uppercase label when style requests it (warning)', () async {
    // Only show labels for warnings/errors
    PrettyLoggerPlus.configureConsoleStyle(
      shortLabelFor: { LogLevel.debug, LogLevel.info, LogLevel.success },
    );

    final out = await _capturePrints(() async {
      PrettyLoggerPlus.log("Careful…", level: LogLevel.warning, module: "Demo");
    });
    final line = out.single;

    // Now label should be visible
    expect(line.contains('WARNING '), isTrue);
    expect(line.contains('⚠️: Careful…'), isTrue);
  });

  test('level filtering in debug (only errors)', () async {
    // Restrict debug output to only errors
    PrettyLoggerPlus.configureConsoleLevels(
      debugLevels: { LogLevel.error },
    );

    final out = await _capturePrints(() async {
      PrettyLoggerPlus.log("hello", level: LogLevel.info, module: "Demo");
      PrettyLoggerPlus.log("boom",  level: LogLevel.error, module: "Demo");
    });

    // Only one line should print (the error)
    expect(out.length, 1);
    expect(out.first.contains('❌: boom'), isTrue);
  });

  test('JSON mode prints a valid JSON payload (with prettyTs)', () async {
    final out = await _capturePrints(() async {
      PrettyLoggerPlus.log(
        "payload accepted",
        level: LogLevel.info,
        module: "API",
        json: true,
      );
    });

    final line = out.single;

    // Extract the JSON part (after the first '{')
    final idx = line.indexOf('{');
    expect(idx, greaterThanOrEqualTo(0));
    final jsonPart = line.substring(idx);
    final obj = jsonDecode(jsonPart) as Map<String, dynamic>;

    expect(obj['module'], 'API');
    expect(obj['level'], 'INFO');
    expect(obj['msg'], 'payload accepted');
    // prettyTs is present and non-empty
    expect(obj['prettyTs'] is String, isTrue);
    expect((obj['prettyTs'] as String).isNotEmpty, isTrue);
  });

  test('TimeStyle.none hides the timestamp prefix', () async {
    PrettyLoggerPlus.configureTime(style: TimeStyle.none);

    final out = await _capturePrints(() async {
      PrettyLoggerPlus.log("No time prefix", level: LogLevel.info, module: "Demo");
    });
    final line = out.single;

    // With no time, line should start directly with [Demo]
    expect(line.startsWith('[Demo]'), isTrue);
    expect(line.contains('ℹ️: No time prefix'), isTrue);
  });

  test('dateClock + millis shows a verbose, human-friendly time', () async {
    PrettyLoggerPlus.configureTime(style: TimeStyle.dateClock, showMillis: true);

    final out = await _capturePrints(() async {
      PrettyLoggerPlus.log("Verbose time", level: LogLevel.info, module: "Demo");
    });
    final line = out.single;

    // Example prefix: [03 Sep 2025 12:34:56.123 PM]
    expect(line.startsWith('['), isTrue);
    expect(line.contains('Demo'), isTrue);
    expect(line.contains('Verbose time'), isTrue);
  });
}
