import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi_sahayak/src/features/weather/domain/weather.dart';
import 'package:dio/dio.dart';

class WeatherRepository {
  final Dio _dio = Dio();
  
  Future<Weather> fetchCurrentWeather() async {
    try {
      // In a real project, you would use:
      // final response = await _dio.get('https://api.openweathermap.org/data/2.5/weather?q=Patna&appid=YOUR_KEY&units=metric');
      
      // Removed artificial delay for better performance
      return Weather(
        temperature: 29.0,
        condition: 'Partly Cloudy',
        location: 'Patna, Bihar',
        humidity: 62,
        windSpeed: 8.5,
      );
    } catch (e) {
      // Fallback if API fails
      return Weather(
        temperature: 27.0,
        condition: 'Clear Sky',
        location: 'Patna, Bihar',
        humidity: 50,
        windSpeed: 5.0,
      );
    }
  }
}

final weatherRepositoryProvider = Provider((ref) => WeatherRepository());

final currentWeatherProvider = FutureProvider<Weather>((ref) {
  return ref.watch(weatherRepositoryProvider).fetchCurrentWeather();
});
