import 'dart:io';

import 'package:butler/utils/logging.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class StorageHelper with Logging {
  static final StorageHelper _instance = StorageHelper._internal();
  factory StorageHelper.getInstance() => _instance;
  StorageHelper._internal();

  Directory? _logsDir;
  final String logName = "logs.txt";

  Future<void> init() async {
    _logsDir = Directory(join((await getApplicationDocumentsDirectory()).path, "logs"));
    await _logsDir!.create();
  }

  void _throwNotInitialisedIfNull(Object? value) {
    if (value == null) {
      throw Exception("StorageHelper not initialised.");
    }
  }

  Directory get logsDir {
    _throwNotInitialisedIfNull(_logsDir);
    return _logsDir!;
  }
}

mixin StorageAccess {
  @protected
  StorageHelper get storage => StorageHelper.getInstance();
}