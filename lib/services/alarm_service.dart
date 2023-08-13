import 'package:alarm/alarm.dart';
import 'package:flutter_system_ringtones/flutter_system_ringtones.dart';
import 'package:mobile_assistant/models/slots.dart';
import 'package:mobile_assistant/services/service.dart';

class AlarmService extends IntentService {
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
        _setAlarm(day, hour);
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
    int maxId = alarms.map((e) => e.id).reduce((e, max) => (e > max) ? e : max);
    var ringtone = ((await FlutterSystemRingtones.getAlarmSounds())
        .firstOrNull) ??
        ((await FlutterSystemRingtones.getRingtoneSounds()).firstOrNull) ??
        ((await FlutterSystemRingtones.getNotificationSounds()).firstOrNull);
    if (ringtone == null) {
      doOnInfo("Cancelled: No audio tracks found");
      return;
    }
    try {
      if (await Alarm.set(
          alarmSettings: AlarmSettings(
              id: ++maxId,
              dateTime: dateTime,
              assetAudioPath: ringtone.uri)) == false) {
        doOnInfo("Failed: Unknown error occurred by setting an alarm.");
      }
    } on AlarmException catch (e) {
      doOnInfo("Failed: ${e.message}");
    }
  }

}