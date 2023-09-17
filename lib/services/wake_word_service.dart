import 'package:butler/utils/debug.dart';
import 'package:butler/utils/logging.dart';
import 'package:butler/utils/shared_preferences_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:butler/services/service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:porcupine_flutter/porcupine_error.dart';
import 'package:porcupine_flutter/porcupine_manager.dart';

class WakeWordService extends Service with Logging, SharedPreferencesAccess, DebugMixin {

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
          _wakeWordCallback, errorCallback: _showPorcupineError);
      logger.info("Initialized Porcupine");
      if ((await requestRecordingPermissions()) == false) return;
    } on PorcupineException catch (e) {
      if (e.message != null) {
        logger.severe("Failed to initialize Porcupine: ${e.message}", e);
      }
      else {
        logger.severe("Failed to initialize Porcupine", e);
      }
      doOnError(e.message ?? e.toString());
    }
  }

  @override
  Future<void> dispose() async {
    await _porcupineManager?.delete();
  }

  void _showPorcupineError(PorcupineException e) => doOnError(e.message ?? e.toString());

  Future<bool> requestRecordingPermissions() async {
    if (await Permission.microphone.request().isGranted == false) {
      logger.warning("Request for recording permission denied.");
      doOnError("Button won't work without this permission being granted.");
      return false;
    }
    logger.info("Request for recording permission granted.");
    return true;
  }

  void _wakeWordCallback(int keywordIndex) {
    logger.info("Wake word detected");
    if (isInDebug) doOnInfo("Wake word detected");
    onWordDetected();
  }

  Future<void> listen() async {
    if (await requestRecordingPermissions() == false) return;
    if (_porcupineManager != null) {
      try {
        logger.info("Porcupine listening...");
        await _porcupineManager!.start();
        isListening.value = true;
        await Future.delayed(const Duration(seconds: 5));
        await _porcupineManager!.stop();
      } on PorcupineException catch (e) {
        if (e.message != null) {
          logger.severe("Porcupine failed while listening: ${e.message}", e);
        }
        else {
          logger.severe("Porcupine failed while listening", e);
        }
        doOnError(e.message ?? e.toString());
      } finally {
        isListening.value = false;
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