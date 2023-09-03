import 'package:butler/utils/logging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper with Logging {
  static const String _keyPrefsVersion = "prefsVersion";
  static const String _settingPrefix = "setting";
  static const String keySettingAddress = "${_settingPrefix}Address";
  static const String keySettingLongitude = "${_settingPrefix}Longitude";
  static const String keySettingLatitude = "${_settingPrefix}Latitude";
  static const String keySettingRingtoneDirectory = "${_settingPrefix}Ringtone";

  static final SharedPreferencesHelper _instance = SharedPreferencesHelper._internal();
  SharedPreferencesHelper._internal();
  factory SharedPreferencesHelper.getInstance() => _instance;

  SharedPreferences? _prefs;

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      logger.fine("Initialized SharedPreferences");
      int prefsVersion = _prefs!.getInt(_keyPrefsVersion) ?? 0;
      if (prefsVersion == 0) {
        await _prefs!.setString(keySettingAddress, "Winterthur, Zurich, Switzerland");
        await _prefs!.setDouble(keySettingLongitude, 8.7241);
        await _prefs!.setDouble(keySettingLatitude, 47.5056);
        await _prefs!.setInt(_keyPrefsVersion, 1);
      }
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