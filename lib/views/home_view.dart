import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';

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

  String getSuggestion() =>
      (!_isListening) ? "Press the button" : "Say \"Android ascend\"";

  @override
  void initState() {
    super.initState();
    dotenv.load(fileName: 'assets/.env').then((_) async {
      String? porcupineAccessKey = dotenv.maybeGet('PORCUPINE_ACCESS_KEY');
      if (porcupineAccessKey != null) {
        await initPorcupine(porcupineAccessKey);
      }
    }).then((_) => setState(() => {
          _isInitializing = false,
        }));
  }

  Future<void> initPorcupine(String accessKey) async {
    try {
      _porcupineManager = await PorcupineManager.fromKeywordPaths(
          accessKey,
          ["assets/porcupine/android-ascend_en_android_v2_1_0.ppn"],
          _wakeWordCallback);
    } on PorcupineException catch (err) {
      showMessage(err.toString());
    }
  }

  void showMessage(String message) {
    SnackBar snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _wakeWordCallback(int keywordIndex) {
    if (keywordIndex == 0) {
      showMessage("android ascend detected");
    }
  }

  Future<void> detectWakeWord() async {
    setState(() {
      _isListening = true;
    });
    try {
      await _porcupineManager!.start();
    } on PorcupineException catch (ex) {
      showMessage(ex.toString());
    }
    Future.delayed(const Duration(seconds: 3)).then((value) => {
          _porcupineManager!.stop().then((_) => {
                setState(() {
                  _isListening = false;
                })
              })
        });
  }

  @override
  Widget build(BuildContext context) {
    return (_isInitializing)
        ? const Center(
            child: CircularProgressIndicator(
            color: Colors.grey,
          ))
        : Column(
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
