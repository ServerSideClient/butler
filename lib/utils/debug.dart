import 'package:butler/utils/shared_preferences_helper.dart';

mixin DebugMixin on SharedPreferencesAccess {
  bool get isInDebug =>
      prefs.getBool(SharedPreferencesHelper.keySettingDebug) ?? false;
}
