import 'dart:convert';
import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:butler/utils/shared_preferences_helper.dart';
import 'package:flutter/services.dart';
import 'package:flutter_system_ringtones/flutter_system_ringtones.dart';
import 'package:butler/models/slots.dart';
import 'package:butler/services/service.dart';
import 'package:butler/utils/list_extensions.dart';

class AlarmService extends IntentService with SharedPreferencesAccess {
  @override
  Future<void> init() async {
    await Alarm.init();
  }

  @override
  Future<void> process(Map<String, String>? slots) async {
    if (slots != null && slots["day"] != null && slots["hour"] != null) {
      Day? day = Day.fromString(slots["day"]!);
      if (day == null) {
        doOnError("Day ${slots["day"]!} is not yet supported.");
        return;
      }
      int hour = int.tryParse(slots["hour"]!) ?? -1;
      if (hour >= 0) {
        await _setAlarm(day, hour);
      } else {
        doOnError("Failed to understand when the alarm should be set for.");
      }
    }
  }

  Future<void> _setAlarm(Day day, int hour) async {
    DateTime now = DateTime.now();
    DateTime dateTime = DateTime(now.year, now.month, now.day, hour);
    dateTime.add(day.durationFromToday);
    List<AlarmSettings> alarms = Alarm.getAlarms();
    try {
      alarms.firstWhere((element) => element.dateTime == dateTime);
      // if no StateError thrown then cancel
      doOnInfo("Cancelled: Identical alarm set.");
      return;
    } on StateError {
      // no duplicate found
    }
    int maxId = -1;
    if (alarms.isNotEmpty) {
      maxId = alarms.map((e) => e.id).reduce((e, max) => (e > max) ? e : max);
    }

    var ringtone = await _getRandomRingtone();
    if (ringtone == null) {
      doOnInfo("Cancelled: No audio tracks found");
      return;
    }
    try {
      if (await Alarm.set(
          alarmSettings: AlarmSettings(
              id: ++maxId, dateTime: dateTime, assetAudioPath: ringtone))) {
        doOnInfo("Alarm set for ${day.toString()} at $hour.");
      } else {
        doOnError("Failed: Unknown error occurred by setting an alarm.");
      }
    } on AlarmException catch (e) {
      doOnError("Failed: ${e.message}");
    }
  }

  Future<String?> _getRandomRingtone() async {
    var ringtoneDirs = prefs.getStringList(
            SharedPreferencesHelper.keySettingRingtoneDirectory) ??
        [];
    String? ringtonePath;
    if (ringtoneDirs.isEmpty) {
      final manifestJson = await rootBundle.loadString('AssetManifest.json');
      var ringtoneAssets = json
          .decode(manifestJson)
          .keys
          .where((key) => key.startsWith('assets/ringtones/'));
      if (ringtoneAssets is List<String>) {
        var ringtones = ringtoneAssets.cast<String>();
        if (ringtones.isEmpty) {
          ringtonePath =
              (((await FlutterSystemRingtones.getAlarmSounds()).firstOrNull) ??
                      ((await FlutterSystemRingtones.getRingtoneSounds())
                          .firstOrNull) ??
                      ((await FlutterSystemRingtones.getNotificationSounds())
                          .firstOrNull))
                  ?.uri;
        } else {
          ringtonePath = ringtones.randomPick();
        }
      }
    } else {
      ringtonePath = await Directory(ringtoneDirs.randomPick()!)
          .list()
          .map((event) => event.path)
          .where((element) => element.endsWith(".mp3"))
          .toList()
          .then((value) => value.randomPick());
    }
    return ringtonePath;
  }
}
