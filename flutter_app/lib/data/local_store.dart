import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'app_models.dart';

class LocalStore {
  static const _profileKey = 'bharatfit.profile.v1';
  static const _wardrobeKey = 'bharatfit.wardrobe.v1';
  static const _outfitsKey = 'bharatfit.outfits.v1';
  static const _baseUrlKey = 'bharatfit.apiBaseUrl.v1';

  Future<UserProfile?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileKey);
    if (raw == null || raw.isEmpty) return null;
    return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  Future<List<WardrobeItem>> loadWardrobe() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_wardrobeKey);
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((item) => WardrobeItem.fromJson((item as Map).cast<String, dynamic>())).toList();
  }

  Future<void> saveWardrobe(List<WardrobeItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_wardrobeKey, jsonEncode(items.map((item) => item.toJson()).toList()));
  }

  Future<List<OutfitRecommendation>> loadOutfits() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_outfitsKey);
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((item) => OutfitRecommendation.fromJson((item as Map).cast<String, dynamic>())).toList();
  }

  Future<void> saveOutfits(List<OutfitRecommendation> outfits) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_outfitsKey, jsonEncode(outfits.map((item) => item.toJson()).toList()));
  }

  Future<String?> loadBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_baseUrlKey);
  }

  Future<void> saveBaseUrl(String baseUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, baseUrl);
  }

  Future<String> exportJson({
    required UserProfile profile,
    required List<WardrobeItem> wardrobe,
    required List<OutfitRecommendation> outfits,
  }) async {
    return const JsonEncoder.withIndent('  ').convert({
      'exported_at': DateTime.now().toIso8601String(),
      'privacy_note': 'This export contains structured wardrobe/profile data and local image references only, not image bytes.',
      'profile': profile.toJson(),
      'wardrobe': wardrobe.map((item) => item.toJson()).toList(),
      'outfits': outfits.map((item) => item.toJson()).toList(),
    });
  }

  Future<void> clearOutfits() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_outfitsKey);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
    await prefs.remove(_wardrobeKey);
    await prefs.remove(_outfitsKey);
  }
}
