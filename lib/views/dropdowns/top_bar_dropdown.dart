import 'dart:io';

import 'package:butler/utils/logging.dart';
import 'package:butler/utils/storage_helper.dart';
import 'package:butler/views/dialogs/logs_list_dialog.dart';
import 'package:butler/views/dialogs/phrase_list_dialog.dart';
import 'package:butler/views/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

enum TopBarDropdownItem {
  phrasePossibilities("Possible phrases"),
  showLogs("Logs"),
  openSettings("Settings");

  final String label;

  const TopBarDropdownItem(this.label);
}

class TopBarDropdown extends StatelessWidget with StorageAccess, Logging {
  const TopBarDropdown({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<TopBarDropdownItem>(
      itemBuilder: (context) => TopBarDropdownItem.values
          .map((item) => PopupMenuItem<TopBarDropdownItem>(
              value: item, child: Text(item.label)))
          .toList(growable: false),
      onSelected: (item) async {
        switch (item) {
          case TopBarDropdownItem.phrasePossibilities:
            await showDialog(
                context: context, builder: (_) => const PhraseListDialog());
            break;
          case TopBarDropdownItem.showLogs:
            await _callLogs(context);
            break;
          case TopBarDropdownItem.openSettings:
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const SettingsView()));
        }
      },
    );
  }

  Future<void> _callLogs(BuildContext context) async {
    var logs = await storage.logsDir
        .list(recursive: false, followLinks: false)
        .where((event) => event.statSync().type == FileSystemEntityType.file)
        .map((entity) => entity.uri.path)
        .where((entity) => entity.endsWith(".txt"))
        .toList();
    if (context.mounted) {
      var logFile = await showDialog(
          context: context,
          builder: (_) => LogsListDialog(
                loadedLogs: logs,
              ));
      if (logFile == null) return;
      var tempDir = await getTemporaryDirectory();
      var tempLogsDir = await tempDir.createTemp("block_algebra_logs");
      var tempLogsFile = File(join(tempLogsDir.path, "logs.txt")).path;
      await File(logFile).copy(tempLogsFile);
      var openResult = await OpenFile.open(tempLogsFile);
      logger.info("${openResult.type}: ${openResult.message}");
    }
  }
}
