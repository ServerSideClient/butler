import 'package:butler/views/dialogs/phrase_list_dialog.dart';
import 'package:flutter/material.dart';

enum TopBarDropdownItem {
  phrasePossibilities("Possible phrases");

  final String label;

  const TopBarDropdownItem(this.label);
}

class TopBarDropdown extends StatelessWidget {
  const TopBarDropdown({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<TopBarDropdownItem>(itemBuilder: (context) => TopBarDropdownItem.values
        .map((item) => PopupMenuItem<TopBarDropdownItem>(
        value: item, child: Text(item.label)))
        .toList(growable: false),
    onSelected: (item) async {
      switch (item) {
        case TopBarDropdownItem.phrasePossibilities: await showDialog(context: context, builder: (_) => const PhraseListDialog());
      }
    },);
  }
}
