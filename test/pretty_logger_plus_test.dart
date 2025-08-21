import 'package:flutter_test/flutter_test.dart';
import 'package:pretty_logger_plus/pretty_logger_plus.dart';

void main() {
  test("Log messages with all levels", () {
    // Debug log
    PrettyLoggerPlus.log("Debug message", level: LogLevel.debug);

    // Info log
    PrettyLoggerPlus.log("Info message", level: LogLevel.info);

    // Warning log
    PrettyLoggerPlus.log("Warning message", level: LogLevel.warning);

    // Error log
    PrettyLoggerPlus.log("Error message", level: LogLevel.error);

    // ✅ If no exception is thrown, test is successful
    expect(true, true);
  });
}
