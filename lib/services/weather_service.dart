import 'dart:convert';

import 'package:butler/models/weather_forecast.dart';
import 'package:butler/services/service.dart';
import 'package:butler/utils/logging.dart';
import 'package:butler/utils/shared_preferences_helper.dart';
import 'package:butler/views/dialogs/weather_forecast_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../models/slots.dart';

class WeatherService extends IntentService
    with Logging, SharedPreferencesAccess {
  final Function(WeatherForecast forecast)? onGraphRequest;

  WeatherService({this.onGraphRequest});

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
        if (onGraphRequest != null) onGraphRequest!(forecast);
      }
    }
  }

  Future<void> showGraph(WeatherForecast forecast, BuildContext context) async {
    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    try {
      if (context.mounted) {
        await showDialog(
            context: context,
            builder: (_) => WeatherForecastDialog(forecast: forecast));
      }
    } finally {
      await SystemChrome.setPreferredOrientations([]);
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, "0")}-${date.month.toString().padLeft(2, "0")}-${date.day.toString().padLeft(2, "0")}";
  }

  Uri _generateWeatherUrl(DateTime startDate, DateTime endDate) {
    Uri uri = Uri.https("api.open-meteo.com", "/v1/forecast", {
      "latitude":
          (prefs.getDouble(SharedPreferencesHelper.keySettingLatitude) ?? 0)
              .toString(),
      "longitude":
          (prefs.getDouble(SharedPreferencesHelper.keySettingLongitude) ?? 0)
              .toString(),
      "hourly": "temperature_2m,apparent_temperature,precipitation_probability",
      "daily":
          "temperature_2m_max,temperature_2m_min,precipitation_probability_max",
      "timezone": "Europe/Berlin",
      "start_date": _formatDate(startDate),
      "end_date": _formatDate(endDate)
    });
    logger.info("Calling $uri");
    return uri;
  }

  Future<WeatherForecast?> _parseForecast(http.Response response) async {
    logger.fine("Parsing forecast response");
    if (response.statusCode == 200) {
      return WeatherForecast.fromJson(jsonDecode(response.body));
    } else {
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
