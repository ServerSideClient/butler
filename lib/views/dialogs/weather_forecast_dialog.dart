import 'dart:math';

import 'package:butler/models/weather_forecast.dart';
import 'package:butler/utils/shared_preferences_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class WeatherForecastDialog extends StatelessWidget
    with SharedPreferencesAccess {
  final WeatherForecast forecast;

  const WeatherForecastDialog({Key? key, required this.forecast})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var graphData = forecast.graphData;
    final zoomPanBehavior = ZoomPanBehavior(
        // Enables pinch zooming
        enablePinching: true,
        // Enables movement within zoomed graph
        enablePanning: true);
    return AlertDialog(
      title: Text(prefs.getString(SharedPreferencesHelper.keySettingAddress) ??
          "Forecast"),
      content: SizedBox(
        width: double.maxFinite,
        child: Center(
          child: SfCartesianChart(
            zoomPanBehavior: zoomPanBehavior,
            primaryXAxis: DateTimeAxis(dateFormat: DateFormat(DateFormat.HOUR24)),
            primaryYAxis: NumericAxis(
                title: AxisTitle(text: "° C"),
                name: "axisTemperature",
                minimum: forecast.minTemperatures
                    .reduce((acc, val) => min(acc, val)),
                maximum: forecast.maxTemperatures
                    .reduce((acc, val) => max(acc, val)),
                decimalPlaces: 1),
            axes: [
              NumericAxis(
                  title: AxisTitle(text: "% Rain"),
                  name: "axisPrecipitation",
                  opposedPosition: true,
                  minimum: 0,
                  maximum: 100,
                  decimalPlaces: 0)
            ],
            series: [
              LineSeries<WeatherForecastGraphEntry, DateTime>(
                  dataSource: graphData,
                  xValueMapper: (entry, _) => entry.time,
                  yValueMapper: (entry, _) => entry.temperature,
                  yAxisName: "axisTemperature",
                  color: Colors.red),
              LineSeries<WeatherForecastGraphEntry, DateTime>(
                  dataSource: graphData,
                  xValueMapper: (entry, _) => entry.time,
                  yValueMapper: (entry, _) => entry.precipitation,
                  yAxisName: "axisPrecipitation",
                  color: Colors.blue)
            ],
          ),
        ),
      ),
    );
  }
}
