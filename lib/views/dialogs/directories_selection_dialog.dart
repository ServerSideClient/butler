import 'package:flutter/material.dart';
import 'package:saf/saf.dart';

class DirectoriesSelectionDialog extends StatefulWidget {
  final Future<void> Function(List<String> directories) onSubmit;
  final List<String> initialDirectories;

  const DirectoriesSelectionDialog(
      {super.key, required this.onSubmit, this.initialDirectories = const []});

  @override
  State<DirectoriesSelectionDialog> createState() =>
      _DirectoriesSelectionDialogState();
}

class _DirectoriesSelectionDialogState
    extends State<DirectoriesSelectionDialog> {
  final List<String> entries = List.empty(growable: true);

  @override
  void initState() {
    entries.addAll(widget.initialDirectories);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Choose directories"),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.separated(
          itemCount: entries.length + 1,
          itemBuilder: (ctx, index) => (index < entries.length)
              ? ListTile(
                  key: UniqueKey(),
                  title: Text(
                    entries[index],
                    style: TextStyle(
                        fontStyle:
                            (index == 0) ? FontStyle.italic : FontStyle.normal),
                  ),
                  trailing: IconButton(
                    onPressed: () async => await _removeEntry(index),
                    icon: const Icon(Icons.close),
                    color: Colors.red,
                  ),
                )
              : IconButton(
                  onPressed: () async => await _addEntry(),
                  icon: const Icon(Icons.add)),
          separatorBuilder: (ctx, index) =>
              const Divider(thickness: 3, height: 0),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async => await _clearEntries(),
          style: const ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Colors.grey)),
          child: const Text("Clear"),
        ),
        TextButton(
          onPressed: () => widget.onSubmit(entries),
          style: const ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Colors.green)),
          child: const Text("Submit"),
        )
      ],
    );
  }

  Future<void> _syncEntries() async {
    var directories = await Saf.getPersistedPermissionDirectories();
    setState(() {
      entries.clear();
      entries.addAll(directories ?? []);
    });
  }

  Future<void> _clearEntries() async {
    setState(() {
      entries.clear();
    });
  }

  Future<void> _removeEntry(int index) async {
    setState(() {
      entries.removeAt(index);
    });
  }

  Future<void> _addEntry() async {
    if ((await Saf.getDynamicDirectoryPermission(
            grantWritePermission: false)) ==
        true) {
      _syncEntries();
    }
  }
}
