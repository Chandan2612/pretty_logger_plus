import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pretty_logger_plus/pretty_logger_plus.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 👇 Start with defaults so you can see how it looks out of the box
  _applyDefaults();

  // 🧯 Catch framework & async errors and log as ERROR ❌
  FlutterError.onError = (details) {
    PrettyLoggerPlus.log(details.exceptionAsString(),
        level: LogLevel.error, module: "FlutterError");
    FlutterError.dumpErrorToConsole(details);
  };
  runZonedGuarded(() {
    runApp(const DemoApp());

    // 🟢 DEMO A: DEFAULTS (no config needed)
    PrettyLoggerPlus.log("=== DEMO A: DEFAULTS ===",
        level: LogLevel.info, module: "Demo");
    PrettyLoggerPlus.log("App booting…",        level: LogLevel.info,    module: "Startup");
    PrettyLoggerPlus.log("Loaded 120 questions", level: LogLevel.success, module: "API");
    PrettyLoggerPlus.log("Slow response (950ms)",level: LogLevel.warning, module: "Network");
    PrettyLoggerPlus.log("Submit failed",        level: LogLevel.error,   module: "Submit");

    // 🟡 DEMO B: APPLY TWEAKS (more info, still clean)
    _applyTweaks();
    PrettyLoggerPlus.log("=== DEMO B: CONFIGURED ===",
        level: LogLevel.info, module: "Demo");
    PrettyLoggerPlus.log("App booted (tweaked time/levels/style)",
        level: LogLevel.info, module: "Startup");
  }, (error, stack) {
    PrettyLoggerPlus.log("Uncaught: $error\n$stack",
        level: LogLevel.error, module: "Zoned");
  });
}

/// ✅ Defaults (simple & readable out-of-the-box)
void _applyDefaults() {
  // Time: [12:34:56 PM], local, no ms
  PrettyLoggerPlus.configureTime(
    style: TimeStyle.clock,
    local: true,
    showMillis: false,
  );
  // Show all in debug, only errors in release
  PrettyLoggerPlus.configureConsoleLevels(
    debugLevels: { for (final l in LogLevel.values) l },
    releaseLevels: { LogLevel.error },
  );
  // Emoji-only labels for all levels (tidy console)
  PrettyLoggerPlus.configureConsoleStyle(
    shortLabelFor: { for (final l in LogLevel.values) l },
  );
}

/// ✨ Tweaks (date+ms, warn+error in release, labels for warn/error)
void _applyTweaks() {
  // Time: [03 Sep 2025 12:34:56.123 PM]
  PrettyLoggerPlus.configureTime(
    style: TimeStyle.dateClock,
    local: true,
    showMillis: true,
  );
  // Debug: all | Release: warnings + errors
  PrettyLoggerPlus.configureConsoleLevels(
    debugLevels: { for (final l in LogLevel.values) l },
    releaseLevels: { LogLevel.warning, LogLevel.error },
  );
  // Keep emoji-only for low-noise; show labels for warn/error
  PrettyLoggerPlus.configureConsoleStyle(
    shortLabelFor: { LogLevel.debug, LogLevel.info, LogLevel.success },
  );
}

class DemoApp extends StatefulWidget {
  const DemoApp({super.key});
  @override
  State<DemoApp> createState() => _DemoAppState();
}

class _DemoAppState extends State<DemoApp> {
  bool tweaked = true; // current profile

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "PrettyLoggerPlus Demo",
      home: Scaffold(
        appBar: AppBar(title: const Text("PrettyLoggerPlus (console only)")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔀 Switch between BOTH demos at runtime
                Wrap(
                  spacing: 10,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _applyDefaults();
                        setState(() => tweaked = false);
                        PrettyLoggerPlus.log("Switched to DEFAULTS",
                            level: LogLevel.info, module: "Demo");
                      },
                      child: const Text("Use DEFAULTS"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _applyTweaks();
                        setState(() => tweaked = true);
                        PrettyLoggerPlus.log("Switched to CONFIGURED",
                            level: LogLevel.info, module: "Demo");
                      },
                      child: const Text("Use CONFIGURED"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  tweaked
                      ? "Mode: CONFIGURED (date+ms, warn+error in release)"
                      : "Mode: DEFAULTS (clock only, errors in release)",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // 🔘 Log buttons
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ElevatedButton(
                      onPressed: () => PrettyLoggerPlus.log(
                        "Debug details…",
                        level: LogLevel.debug,
                        module: "Demo",
                      ),
                      child: const Text("Debug 🐞"),
                    ),
                    ElevatedButton(
                      onPressed: () => PrettyLoggerPlus.log(
                        "App ready!",
                        level: LogLevel.info,
                        module: "Demo",
                      ),
                      child: const Text("Info ℹ️"),
                    ),
                    ElevatedButton(
                      onPressed: () => PrettyLoggerPlus.log(
                        "All good ✅",
                        level: LogLevel.success,
                        module: "Demo",
                      ),
                      child: const Text("Success ✅"),
                    ),
                    ElevatedButton(
                      onPressed: () => PrettyLoggerPlus.log(
                        "Hmm, slow API…",
                        level: LogLevel.warning,
                        module: "Demo",
                      ),
                      child: const Text("Warning ⚠️"),
                    ),
                    ElevatedButton(
                      onPressed: () => PrettyLoggerPlus.log(
                        "Kaboom! Simulated error.",
                        level: LogLevel.error,
                        module: "Demo",
                      ),
                      child: const Text("Error ❌"),
                    ),
                    OutlinedButton(
                      onPressed: () => PrettyLoggerPlus.log(
                        "payload accepted",
                        level: LogLevel.info,
                        module: "API",
                        json: true, // 👈 machine-readable JSON in console
                      ),
                      child: const Text("JSON log"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
