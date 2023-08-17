import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:logging_appenders/logging_appenders.dart';

class FilteredRotatingFileAppender extends RotatingFileAppender {
  final Level filterLevel;

  FilteredRotatingFileAppender({required super.baseFilePath, super.formatter, super.clock, super.keepRotateCount, super.rotateAtSizeBytes, super.rotateCheckInterval, this.filterLevel = Level.ALL});
  @override
  void handle(LogRecord record) {
    if (filterLevel <= record.level) {
      super.handle(record);
    }
  }
}

mixin Logging {
  @protected
  Logger get logger => Logger((this).runtimeType.toString());
}