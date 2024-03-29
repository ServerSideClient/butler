import 'package:butler/models/weather_forecast.dart';
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
  late final WeatherService _weatherService;
  late final WakeWordService _wakeWordService;
  late final IntentListenerService _intentService;

  _HomeViewState() {
    _wakeWordService = WakeWordService(
      onWordDetected: () async => await detectIntent(),
    );
    _weatherService = WeatherService(onGraphRequest: _requestGraph);
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
      await _alarmService.init();
      await _weatherService.init();
      return true;
    } else {
      showInfo("Access key for Porcupine/Rhino is missing");
      return false;
    }
  }

  void showInfo(String message) {
    SnackBar snackBar = SnackBar(content: Text(message), behavior: SnackBarBehavior.floating);
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showError(String message) {
    MaterialBanner banner = MaterialBanner(content: Text(message), actions: [
      TextButton(
        onPressed: () {
          if (context.mounted) {
            ScaffoldMessenger.of(context).hideCurrentMaterialBanner(
                reason: MaterialBannerClosedReason.dismiss);
          }
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
    try {
      switch (intent) {
        case InferenceIntent.alarm:
          await _alarmService.process(slots);
          break;
        case InferenceIntent.weather:
          await _weatherService.process(slots);
          break;
      }
    } on Exception catch (e) {
      showError(e.toString());
    }
  }

  Future<void> detectIntent() async {
    await _wakeWordService.stopListening();
    await _intentService.listen();
  }

  Future<void> _requestGraph(WeatherForecast forecast) async {
    ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
        content: const Text("Would you like to see it graphed?"),
        actions: [
          TextButton(onPressed: () async {
            // Close Summary
            ScaffoldMessenger.of(context).hideCurrentSnackBar(reason: SnackBarClosedReason.dismiss);
            if (context.mounted) {
              ScaffoldMessenger.of(context)
                .hideCurrentMaterialBanner(
                reason: MaterialBannerClosedReason.dismiss);
              await _weatherService.showGraph(forecast, context);
            }
          }, child: const Text("Yes")),
          TextButton(
              onPressed: () => ScaffoldMessenger.of(context)
                  .hideCurrentMaterialBanner(
                      reason: MaterialBannerClosedReason.dismiss),
              child: const Text("No")),
        ]));
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.center,
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
