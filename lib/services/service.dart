import 'package:flutter/cupertino.dart';

abstract class Service {

  void Function(String message)? onError;

  void Function(String message)? onInfo;

  @protected
  void doOnError(String message) {
    if (onError != null) onError!(message);
  }

  @protected
  void doOnInfo(String message) {
    if (onInfo != null) onInfo!(message);
  }

  Future<void> init();

  Future<void> dispose() async {}
}

abstract class IntentService extends Service {
  Future<void> process(Map<String, String>? slots);
}