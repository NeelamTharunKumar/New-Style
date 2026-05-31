import 'package:flutter/foundation.dart';

import '../data/app_models.dart';
import '../data/bharatfit_api_client.dart';

class AppState extends ChangeNotifier {
  AppState(this.apiClient);

  final BharatFitApiClient apiClient;

  UserProfile profile = const UserProfile(
    userId: 'demo_user',
    styleMode: 'mixed',
    skinTone: 'medium warm',
    climatePreference: 'hot_humid',
    preferences: ['smart casual', 'budget-conscious'],
  );

  List<WardrobeItem> wardrobeItems = [];
  List<OutfitRecommendation> outfits = [];
  bool isBusy = false;
  String? error;
  String? statusMessage;
  String? backendHealth;

  String get userId => profile.userId;

  void updateBaseUrl(String value) {
    apiClient.baseUrl = value.trim();
    statusMessage = 'Backend URL updated';
    notifyListeners();
  }

  WardrobeItem? itemById(String itemId) {
    for (final item in wardrobeItems) {
      if (item.itemId == itemId) return item;
    }
    return null;
  }

  Future<void> checkHealth() async {
    await _run(() async {
      final response = await apiClient.health();
      backendHealth = '${response['status']} · ${response['product']}';
      statusMessage = response['privacy']?.toString();
    });
  }

  Future<void> saveProfile(UserProfile nextProfile) async {
    await _run(() async {
      profile = await apiClient.upsertProfile(nextProfile);
      statusMessage = 'Profile saved for ${profile.userId}';
      await loadWardrobe(notify: false);
    });
  }

  Future<void> loadWardrobe({bool notify = true}) async {
    if (notify) {
      isBusy = true;
      error = null;
      notifyListeners();
    }
    try {
      wardrobeItems = await apiClient.listWardrobeItems(userId);
      statusMessage = 'Loaded ${wardrobeItems.length} wardrobe items';
    } catch (err) {
      error = err.toString();
    } finally {
      if (notify) {
        isBusy = false;
        notifyListeners();
      }
    }
  }

  Future<void> addWardrobeItem(WardrobeItem item) async {
    await _run(() async {
      final saved = await apiClient.addWardrobeItem(item);
      wardrobeItems = [...wardrobeItems, saved];
      statusMessage = 'Added ${saved.displayName}';
    });
  }

  Future<void> deleteWardrobeItem(WardrobeItem item) async {
    final itemId = item.itemId;
    if (itemId == null || itemId.isEmpty) return;
    await _run(() async {
      await apiClient.deleteWardrobeItem(userId, itemId);
      wardrobeItems = wardrobeItems.where((existing) => existing.itemId != itemId).toList();
      statusMessage = 'Deleted ${item.displayName}';
    });
  }

  Future<void> addDemoWardrobe() async {
    final mode = profile.styleMode == 'womenswear' ? 'womenswear' : 'menswear';
    final items = mode == 'womenswear' ? _demoWomenswear(userId) : _demoMenswear(userId);
    for (final item in items) {
      await addWardrobeItem(item);
    }
  }

  Future<void> generateOutfits({
    required String occasion,
    double? temperatureC,
    String? weatherCondition,
  }) async {
    await _run(() async {
      outfits = await apiClient.generateOutfits(
        userId: userId,
        occasion: occasion,
        styleMode: profile.styleMode,
        temperatureC: temperatureC,
        weatherCondition: weatherCondition,
      );
      statusMessage = outfits.isEmpty ? 'No outfit combinations found yet' : 'Generated ${outfits.length} outfits';
    });
  }

  Future<String> askStylist(String message) async {
    var reply = '';
    await _run(() async {
      reply = await apiClient.chat(userId: userId, message: message);
    });
    return reply;
  }

  Future<void> _run(Future<void> Function() task) async {
    isBusy = true;
    error = null;
    notifyListeners();
    try {
      await task();
    } catch (err) {
      error = err.toString();
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }
}

List<WardrobeItem> _demoMenswear(String userId) {
  return [
    WardrobeItem(
      userId: userId,
      itemId: 'shirt_office_blue',
      styleMode: 'menswear',
      name: 'Light blue office shirt',
      category: 'shirt',
      color: 'light blue',
      hexColor: '#A8C7E8',
      fabric: 'cotton',
      fit: 'regular',
      formality: 8,
      styleTags: const ['formal', 'minimal'],
      occasionTags: const ['office', 'interview'],
      climateTags: const ['hot_humid'],
      localImageRef: 'local://wardrobe/shirt_office_blue.jpg',
    ),
    WardrobeItem(
      userId: userId,
      itemId: 'trouser_charcoal',
      styleMode: 'menswear',
      name: 'Charcoal formal trousers',
      category: 'trousers',
      color: 'charcoal',
      fabric: 'cotton blend',
      fit: 'regular',
      formality: 8,
      styleTags: const ['formal', 'minimal'],
      occasionTags: const ['office', 'interview'],
      localImageRef: 'local://wardrobe/trouser_charcoal.jpg',
    ),
    WardrobeItem(
      userId: userId,
      itemId: 'loafers_brown',
      styleMode: 'menswear',
      name: 'Brown loafers',
      category: 'loafers',
      color: 'brown',
      formality: 7,
      styleTags: const ['smart casual', 'minimal'],
      occasionTags: const ['office', 'date'],
      localImageRef: 'local://wardrobe/loafers_brown.jpg',
    ),
  ];
}

List<WardrobeItem> _demoWomenswear(String userId) {
  return [
    WardrobeItem(
      userId: userId,
      itemId: 'kurti_mustard',
      styleMode: 'womenswear',
      name: 'Mustard cotton kurti',
      category: 'kurti',
      color: 'mustard yellow',
      hexColor: '#D9A21B',
      fabric: 'cotton',
      fit: 'straight',
      sleeve: 'three-quarter',
      formality: 7,
      styleTags: const ['ethnic', 'festive'],
      occasionTags: const ['haldi', 'festival', 'college'],
      climateTags: const ['hot_humid'],
      localImageRef: 'local://wardrobe/kurti_mustard.jpg',
    ),
    WardrobeItem(
      userId: userId,
      itemId: 'palazzo_white',
      styleMode: 'womenswear',
      name: 'White palazzo',
      category: 'palazzo',
      color: 'white',
      fabric: 'cotton',
      fit: 'relaxed',
      formality: 5,
      styleTags: const ['ethnic', 'comfortable'],
      occasionTags: const ['haldi', 'college', 'festival'],
      climateTags: const ['hot_humid'],
      localImageRef: 'local://wardrobe/palazzo_white.jpg',
    ),
    WardrobeItem(
      userId: userId,
      itemId: 'juttis_gold',
      styleMode: 'womenswear',
      name: 'Gold juttis',
      category: 'juttis',
      color: 'gold',
      formality: 7,
      styleTags: const ['ethnic', 'festive'],
      occasionTags: const ['haldi', 'wedding guest', 'festival'],
      localImageRef: 'local://wardrobe/juttis_gold.jpg',
    ),
  ];
}
