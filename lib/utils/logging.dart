import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

mixin Logging {
  @protected
  Logger get logger => Logger((this).runtimeType.toString());
}