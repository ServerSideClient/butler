import 'package:flutter/foundation.dart';
import 'package:mobile_assistant/services/service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:porcupine_flutter/porcupine_error.dart';
import 'package:porcupine_flutter/porcupine_manager.dart';

class WakeWordService extends Service {

  final Future<void> Function() onWordDetected;

  WakeWordService({required this.onWordDetected});

  final ValueNotifier<bool> isListening = ValueNotifier(false);

  PorcupineManager? _porcupineManager;
  String _accessKey = "";

  set accessKey(String accessKey) => _accessKey = accessKey;

  @override
  Future<void> init() async {
    try {
      _porcupineManager = await PorcupineManager.fromKeywordPaths(
          _accessKey,
          ["assets/porcupine/android-awaken_en_android_v2_2_0.ppn"],
          _wakeWordCallback);
    } on PorcupineException catch (e) {
      doOnError(e.message ?? e.toString());
    }
  }

  @override
  Future<void> dispose() async {
    await _porcupineManager?.delete();
  }

  Future<bool> requestRecordingPermissions() async {
    if (await Permission.microphone.request().isGranted == false) {
      doOnError("Button won't work without this permission being granted.");
      return false;
    }
    return true;
  }

  void _wakeWordCallback(int keywordIndex) {
    debugPrint("KeywordIndex: $keywordIndex");
    if (keywordIndex == 0) {
      doOnInfo("Wake word detected");
    }
    onWordDetected();
  }

  Future<void> listen() async {
    if (await requestRecordingPermissions() == false) return;
    if (_porcupineManager != null) {
      try {
        await _porcupineManager!.start();
        isListening.value = true;
        await Future.delayed(const Duration(seconds: 5));
        await _porcupineManager!.stop();
        isListening.value = false;
      } on PorcupineException catch (e) {
        doOnError(e.message ?? e.toString());
      }
    }
    else {
      doOnError("PorcupineManager not initialized.");
    }
  }

  Future<void> stopListening() async {
    await _porcupineManager?.stop();
  }

}