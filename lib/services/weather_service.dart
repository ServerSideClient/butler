import 'package:mobile_assistant/services/service.dart';

import '../models/slots.dart';

class WeatherService extends IntentService {
  @override
  Future<void> init() async {

  }

  @override
  Future<void> process(Map<String, String>? slots) async {
    if (slots != null && slots["day"] != null) {
      Day? day = Day.fromString(slots["day"]!);
      if (day == null) {
        doOnError("Day ${slots["day"]!} is not yet supported.");
        return;
      }
      switch (day) {
        case Day.today:
          break;
        case Day.tomorrow:
          break;
      }
    }
  }

}