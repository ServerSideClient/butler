import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:butler/models/inference_intent.dart';
import 'package:butler/services/intent_listener_service.dart';
import 'package:butler/services/weather_service.dart';
import 'dart:async';

import '../services/alarm_service.dart';
import '../services/wake_word_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final AlarmService _alarmService = AlarmService();
  final WeatherService _weatherService = WeatherService();
  late final WakeWordService _wakeWordService;
  late final IntentListenerService _intentService;

  _HomeViewState() {
    _wakeWordService = WakeWordService(
      onWordDetected: () async => await detectIntent(),
    );
    _intentService = IntentListenerService(onIntent: _processIntent);
    _alarmService.onError = showError;
    _weatherService.onError = showError;
    _wakeWordService.onError = showError;
    _intentService.onError = showError;
    _alarmService.onInfo = showInfo;
    _weatherService.onInfo = showInfo;
    _wakeWordService.onInfo = showInfo;
    _intentService.onInfo = showInfo;
  }

  @override
  Future<void> dispose() async {
    await _alarmService.dispose();
    await _wakeWordService.dispose();
    await _intentService.dispose();
    await _weatherService.dispose();
    super.dispose();
  }

  Future<bool> boot() async {
    await dotenv.load(fileName: 'assets/.env');
    String? voiceAccessKey = dotenv.maybeGet('VOICE_ACCESS_KEY');
    if (voiceAccessKey != null) {
      _wakeWordService.accessKey = voiceAccessKey;
      _intentService.accessKey = voiceAccessKey;
      await _wakeWordService.init();
      await _intentService.init();
      return true;
    } else {
      showInfo("Access key for Porcupine/Rhino is missing");
      return false;
    }
  }

  void showInfo(String message) {
    SnackBar snackBar = SnackBar(content: Text(message));
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showError(String message) {
    MaterialBanner banner = MaterialBanner(content: Text(message), actions: [
      TextButton(
        onPressed: () {
          if (context.mounted) Navigator.of(context).pop();
        },
        child: const Text('DISMISS'),
      )
    ]);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showMaterialBanner(banner);
    }
  }

  Future<void> _processIntent(
      InferenceIntent intent, Map<String, String>? slots) async {
    switch (intent) {
      case InferenceIntent.alarm:
        await _alarmService.process(slots);
        break;
      case InferenceIntent.weather:
        await _weatherService.process(slots);
        break;
    }
  }

  Future<void> detectIntent() async {
    await _wakeWordService.stopListening();
    await _intentService.listen();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: boot(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          bool errorFree = snapshot.data ?? false;
          return (errorFree)
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: GestureDetector(
                          onTap: () async => await _wakeWordService.listen(),
                          child: const Icon(Icons.record_voice_over_rounded),
                        ),
                      ),
                    ),
                    ValueListenableBuilder(
                        valueListenable: _wakeWordService.isListening,
                        builder: (c, listening, _) => Text((!listening)
                            ? "Press the button"
                            : "Say \"Android awaken\"")),
                  ],
                )
              : const Placeholder();
        } else {
          return const Center(
              child: CircularProgressIndicator(
            color: Colors.grey,
          ));
        }
      },
    );
  }
}
