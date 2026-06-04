import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

// ────────────────────────────────────────────────────────────────────────────
// WeatherData — immutable result from the weather service.
// ────────────────────────────────────────────────────────────────────────────

class WeatherData {
  const WeatherData({
    required this.temperatureC,
    required this.humidity,
    required this.condition,
    required this.city,
    required this.icon,
    required this.description,
  });

  /// Current temperature in Celsius.
  final double temperatureC;

  /// Relative humidity percentage.
  final int humidity;

  /// Backend-compatible condition string: hot_humid, hot_dry, monsoon, winter, indoor_ac.
  final String condition;

  /// Reverse-geocoded city name.
  final String city;

  /// Emoji icon representing the weather.
  final String icon;

  /// Human-readable description, e.g. "Sunny & Hot".
  final String description;
}

// ────────────────────────────────────────────────────────────────────────────
// WeatherService — fetches location + weather from Open-Meteo (free, no key).
// ────────────────────────────────────────────────────────────────────────────

class WeatherService {
  const WeatherService({this.backendBaseUrl});

  /// The app's backend URL. When set, weather is fetched through the backend
  /// proxy at /weather/current — avoiding CORS on web.
  final String? backendBaseUrl;

  /// Fetch current weather for the user's location.
  /// Returns `null` if location is unavailable or the API call fails.
  Future<WeatherData?> fetchCurrentWeather() async {
    // Strategy 1: Use our backend proxy (no CORS, works everywhere).
    if (backendBaseUrl != null && backendBaseUrl!.isNotEmpty) {
      final result = await _fetchViaBackend();
      if (result != null) return result;
    }

    // Strategy 2: Direct Open-Meteo call (works on native, may CORS-fail on web).
    return _fetchDirect();
  }

  /// Fetch weather via our backend's /weather/current proxy endpoint.
  Future<WeatherData?> _fetchViaBackend() async {
    try {
      final base = backendBaseUrl!.endsWith('/') ? backendBaseUrl!.substring(0, backendBaseUrl!.length - 1) : backendBaseUrl!;
      final response = await http.get(Uri.parse('$base/weather/current'));
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      final tempC = (data['temperature_2m'] as num?)?.toDouble() ?? 0;
      final humidity = (data['relative_humidity_2m'] as num?)?.toInt() ?? 0;
      final weatherCode = (data['weather_code'] as num?)?.toInt() ?? 0;
      final isDay = (data['is_day'] as num?)?.toInt() == 1;
      final city = data['city'] as String? ?? 'Your location';
      final weatherDesc = data['weather_desc'] as String?;

      final mapped = _mapWeatherCode(weatherCode, isDay);
      final condition = _deriveBackendCondition(tempC, humidity, weatherCode);

      return WeatherData(
        temperatureC: tempC,
        humidity: humidity,
        condition: condition,
        city: city,
        icon: mapped.icon,
        description: weatherDesc?.isNotEmpty == true ? weatherDesc! : mapped.description,
      );
    } catch (e) {
      debugPrint('Backend weather proxy failed: $e');
      return null;
    }
  }

  /// Direct fetch: GPS/IP location → Open-Meteo API.
  Future<WeatherData?> _fetchDirect() async {
    try {
      final loc = await _getLocation();
      if (loc == null) return null;

      final city = loc.city ?? await _reverseGeocode(loc.lat, loc.lng);

      final uri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=${loc.lat}'
        '&longitude=${loc.lng}'
        '&current=temperature_2m,relative_humidity_2m,weather_code,is_day'
        '&timezone=auto',
      );
      final response = await http.get(uri);
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final current = data['current'] as Map<String, dynamic>?;
      if (current == null) return null;

      final tempC = (current['temperature_2m'] as num?)?.toDouble() ?? 0;
      final humidity = (current['relative_humidity_2m'] as num?)?.toInt() ?? 0;
      final weatherCode = (current['weather_code'] as num?)?.toInt() ?? 0;
      final isDay = (current['is_day'] as num?)?.toInt() == 1;

      final mapped = _mapWeatherCode(weatherCode, isDay);
      final condition = _deriveBackendCondition(tempC, humidity, weatherCode);

      return WeatherData(
        temperatureC: tempC,
        humidity: humidity,
        condition: condition,
        city: city,
        icon: mapped.icon,
        description: mapped.description,
      );
    } catch (e) {
      debugPrint('Direct weather fetch failed: $e');
      return null;
    }
  }

  // ── Location helpers ──────────────────────────────────────────────────────

  /// Simple location result with optional pre-resolved city.
  Future<({double lat, double lng, String? city})?> _getLocation() async {
    // Try GPS first (works on native and HTTPS web).
    final gpsPosition = await _tryGps();
    if (gpsPosition != null) {
      return (lat: gpsPosition.latitude, lng: gpsPosition.longitude, city: null);
    }

    // Fallback: IP-based geolocation (works on HTTP localhost for web dev).
    return _ipGeolocate();
  }

  Future<Position?> _tryGps() async {
    try {
      if (kIsWeb) {
        final permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          final requested = await Geolocator.requestPermission();
          if (requested == LocationPermission.denied || requested == LocationPermission.deniedForever) {
            return null;
          }
        }
        if (permission == LocationPermission.deniedForever) return null;
        return await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.low, timeLimit: Duration(seconds: 10)),
        );
      }

      // Native platforms
      if (!await Geolocator.isLocationServiceEnabled()) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low, timeLimit: Duration(seconds: 10)),
      );
    } catch (e) {
      debugPrint('GPS failed: $e');
      return null;
    }
  }

  /// Free IP-based geolocation via ip-api.com (no key, no permissions needed).
  Future<({double lat, double lng, String? city})?> _ipGeolocate() async {
    try {
      final response = await http.get(
        Uri.parse('http://ip-api.com/json/?fields=status,city,lat,lon'),
      );
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['status'] != 'success') return null;
      final lat = (data['lat'] as num?)?.toDouble();
      final lng = (data['lon'] as num?)?.toDouble();
      final city = data['city'] as String?;
      if (lat == null || lng == null) return null;
      return (lat: lat, lng: lng, city: city);
    } catch (e) {
      debugPrint('IP geolocation failed: $e');
      return null;
    }
  }

  Future<String> _reverseGeocode(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        return p.locality?.isNotEmpty == true
            ? p.locality!
            : p.subAdministrativeArea ?? p.administrativeArea ?? 'Unknown';
      }
    } catch (_) {
      // Geocoding can fail silently — return fallback.
    }
    return 'Your location';
  }

  // ── Weather code → emoji + description ────────────────────────────────
  // Handles both WMO codes (Open-Meteo) and wttr.in codes.

  static ({String icon, String description}) _mapWeatherCode(int code, bool isDay) {
    return switch (code) {
      // wttr.in codes
      113 => (icon: isDay ? '☀️' : '🌙', description: 'Sunny'),
      116 => (icon: '⛅', description: 'Partly cloudy'),
      119 => (icon: '☁️', description: 'Cloudy'),
      122 => (icon: '☁️', description: 'Overcast'),
      143 || 248 || 260 => (icon: '🌫️', description: 'Foggy'),
      176 || 263 || 266 => (icon: '🌦️', description: 'Light drizzle'),
      293 || 296 => (icon: '🌧️', description: 'Light rain'),
      299 || 302 => (icon: '🌧️', description: 'Moderate rain'),
      305 || 308 || 311 || 314 || 356 || 359 => (icon: '🌧️', description: 'Heavy rain'),
      179 || 227 || 230 => (icon: '❄️', description: 'Snowy'),
      200 || 386 || 389 || 392 || 395 => (icon: '⛈️', description: 'Thunderstorm'),
      // WMO codes (fallback for Open-Meteo direct calls)
      0 => (icon: isDay ? '☀️' : '🌙', description: 'Clear sky'),
      1 => (icon: isDay ? '🌤️' : '🌙', description: 'Mostly clear'),
      2 => (icon: '⛅', description: 'Partly cloudy'),
      3 => (icon: '☁️', description: 'Overcast'),
      45 || 48 => (icon: '🌫️', description: 'Foggy'),
      51 || 53 || 55 => (icon: '🌦️', description: 'Drizzle'),
      61 || 63 || 65 => (icon: '🌧️', description: 'Rainy'),
      71 || 73 || 75 || 77 => (icon: '❄️', description: 'Snowy'),
      80 || 81 || 82 => (icon: '🌧️', description: 'Rain showers'),
      95 || 96 || 99 => (icon: '⛈️', description: 'Thunderstorm'),
      _ => (icon: '🌡️', description: ''),
    };
  }

  // ── Derive backend-compatible condition string ────────────────────────────

  static String _deriveBackendCondition(double tempC, int humidity, int weatherCode) {
    // Rain / thunderstorm codes (WMO + wttr.in)
    const rainCodes = [51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82, 95, 96, 99,
      176, 263, 266, 293, 296, 299, 302, 305, 308, 311, 314, 356, 359, 200, 386, 389];
    if (rainCodes.contains(weatherCode)) return 'monsoon';

    // Snow codes (WMO + wttr.in)
    const snowCodes = [71, 73, 75, 77, 85, 86, 179, 227, 230, 392, 395];
    if (snowCodes.contains(weatherCode)) return 'winter';

    // Temperature-based
    if (tempC < 15) return 'winter';
    if (tempC >= 30 && humidity >= 60) return 'hot_humid';
    if (tempC >= 30) return 'hot_dry';
    return 'hot_humid'; // Safe Indian default
  }
}
