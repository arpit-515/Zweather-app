import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/provider/providers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String? apiKey = dotenv.env['API_KEY'];

final weatherServiceProvider = Provider((ref) => WeatherService());

class WeatherService {
  Future<WeatherModel> getWeather(String cityName, WidgetRef ref) async {
    final connection = await ref.read(internetConnectionProvider.future);
    if (!connection) {
      throw Exception('No internet connection');
    }

    final url = Uri.parse(
      'http://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$cityName&days=3',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<List<String>> forecastCurrent = [];
      final List<List<String>> forecastFuture = [];

      for (int i = 0; i < 24; i++) {
        var hourData = data['forecast']['forecastday'][0]['hour'][i];
        forecastCurrent.add([
          hourData['time'],
          hourData['temp_c'].toString(),
          hourData['condition']['text'],
          hourData['condition']['icon'],
          hourData['is_day'].toString(),
          hourData['chance_of_rain'].toString(),
          hourData['chance_of_snow'].toString(),
        ]);
      }

      for (int i = 0; i < 2; i++) {
        var dayData = data['forecast']['forecastday'][i + 1];
        forecastFuture.add([
          dayData['day']['maxtemp_c'].toString(),
          dayData['date'],
          dayData['day']['mintemp_c'].toString(),
          dayData['day']['daily_chance_of_rain'].toString(),
          dayData['day']['condition']['text'],
          dayData['day']['condition']['icon'],
          dayData['day']['maxwind_kph'].toString(),
          dayData['day']['totalprecip_mm'].toString(),
        ]);
      }

      return WeatherModel(
        city: cityName,
        condition: data['current']['condition']['text'],
        country: data['location']['country'],
        isDay: data['current']['is_day'].toString(),
        feelslike: data['current']['feelslike_c'].toString(),
        wind: data['current']['wind_kph'].toString(),
        temperature: data['current']['temp_c'].toString(),
        iconCode: data['current']['condition']['icon'],
        humidity: data['current']['humidity'].toString(),
        cloud: data['current']['cloud'].toString(),
        dewpoint: data['current']['dewpoint_c'].toString(),
        precipitation: data['current']['precip_mm'].toString(),
        visibility: data['current']['vis_km'].toString(),
        heatIndex: data['current']['heatindex_c'].toString(),
        sunrise: data['forecast']['forecastday'][0]['astro']['sunrise'],
        sunset: data['forecast']['forecastday'][0]['astro']['sunset'],
        moonphase: data['forecast']['forecastday'][0]['astro']['moon_phase'],
        forecastCurrentDay: forecastCurrent,
        forecastFutureDays: forecastFuture,
      );
    } else {
      throw Exception('Failed to fetch weather');
    }
  }
}