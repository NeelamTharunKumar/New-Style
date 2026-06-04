import 'dart:convert';

import 'package:http/http.dart' as http;

import 'app_models.dart';

class DrapeApiClient {
  DrapeApiClient({String? baseUrl, String? apiKey, String? authToken})
      : baseUrl = baseUrl ?? defaultBaseUrl,
        apiKey = apiKey ?? defaultApiKey,
        authToken = authToken ?? defaultAuthToken;

  static const String defaultBaseUrl = String.fromEnvironment(
    'DRAPE_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );
  static const String defaultApiKey = String.fromEnvironment('DRAPE_API_KEY', defaultValue: '');
  static const String defaultAuthToken = String.fromEnvironment('DRAPE_AUTH_TOKEN', defaultValue: '');

  String baseUrl;
  String apiKey;
  String authToken;

  Uri _uri(String path) {
    final normalizedBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    return Uri.parse('$normalizedBase$path');
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (apiKey.trim().isNotEmpty) 'X-API-Key': apiKey.trim(),
        if (authToken.trim().isNotEmpty) 'Authorization': 'Bearer ${authToken.trim()}',
      };

  Future<Map<String, dynamic>> health() async {
    final response = await http.get(_uri('/health'));
    return _decodeObject(response);
  }

  Future<Map<String, dynamic>> session() async {
    final response = await http.get(_uri('/auth/session'), headers: _headers);
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
    final response = await http.get(_uri('/wardrobe/items/$userId'), headers: _headers);
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
    final response = await http.delete(_uri('/wardrobe/items/$userId/$itemId'), headers: _headers);
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

  Future<void> recordOutfitFeedback({
    required String userId,
    required String outfitId,
    required List<String> itemIds,
    String? occasion,
    int? rating,
    bool worn = false,
    bool favorite = false,
    bool rejected = false,
    String? notes,
  }) async {
    final response = await http.post(
      _uri('/outfits/feedback'),
      headers: _headers,
      body: jsonEncode({
        'user_id': userId,
        'outfit_id': outfitId,
        'item_ids': itemIds,
        if (occasion != null) 'occasion': occasion,
        if (rating != null) 'rating': rating,
        'worn': worn,
        'favorite': favorite,
        'rejected': rejected,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      }),
    );
    _decode(response);
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
