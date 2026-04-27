import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

enum LogLevel { verbose, debug, info, warn, error }

extension on LogLevel {
  String get prefix => name.toUpperCase();
  int get value => index;
}

class Logger {
  static LogLevel get _minLevel => kReleaseMode ? LogLevel.info : LogLevel.verbose;

  final String name;
  Logger(this.name);

  bool _shouldLog(LogLevel level) => level.value >= _minLevel.value;

  void v(String msg, {Object? error, StackTrace? stack}) => _log(LogLevel.verbose, msg, error, stack);
  void d(String msg, {Object? error, StackTrace? stack}) => _log(LogLevel.debug, msg, error, stack);
  void i(String msg, {Object? error, StackTrace? stack}) => _log(LogLevel.info, msg, error, stack);
  void w(String msg, {Object? error, StackTrace? stack}) => _log(LogLevel.warn, msg, error, stack);
  void e(String msg, {Object? error, StackTrace? stack}) => _log(LogLevel.error, msg, error, stack);

  void _log(LogLevel level, String msg, Object? error, StackTrace? stack) {
    if (!_shouldLog(level)) return;

    final now = DateTime.now().toUtc().toIso8601String().split('.')[0];
    final prefix = level.prefix;
    final loggerName = '$now [$prefix] $name';

    developer.log(
      msg,
      level: level.value * 200,
      name: loggerName,
      error: error,
      stackTrace: stack,
      zone: Zone.current,
    );
  }
}