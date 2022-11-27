import 'package:flutter/material.dart';
import 'dart:async';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool isListening = false;

  String getSuggestion() =>
      (!isListening) ? "Press the button" : "Say \"Android ascend\"";

  void detectWakeWord() {
    setState(() {
      isListening = true;
    });
    Future.delayed(const Duration(seconds: 3)).then((value) => setState(() {
          isListening = false;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          child: CircleAvatar(
            backgroundColor: Colors.blue,
            child: GestureDetector(
              onTap: detectWakeWord,
              child: const Icon(Icons.record_voice_over_rounded),
            ),
          ),
        ),
        Text(getSuggestion()),
      ],
    );
  }
}
