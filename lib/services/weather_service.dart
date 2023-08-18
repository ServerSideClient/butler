import 'dart:convert';

import 'package:butler/models/weather_forecast.dart';
import 'package:butler/services/service.dart';
import 'package:butler/utils/logging.dart';
import 'package:http/http.dart' as http;

import '../models/slots.dart';

class WeatherService extends IntentService with Logging {

  Uri _generateWeatherUrl(DateTime startDate, DateTime endDate) {
    String startString = "${startDate.year.toString().padLeft(4, "0")}-${startDate.month.toString().padLeft(2, "0")}-${startDate.day.toString().padLeft(2, "0")}";
    String endString = "${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, "0")}-${endDate.day.toString().padLeft(2, "0")}";
    Uri uri = Uri.https("api.open-meteo.com", "/v1/forecast", {
      "latitude": "47.5056",
      "longitude": "8.7241",
      "hourly": "temperature_2m,apparent_temperature,precipitation_probability",
      "daily": "temperature_2m_max,temperature_2m_min,precipitation_probability_max",
      "timeformat": "unixtime",
      "timezone": "Europe/Berlin",
      "start_date": startString,
      "end_date": endString
    });
    logger.info("Calling $uri");
    return uri;
  }

  @override
  Future<void> init() async {}

  @override
  Future<void> process(Map<String, String>? slots) async {
    if (slots != null && slots["day"] != null) {
      Day? day = Day.fromString(slots["day"]!);
      if (day == null) {
        doOnError("Day ${slots["day"]!} is not yet supported.");
        return;
      }
      DateTime today = DateTime.now();
      http.Response response;
      switch (day) {
        case Day.today:
          response = await http.get(_generateWeatherUrl(today, today));
          break;
        case Day.tomorrow:
          DateTime tomorrow = today.add(const Duration(days: 1));
          response = await http.get(_generateWeatherUrl(tomorrow, tomorrow));
      }
      var forecast = await _parseForecast(response);
      if (forecast != null) {
        doOnInfo(forecast.toString());
      }
    }
  }

  Future<WeatherForecast?> _parseForecast(http.Response response) async {
    logger.fine("Parsing forecast response");
    if (response.statusCode == 200) {
      return WeatherForecast.fromJson(jsonDecode(response.body));
    }
    else {
      String errorCause = response.reasonPhrase ?? "";
      try {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse != null) {
          errorCause = jsonResponse!.toString();
        }
      } on Exception {
        //
      }
      logger.warning("HTTP Response = ${response.statusCode} $errorCause");
      doOnError("Failed: HTTP Response = ${response.statusCode} $errorCause");
      return null;
    }
  }

}