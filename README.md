# 🌈 pretty_logger_plus

A colorful, emoji-friendly Flutter **console logger** with **automatic debug/release detection**.
No more boring `print()` — make your logs pop ✨

> **Version:** `^1.0.3` (console-only logging; no file I/O by default)

---

## 🚀 Features
- ✅ Zero-config: just call `PrettyLoggerPlus.log(...)` and go
- 🕒 Human-friendly timestamps (12-hour clock by default) — configurable
- 🌈 Colored output + emojis for levels (colors in debug on native terminals)
- 🧠 Smart policies: **all levels** in debug, **errors only** in release (tweakable)
- 🏷️ Clean console: **emoji-only** labels by default (show UPPERCASE on chosen levels)
- 🧩 JSON line output for machine parsing
- 🪝 `onRecord` hook so you can keep a **small in-memory buffer** or export to **temp** on demand
- 🌐 Web-friendly (prints to console; colors disabled by browsers)

---

## 📦 Installation
Add this to your `pubspec.yaml`:
```yaml
dependencies:
  pretty_logger_plus: ^1.0.3
```

---

## ⚡ Quick Start (no config)
```dart
import 'package:flutter/material.dart';
import 'package:pretty_logger_plus/pretty_logger_plus.dart';

void main() {
  runApp(const MyApp());

  // 🌈 Logs you’ll see in console (all levels in debug; only errors in release)
  PrettyLoggerPlus.log("App booting…",        level: LogLevel.info,    module: "Startup");
  PrettyLoggerPlus.log("Loaded 120 questions", level: LogLevel.success, module: "API");
  PrettyLoggerPlus.log("Slow response (950ms)",level: LogLevel.warning, module: "Network");
  PrettyLoggerPlus.log("Submit failed",        level: LogLevel.error,   module: "Submit");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => const MaterialApp(home: Scaffold(body: Center(child: Text("Check console 🌈"))));
}
```

**Example output (debug):**
```
[12:34:56 PM] [Startup] ℹ️: App booting…
[12:34:56 PM] [API] ✅: Loaded 120 questions
[12:34:56 PM] [Network] ⚠️: Slow response (950ms)
[12:34:57 PM] [Submit] ❌: Submit failed
```

---

## 🎛️ Optional Configuration (one-liners)

### 1) Time format
```dart
PrettyLoggerPlus.configureTime(
  style: TimeStyle.clock,      // ▶ default: [12:34:56 PM]
  // TimeStyle.dateClock       // ▶ [03 Sep 2025 12:34:56 PM]
  local: true,                 // ▶ true = local time; false = UTC
  showMillis: false,           // ▶ set true to show .SSS
);
```

### 2) What prints in debug vs release
```dart
PrettyLoggerPlus.configureConsoleLevels(
  debugLevels: { for (final l in LogLevel.values) l },     // ▶ all in debug
  releaseLevels: { LogLevel.warning, LogLevel.error },     // ▶ show warning+error in release
);
```

### 3) Label style (emoji-only vs label+emoji)
```dart
// ▶ Keep console tidy: emoji-only for low-noise levels; show UPPERCASE for warn/error
PrettyLoggerPlus.configureConsoleStyle(
  shortLabelFor: { LogLevel.debug, LogLevel.info, LogLevel.success },
);
```

### 4) Catch and log framework/async errors (recommended)
```dart
FlutterError.onError = (details) {
  PrettyLoggerPlus.log(details.exceptionAsString(), level: LogLevel.error, module: "FlutterError");
  FlutterError.dumpErrorToConsole(details);
};

runZonedGuarded(() => runApp(const MyApp()), (error, stack) {
  PrettyLoggerPlus.log("Uncaught: $error\n$stack", level: LogLevel.error, module: "Zoned");
});
```

---

## 🧩 JSON Logs (no file; printed to console)
```dart
PrettyLoggerPlus.log(
  "payload accepted",
  level: LogLevel.info,
  module: "API",
  json: true, // 👈 prints a compact JSON line (also includes prettyTs)
);
```
Example (console):
```
ℹ️ {"ts":"2025-09-03T12:35:01.123Z","prettyTs":"12:35:01 PM","module":"API","level":"INFO","msg":"payload accepted"}
```

---

## 🪝 In-Memory Buffer + Temp Export (optional, still no constant disk I/O)
Use the `onRecord` hook to keep the last N logs in memory, then write them **once** to the **OS temp** folder when you need to share a log.

```dart
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

final List<String> _ring = [];
const int _maxLines = 500;

void setupTempLogRing() {
  PrettyLoggerPlus.onRecord = (e) {
    final jsonLine = const JsonEncoder().convert(e); // e is Map<String,dynamic>
    _ring.add(jsonLine);
    if (_ring.length > _maxLines) _ring.removeAt(0);
  };
}

Future<String> saveLogsToTempFile() async {
  final dir = await getTemporaryDirectory();             // e.g., /data/user/0/<app>/cache
  final path = "${dir.path}/pretty_logger_plus_temp.log";
  final file = File(path);
  await file.writeAsString(_ring.join('\n'));
  return path;
}
```
> ✅ No background writing. The app remains fast; you export only when you choose.

---

## 🔍 Example with both profiles (defaults & configured)
```dart
void main() {
  // Defaults are fine (clock time, all levels in debug, errors in release, emoji-only labels)
  PrettyLoggerPlus.log("Defaults active", level: LogLevel.info, module: "Demo");

  // Apply optional tweaks
  PrettyLoggerPlus.configureTime(style: TimeStyle.dateClock, showMillis: true);
  PrettyLoggerPlus.configureConsoleLevels(
    debugLevels: { for (final l in LogLevel.values) l },
    releaseLevels: { LogLevel.warning, LogLevel.error },
  );
  PrettyLoggerPlus.configureConsoleStyle(
    shortLabelFor: { LogLevel.debug, LogLevel.info, LogLevel.success },
  );
  PrettyLoggerPlus.log("Configured mode active", level: LogLevel.info, module: "Demo");
}
```

---

## 🧪 Testing
- Capture prints with a `ZoneSpecification` and **strip ANSI** colors first:
```dart
String stripAnsi(String s) => s.replaceAll(RegExp(r'\x1B\[[0-9;]*m'), '');
Future<List<String>> capturePrints(Future<void> Function() body) async {
  final lines = <String>[];
  final spec = ZoneSpecification(print: (_, __, ___, String msg) => lines.add(stripAnsi(msg)));
  await Zone.current.fork(specification: spec).run(body);
  return lines;
}
```
- Then assert on **plain text** (timestamps, labels, JSON structure).

Run:
```bash
flutter test -r expanded
```

---

## ⚠️ Notes
- Colors show in native debug terminals; browsers (web) ignore ANSI.
- This package does **not** write logs to disk by default. If you need files, implement a small sink using `onRecord` (see above).

---

## 📜 License
MIT

---

## ❤️ Thanks
Built to make Flutter logs easier to scan at a glance — with colors, emojis, and sensible defaults.
