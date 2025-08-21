import 'package:flutter/material.dart';
import 'package:pretty_logger_plus/pretty_logger_plus.dart';

void main() {
  runApp(const ExampleApp());

  // 🔥 Example logs
  PrettyLoggerPlus.log("Debugging details here...", level: LogLevel.debug);
  PrettyLoggerPlus.log("App started successfully!", level: LogLevel.info);
  PrettyLoggerPlus.log("Something looks suspicious!", level: LogLevel.warning);
  PrettyLoggerPlus.log("App crashed!", level: LogLevel.error);
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            "Check your console logs 🌈",
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
