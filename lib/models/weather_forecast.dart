import 'dart:math';

class WeatherForecast {
  final List<double> temperatures;
  final List<double> apparentTemperatures;
  final List<double> precipitationProbability;
  final List<double> minTemperatures;
  final List<double> maxTemperatures;
  final List<double> maxPrecipitationProbability;

  const WeatherForecast(
      {required this.temperatures,
      required this.apparentTemperatures,
      required this.precipitationProbability,
      required this.minTemperatures,
      required this.maxTemperatures,
      required this.maxPrecipitationProbability});

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
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
            .map((x) => x?.toDouble())));
  }

  @override
  String toString() {
    return "Min Temp = ${minTemperatures.reduce((acc, val) => min(acc, val))} °C\n"
        "Avg Temp = ${(temperatures.reduce((sum, val) => sum + val) / temperatures.length).round()} °C\n"
        "Max Temp = ${maxTemperatures.reduce((acc, val) => max(acc, val))} °C\n"
        "Avg Precipitation: ${(precipitationProbability.reduce((sum, val) => sum + val) / precipitationProbability.length).round()} %\n"
        "Max Precipitation: ${maxPrecipitationProbability.reduce((maximum, val) => max(maximum, val))} %";
  }
}
