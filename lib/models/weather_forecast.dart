import 'dart:math';

class WeatherForecast {
  final int entries;
  final List<double> temperatures;
  final List<double> apparentTemperatures;
  final List<double> precipitationProbability;
  final List<double> minTemperatures;
  final List<double> maxTemperatures;
  final List<double> maxPrecipitationProbability;
  final List<String> timestamps;

  const WeatherForecast(
      {required this.entries,
      required this.temperatures,
      required this.apparentTemperatures,
      required this.precipitationProbability,
      required this.minTemperatures,
      required this.maxTemperatures,
      required this.maxPrecipitationProbability,
      required this.timestamps});

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
        entries: json['hourly']['time'].length,
        temperatures: List<double>.from(
            json['hourly']['temperature_2m'].map((x) => x?.toDouble())),
        apparentTemperatures: List<double>.from(
            json['hourly']['apparent_temperature'].map((x) => x?.toDouble())),
        precipitationProbability: List<double>.from(json['hourly']
                ['precipitation_probability']
            .map((x) => x?.toDouble())),
        minTemperatures: List<double>.from(
            json['daily']['temperature_2m_min'].map((x) => x?.toDouble())),
        maxTemperatures: List<double>.from(
            json['daily']['temperature_2m_max'].map((x) => x?.toDouble())),
        maxPrecipitationProbability: List<double>.from(json['daily']
                ['precipitation_probability_max']
            .map((x) => x?.toDouble())),
        timestamps: List<String>.from(json['hourly']['time']));
  }

  @override
  String toString() {
    return "Min Temp = ${minTemperatures.reduce((acc, val) => min(acc, val))} °C\n"
        "Avg Temp = ${(temperatures.reduce((sum, val) => sum + val) / temperatures.length).round()} °C\n"
        "Max Temp = ${maxTemperatures.reduce((acc, val) => max(acc, val))} °C\n"
        "Avg Precipitation: ${(precipitationProbability.reduce((sum, val) => sum + val) / precipitationProbability.length).round()} %\n"
        "Max Precipitation: ${maxPrecipitationProbability.reduce((maximum, val) => max(maximum, val))} %";
  }

  List<WeatherForecastGraphEntry> get graphData {
    List<WeatherForecastGraphEntry> data = List.empty(growable: true);
    for (int i = 0; i < entries; i++) {
      var date = DateTime.parse(timestamps[i]);
      data.add(WeatherForecastGraphEntry(
          temperatures[i], precipitationProbability[i], date));
    }
    return data;
  }
}

class WeatherForecastGraphEntry {
  final double temperature;
  final double precipitation;
  final DateTime time;

  const WeatherForecastGraphEntry(
      this.temperature, this.precipitation, this.time);
}
