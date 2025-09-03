# Changelog

## 1.0.1 - 2025-08-20
- 🔥 Initial release as `pretty_logger_plus`
- ✅ Basic log levels: debug, info, warning, error
- 🎉 Added emoji indicators for log levels
- 🎨 Colored console output

## 1.0.2
- Fixed README package name
- Minor cleanup

## 1.0.3 - 2025-09-03
### Added
- Console-only logger (no file I/O) with emoji + ANSI colors.
- Human-friendly timestamps (`configureTime`): clock, date+clock, milliseconds, local/UTC.
- Console policies (`configureConsoleLevels`) to control which levels print in debug/release.
- Label style control (`configureConsoleStyle`) — emoji-only or show UPPERCASE labels for selected levels.
- JSON console output (`json: true`) including `prettyTs` for readability.
- `onRecord` hook so apps can keep a small **in-memory** ring buffer or export to a **temp** file on demand (optional).
- Example `main.dart` demonstrating **defaults** and **configured** modes with runtime switching.
- Test suite for console mode: timestamp formatting, short/long labels, level filtering, JSON, TimeStyle.none, dateClock+millis.
- Test helper strips ANSI color codes to keep assertions stable across terminals/CI.
