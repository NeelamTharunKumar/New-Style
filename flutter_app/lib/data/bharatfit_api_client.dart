import 'dart:convert';

import 'package:http/http.dart' as http;

import 'app_models.dart';

class BharatFitApiClient {
  BharatFitApiClient({String? baseUrl}) : baseUrl = baseUrl ?? defaultBaseUrl;

  static const String defaultBaseUrl = String.fromEnvironment(
    'BHARATFIT_API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  String baseUrl;

  Uri _uri(String path) {
    final normalizedBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    return Uri.parse('$normalizedBase$path');
  }

  Map<String, String> get _headers => const {'Content-Type': 'application/json'};

  Future<Map<String, dynamic>> health() async {
    final response = await http.get(_uri('/health'));
    return _decodeObject(response);
  }

  Future<UserProfile> upsertProfile(UserProfile profile) async {
    final response = await http.post(
      _uri('/users/profile'),
      headers: _headers,
      body: jsonEncode(profile.toJson()),
    );
    return UserProfile.fromJson(_decodeObject(response));
  }

  Future<List<WardrobeItem>> listWardrobeItems(String userId) async {
    final response = await http.get(_uri('/wardrobe/items/$userId'));
    final decoded = _decode(response);
    if (decoded is! List) {
      throw ApiException('Expected wardrobe list but received ${decoded.runtimeType}');
    }
    return decoded
        .map((item) => WardrobeItem.fromJson((item as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<WardrobeItem> addWardrobeItem(WardrobeItem item) async {
    final response = await http.post(
      _uri('/wardrobe/items'),
      headers: _headers,
      body: jsonEncode(item.toJson()),
    );
    return WardrobeItem.fromJson(_decodeObject(response));
  }

  Future<void> deleteWardrobeItem(String userId, String itemId) async {
    final response = await http.delete(_uri('/wardrobe/items/$userId/$itemId'));
    _decode(response);
  }

  Future<List<OutfitRecommendation>> generateOutfits({
    required String userId,
    required String occasion,
    required String styleMode,
    required UserProfile profile,
    List<WardrobeItem> wardrobeItems = const [],
    double? temperatureC,
    String? weatherCondition,
    int maxResults = 5,
  }) async {
    final weather = <String, dynamic>{};
    if (temperatureC != null) weather['temperature_c'] = temperatureC;
    if (weatherCondition != null && weatherCondition.isNotEmpty) weather['condition'] = weatherCondition;

    final response = await http.post(
      _uri('/outfits/generate'),
      headers: _headers,
      body: jsonEncode({
        'user_id': userId,
        'occasion': occasion,
        'style_mode': styleMode,
        'user_profile': profile.toJson(),
        'max_results': maxResults,
        if (weather.isNotEmpty) 'weather': weather,
        if (wardrobeItems.isNotEmpty) 'wardrobe_items': wardrobeItems.map((item) => item.toJson()).toList(),
      }),
    );
    final decoded = _decodeObject(response);
    final outfits = decoded['outfits'];
    if (outfits is! List) return const [];
    return outfits
        .map((item) => OutfitRecommendation.fromJson((item as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<String> chat({required String userId, required String message}) async {
    final response = await http.post(
      _uri('/chat/stylist'),
      headers: _headers,
      body: jsonEncode({'user_id': userId, 'message': message}),
    );
    return _decodeObject(response)['reply']?.toString() ?? '';
  }

  dynamic _decode(http.Response response) {
    dynamic decoded;
    try {
      decoded = response.body.isEmpty ? null : jsonDecode(response.body);
    } catch (_) {
      decoded = response.body;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final detail = decoded is Map ? decoded['detail'] : decoded;
      throw ApiException('API ${response.statusCode}: $detail');
    }
    return decoded;
  }

  Map<String, dynamic> _decodeObject(http.Response response) {
    final decoded = _decode(response);
    if (decoded is Map) return decoded.cast<String, dynamic>();
    throw ApiException('Expected JSON object but received ${decoded.runtimeType}');
  }
}

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}
