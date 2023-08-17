import 'package:butler/utils/storage_helper.dart';
import 'package:flutter/material.dart';

class LogsListDialog extends StatelessWidget with StorageAccess {
  final List<String> loadedLogs;

  const LogsListDialog({super.key, this.loadedLogs = const []});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(20),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.separated(
            itemCount: loadedLogs.length,
            itemBuilder: (context, index) {
              var logFile = loadedLogs[index];
              return ListTile(
                title: Text(logFile),
                onTap: () => Navigator.of(context).pop(logFile),
              );
            },
            separatorBuilder: (context, index) => const Divider(thickness: 3, height: 0,)),
      ),
    );
  }
}