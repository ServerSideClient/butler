import 'package:butler/utils/logging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper with Logging {
  static final SharedPreferencesHelper _instance = SharedPreferencesHelper._internal();
  SharedPreferencesHelper._internal();
  factory SharedPreferencesHelper.getInstance() => _instance;

  SharedPreferences? _prefs;

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      logger.fine("Initialized SharedPreferences");
    } on Exception catch (e) {
      logger.severe("Failed to initialize SharedPreferences", e);
    }
  }

  SharedPreferences get prefs {
    _throwNotInitialisedIfNull(_prefs);
    return _prefs!;
  }

  void _throwNotInitialisedIfNull(Object? value) {
    if (value == null) {
      throw Exception("StorageHelper not initialised.");
    }
  }
}

mixin SharedPreferencesAccess {
  @protected
  SharedPreferences get prefs => SharedPreferencesHelper.getInstance().prefs;
}