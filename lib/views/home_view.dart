import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';

import 'package:porcupine_flutter/porcupine.dart';
import 'package:porcupine_flutter/porcupine_manager.dart';
import 'package:porcupine_flutter/porcupine_error.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _isListening = false;
  bool _isInitializing = true;
  PorcupineManager? _porcupineManager;
  String? _porcupineAccessKey;

  String getSuggestion() =>
      (!_isListening) ? "Press the button" : "Say \"Android ascend\"";

  @override
  void initState() {
    super.initState();
    dotenv.load().then((_) async {
      _porcupineAccessKey = dotenv.env['PORCUPINE_ACCESS_KEY'];
      try {
        _porcupineManager = await PorcupineManager.fromBuiltInKeywords(
            _porcupineAccessKey!,
            [BuiltInKeyword.PORCUPINE, BuiltInKeyword.BUMBLEBEE],
            _wakeWordCallback);
      } on PorcupineException catch (err) {
        // handle porcupine init error
      }
    }).then((_) =>
        setState(() => {
        _isInitializing = false,
        })
    );
  }

  void createPorcupineManager() async {
    if (_porcupineAccessKey == null) {
      return;
    }
  }

  void _wakeWordCallback(int keywordIndex) {
    if (keywordIndex == 0) {
      // porcupine detected
    }
    else if (keywordIndex == 1) {
      // bumblebee detected
    }
  }

  void detectWakeWord() {
    setState(() {
      _isListening = true;
    });
    Future.delayed(const Duration(seconds: 3)).then((value) =>
        setState(() {
          _isListening = false;
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
