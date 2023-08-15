import 'package:butler/services/service.dart';
import 'package:rhino_flutter/rhino.dart';
import 'package:rhino_flutter/rhino_error.dart';
import 'package:rhino_flutter/rhino_manager.dart';

import '../models/inference_intent.dart';

class IntentListenerService extends Service {

  final Future<void> Function(InferenceIntent intent, Map<String, String>? slots) onIntent;
  IntentListenerService({required this.onIntent});

  RhinoManager? _rhinoManager;
  bool _isProcessing = false;

  String _accessKey = "";

  set accessKey(String accessKey) => _accessKey = accessKey;

  @override
  Future<void> init() async {
    try {
      _rhinoManager = await RhinoManager.create(
          _accessKey,
          "assets/rhino/mobile-assistant-v1_en_android_v2_2_0.rhn",
          _intentCallback,
      endpointDurationSec: 2);
    } on RhinoException catch (e) {
      doOnError(e.message ?? e.toString());
    }
  }

  void _intentCallback(RhinoInference inference) {
    if (inference.isUnderstood ?? false) {
      if (inference.intent != null && _isProcessing == false) {
        var intent = InferenceIntent.fromString(inference.intent!);
        if (intent != null) {
          _isProcessing = true;
          onIntent(intent, inference.slots).whenComplete(() => _isProcessing = false);
        }
        else {
          doOnError("Intent ${inference.intent!} is not yet supported.");
        }
      }
      doOnInfo((inference.slots ?? <String, String>{})
          .entries
          .map((e) => "Slot ${e.key}\tValue ${e.value}")
          .toString());
    } else {
      doOnError("Command not understood");
    }
  }

  Future<void> listen() async {
    if (_rhinoManager != null) {
      try {
        await _rhinoManager!.process();
      } on RhinoException catch (e) {
        doOnError(e.message ?? e.toString());
      }
    }
    else {
      doOnError("RhinoManager not initialized.");
    }
  }
}