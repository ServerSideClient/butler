import 'package:butler/models/slots.dart';
import 'package:flutter/material.dart';

class PhraseListDialog extends StatelessWidget {
  const PhraseListDialog({Key? key}) : super(key: key);

  List<RichText> get _phrases => [
    RichText(text: TextSpan(style: const TextStyle(color: Colors.black), children: [const TextSpan(text: "Set an alarm for ["), TextSpan(text: Day.asOptions, style: const TextStyle(fontStyle: FontStyle.italic)), const TextSpan(text: "] at ["), const TextSpan(text: "hour", style: TextStyle(fontStyle: FontStyle.italic)), const TextSpan(text: "].")])),
        RichText(text: TextSpan(style: const TextStyle(color: Colors.black), children: [const TextSpan(text: "How is the weather ["), TextSpan(text: Day.asOptions, style: const TextStyle(fontStyle: FontStyle.italic)), const TextSpan(text: "]?"),
        ]))];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Phrases"),
      contentPadding: const EdgeInsets.all(20),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.separated(
            itemCount: _phrases.length,
            itemBuilder: (ctx, index) => ListTile(title: _phrases[index]),
            separatorBuilder: (ctx, index) =>
                const Divider(thickness: 3, height: 0)),
      ),
    );
  }
}
