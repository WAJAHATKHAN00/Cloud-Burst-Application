import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String apiKey = "e0c42476cbfb47c60a47e024140742b3";

  // 🌦 Fetch weather forecast
  static Future<Map<String, dynamic>> fetchWeather(double lat, double lon) async {
    final url =
        "https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric";

    final response = await http.get(Uri.parse(url));

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load weather");
    }
  }

  // 🌍 Get city name from coordinates (Reverse Geocoding)
  static Future<String> getCityName(double lat, double lon) async {
    final url =
        "https://api.openweathermap.org/geo/1.0/reverse?lat=$lat&lon=$lon&limit=1&appid=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data.isNotEmpty) {
        final city = data[0]["name"];
        final country = data[0]["country"];
        return "$city, $country";
      }
    }

    return ""; // fallback handled in UI
  }
}