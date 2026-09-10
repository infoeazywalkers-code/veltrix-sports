import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  Future<Map<String, dynamic>> fetchCurrentWeather(
    double lat,
    double lon,
  ) async {
    final url = Uri.parse(
      '$_baseUrl?latitude=${lat.toStringAsFixed(4)}&longitude=${lon.toStringAsFixed(4)}'
      '&current=temperature_2m,relative_humidity_2m,apparent_temperature,'
      'precipitation,weather_code,wind_speed_10m,wind_direction_10m,wind_gusts_10m'
      '&wind_speed_unit=kmh',
    );

    try {
      final res = await http.get(url).timeout(const Duration(seconds: 5));
      if (res.statusCode != 200) throw Exception('Weather API error');
      final json = jsonDecode(res.body);
      final current = json['current'];

      final tempC = (current['temperature_2m'] as num).toDouble();
      final windKmh = (current['wind_speed_10m'] as num).toDouble();
      final windDir = (current['wind_direction_10m'] as num?)?.toInt() ?? 0;
      final humidity = (current['relative_humidity_2m'] as num?)?.toInt() ?? 45;
      final code = (current['weather_code'] as num?)?.toInt() ?? 0;

      return {
        'tempC': tempC,
        'tempF': (tempC * 9 / 5 + 32).toStringAsFixed(1),
        'condition': _parseWMOCode(code),
        'windSpeedKmh': windKmh,
        'windSpeedMph': (windKmh * 0.621371).toStringAsFixed(1),
        'windDirectionDeg': windDir,
        'windDirectionCardinal': _getCardinalDirection(windDir),
        'humidityPct': humidity,
        'isLive': true,
        'source': 'Open-Meteo',
      };
    } catch (_) {
      return _fallbackWeather();
    }
  }

  String _parseWMOCode(int code) {
    switch (code) {
      case 0:
        return 'Clear Sky';
      case 1:
        return 'Mainly Clear';
      case 2:
        return 'Partly Cloudy';
      case 3:
        return 'Overcast';
      case 45:
      case 48:
        return 'Fog';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 61:
        return 'Light Rain';
      case 63:
        return 'Moderate Rain';
      case 65:
        return 'Heavy Rain';
      case 71:
      case 73:
      case 75:
        return 'Snowfall';
      case 80:
      case 81:
      case 82:
        return 'Rain Showers';
      case 95:
        return 'Thunderstorm';
      default:
        return 'Fair';
    }
  }

  String _getCardinalDirection(int degrees) {
    const cardinals = [
      'N',
      'NNE',
      'NE',
      'ENE',
      'E',
      'ESE',
      'SE',
      'SSE',
      'S',
      'SSW',
      'SW',
      'WSW',
      'W',
      'WNW',
      'NW',
      'NNW',
    ];
    final normalized = ((degrees % 360) + 360) % 360;
    final index = (normalized / 22.5).round() % 16;
    return cardinals[index];
  }

  Map<String, dynamic> _fallbackWeather() => {
    'tempC': 20.0,
    'tempF': '68.0',
    'condition': 'Fair',
    'windSpeedKmh': 10.0,
    'windSpeedMph': '6.2',
    'windDirectionDeg': 180,
    'windDirectionCardinal': 'S',
    'humidityPct': 45,
    'isLive': false,
    'source': 'Fallback',
  };
}
