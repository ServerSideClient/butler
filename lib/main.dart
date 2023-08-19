import 'package:butler/utils/shared_preferences_helper.dart';
import 'package:butler/views/dropdowns/top_bar_dropdown.dart';
import 'dart:io';

import 'package:butler/utils/logging.dart';
import 'package:butler/utils/storage_helper.dart';
import 'package:flutter/material.dart';
import 'package:butler/views/home_view.dart';
import 'package:butler/layouts/default_layout.dart';
import 'package:logging/logging.dart';
import 'package:logging_appenders/logging_appenders.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  hierarchicalLoggingEnabled = true;
  PrintAppender(formatter: const ColorFormatter()).attachToLogger(Logger.root);
  var sharedPrefs = SharedPreferencesHelper.getInstance();
  await sharedPrefs.init();
  StorageHelper storage = StorageHelper.getInstance();
  try {
    await storage.init();
    var logFile = File(storage.logsDir.uri.resolve(storage.logName).path);
    await logFile.create(recursive: false, exclusive: false);
    FilteredRotatingFileAppender(
        filterLevel: Level.WARNING,
        baseFilePath: logFile.path,
        formatter: const DefaultLogRecordFormatter())
        .attachToLogger(Logger.root);
  }
  finally {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Butler',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const DefaultLayout(
          title: "Butler",
          centered: true,
          topBarActions: [TopBarDropdown()],
          children: [HomeView()]),
    );
  }
}
