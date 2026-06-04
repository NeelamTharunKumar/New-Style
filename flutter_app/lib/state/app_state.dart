import 'package:flutter/material.dart';

import '../data/app_models.dart';
import '../data/drape_api_client.dart';
import '../data/firebase_login_service.dart';
import '../data/local_image_service.dart';
import '../data/local_store.dart';
import '../data/secure_auth_store.dart';
import '../data/weather_service.dart';

class AppState extends ChangeNotifier {
  AppState(this.apiClient, this.localStore, this.secureAuthStore, this.firebaseLoginService);

  final DrapeApiClient apiClient;
  final LocalStore localStore;
  final SecureAuthStore secureAuthStore;
  final FirebaseLoginService firebaseLoginService;
  final LocalImageService _localImageService = const LocalImageService();

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
  bool isHydrated = false;
  bool hasCompletedOnboarding = false;
  String? error;
  String? statusMessage;
  String? backendHealth;
  AuthCredentials authCredentials = const AuthCredentials();
  ThemeMode themeMode = ThemeMode.system;
  WeatherData? currentWeather;
  bool isWeatherLoading = false;

  bool get isLoggedIn => authCredentials.hasBearerToken || authCredentials.authMode == 'open_dev';
  String get userId => profile.userId;

  Future<void> hydrate() async {
    if (isHydrated) return;
    isBusy = true;
    notifyListeners();
    try {
      final savedBaseUrl = await localStore.loadBaseUrl();
      if (savedBaseUrl != null && savedBaseUrl.isNotEmpty) {
        apiClient.baseUrl = savedBaseUrl;
      }
      authCredentials = await secureAuthStore.load();
      apiClient.apiKey = authCredentials.apiKey;
      apiClient.authToken = authCredentials.authToken;
      hasCompletedOnboarding = await localStore.loadOnboardingCompleted();
      final savedTheme = await localStore.loadThemeMode();
      if (savedTheme == 'light') themeMode = ThemeMode.light;
      if (savedTheme == 'dark') themeMode = ThemeMode.dark;
      if (savedTheme == 'system') themeMode = ThemeMode.system;
      profile = await localStore.loadProfile() ?? profile;
      if (authCredentials.userId.isNotEmpty && profile.userId != authCredentials.userId) {
        profile = profile.copyWith(userId: authCredentials.userId);
      }
      wardrobeItems = await localStore.loadWardrobe();
      outfits = await localStore.loadOutfits();
      statusMessage = 'Loaded secure auth, local profile, ${wardrobeItems.length} wardrobe items and ${outfits.length} saved outfits';
    } catch (err) {
      error = 'Local load failed: $err';
    } finally {
      isHydrated = true;
      isBusy = false;
      notifyListeners();
    }
    // Non-blocking: fetch weather in background after hydration.
    fetchWeather();
  }


  Future<void> loginWithFirebaseAnonymously({String apiKey = ''}) async {
    await _run(() async {
      final result = await firebaseLoginService.signInAnonymously();
      authCredentials = AuthCredentials(
        userId: result.userId,
        authMode: 'firebase',
        authToken: result.idToken,
        apiKey: apiKey.trim(),
      );
      apiClient.apiKey = authCredentials.apiKey;
      apiClient.authToken = authCredentials.authToken;
      await secureAuthStore.save(authCredentials);

      final previousUserId = profile.userId;
      profile = profile.copyWith(userId: result.userId);
      if (previousUserId != profile.userId && wardrobeItems.isNotEmpty) {
        wardrobeItems = wardrobeItems.map((item) => item.copyWith(userId: profile.userId)).toList();
        await localStore.saveWardrobe(wardrobeItems);
      }
      await localStore.saveProfile(profile);

      final session = await apiClient.session();
      statusMessage = 'Firebase login saved securely. Session: ${session['user_id'] ?? result.userId}';
    });
  }

  Future<void> loginWithDevUser({
    required String userId,
    String apiKey = '',
  }) async {
    final trimmedUserId = userId.trim();
    if (trimmedUserId.isEmpty) {
      error = 'User ID is required';
      notifyListeners();
      return;
    }
    await saveAuthCredentials(
      AuthCredentials(
        userId: trimmedUserId,
        authMode: 'dev_bearer',
        authToken: 'dev:$trimmedUserId',
        apiKey: apiKey.trim(),
      ),
      updateProfileUserId: true,
    );
  }

  Future<void> saveAuthCredentials(
    AuthCredentials credentials, {
    bool updateProfileUserId = false,
  }) async {
    await _run(() async {
      authCredentials = credentials;
      apiClient.apiKey = credentials.apiKey;
      apiClient.authToken = credentials.authToken;
      await secureAuthStore.save(credentials);
      if (updateProfileUserId && credentials.userId.isNotEmpty) {
        final previousUserId = profile.userId;
        profile = profile.copyWith(userId: credentials.userId);
        if (previousUserId != profile.userId && wardrobeItems.isNotEmpty) {
          wardrobeItems = wardrobeItems.map((item) => item.copyWith(userId: profile.userId)).toList();
          await localStore.saveWardrobe(wardrobeItems);
        }
        await localStore.saveProfile(profile);
      }
      final session = await apiClient.session();
      statusMessage = 'Login saved securely. Session: ${session['auth_mode']} ${session['user_id'] ?? ''}'.trim();
    });
  }

  Future<void> logout() async {
    await _run(() async {
      authCredentials = const AuthCredentials();
      apiClient.apiKey = '';
      apiClient.authToken = '';
      await secureAuthStore.clear();
      try {
        await firebaseLoginService.signOut();
      } catch (_) {
        // Firebase may be unconfigured in dev/static modes. Secure token cleanup is enough.
      }
      statusMessage = 'Logged out and cleared secure tokens';
    });
  }

  Future<void> completeOnboarding() async {
    hasCompletedOnboarding = true;
    await localStore.saveOnboardingCompleted(true);
    statusMessage = 'Welcome to Drape AI';
    notifyListeners();
  }

  Future<void> resetOnboarding() async {
    hasCompletedOnboarding = false;
    await localStore.saveOnboardingCompleted(false);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    await localStore.saveThemeMode(mode.name);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final next = switch (themeMode) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    await setThemeMode(next);
  }

  Future<void> updateBaseUrl(String value) async {
    final next = value.trim();
    if (next.isEmpty) return;
    apiClient.baseUrl = next;
    await localStore.saveBaseUrl(next);
    statusMessage = 'Backend URL saved locally';
    notifyListeners();
  }

  WardrobeItem? itemById(String itemId) {
    for (final item in wardrobeItems) {
      if (item.itemId == itemId) return item;
    }
    return null;
  }

  Future<void> fetchWeather() async {
    isWeatherLoading = true;
    notifyListeners();
    try {
      final weatherService = WeatherService(backendBaseUrl: apiClient.baseUrl);
      currentWeather = await weatherService.fetchCurrentWeather();
    } catch (_) {
      // Weather is optional — never block the app.
    } finally {
      isWeatherLoading = false;
      notifyListeners();
    }
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
      final previousUserId = profile.userId;
      profile = nextProfile;
      if (previousUserId != profile.userId && wardrobeItems.isNotEmpty) {
        wardrobeItems = wardrobeItems.map((item) => item.copyWith(userId: profile.userId)).toList();
        await localStore.saveWardrobe(wardrobeItems);
      }
      await localStore.saveProfile(profile);
      final synced = await _trySyncProfile();
      statusMessage = synced ? 'Profile saved locally and synced to backend' : 'Profile saved locally. Backend sync can be retried later.';
    });
  }

  Future<void> loadWardrobe({bool notify = true}) async {
    if (notify) {
      isBusy = true;
      error = null;
      notifyListeners();
    }
    try {
      wardrobeItems = await localStore.loadWardrobe();
      statusMessage = 'Loaded ${wardrobeItems.length} local wardrobe items';
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
      final localItem = _ensureLocalItemId(item);
      wardrobeItems = [
        ...wardrobeItems.where((existing) => existing.itemId != localItem.itemId),
        localItem,
      ];
      await localStore.saveWardrobe(wardrobeItems);

      final synced = await _trySyncItem(localItem);
      statusMessage = synced
          ? 'Added ${localItem.displayName} locally and synced structured data'
          : 'Added ${localItem.displayName} locally. Backend sync can be retried later.';
    });
  }

  Future<void> deleteWardrobeItem(WardrobeItem item) async {
    final itemId = item.itemId;
    if (itemId == null || itemId.isEmpty) return;
    await _run(() async {
      await _localImageService.deleteLocalImage(item.localImageRef);
      wardrobeItems = wardrobeItems.where((existing) => existing.itemId != itemId).toList();
      await localStore.saveWardrobe(wardrobeItems);
      try {
        await apiClient.deleteWardrobeItem(userId, itemId);
      } catch (_) {
        // Local delete remains authoritative in Phase 3.
      }
      statusMessage = 'Deleted ${item.displayName} from local wardrobe';
    });
  }

  Future<void> addDemoWardrobe() async {
    final mode = profile.styleMode == 'womenswear' ? 'womenswear' : 'menswear';
    final items = mode == 'womenswear' ? _demoWomenswear(userId) : _demoMenswear(userId);
    for (final item in items) {
      if (wardrobeItems.any((existing) => existing.itemId == item.itemId)) continue;
      await addWardrobeItem(item);
    }
  }

  Future<void> generateOutfits({
    required String occasion,
    double? temperatureC,
    String? weatherCondition,
  }) async {
    await _run(() async {
      // Auto-fill from live weather if not manually provided.
      final effectiveTemp = temperatureC ?? currentWeather?.temperatureC;
      final effectiveCondition = weatherCondition ?? currentWeather?.condition;

      outfits = await apiClient.generateOutfits(
        userId: userId,
        occasion: occasion,
        styleMode: profile.styleMode,
        profile: profile,
        wardrobeItems: wardrobeItems,
        temperatureC: effectiveTemp,
        weatherCondition: effectiveCondition,
      );
      await localStore.saveOutfits(outfits);
      statusMessage = outfits.isEmpty ? 'No outfit combinations found yet' : 'Generated and saved ${outfits.length} outfits locally';
    });
  }

  Future<void> recordOutfitFeedback({
    required OutfitRecommendation outfit,
    int? rating,
    bool worn = false,
    bool favorite = false,
    bool rejected = false,
    String? occasion,
    String? notes,
  }) async {
    await _run(() async {
      await apiClient.recordOutfitFeedback(
        userId: userId,
        outfitId: outfit.outfitId,
        itemIds: outfit.itemIds,
        occasion: occasion,
        rating: rating,
        worn: worn,
        favorite: favorite,
        rejected: rejected,
        notes: notes,
      );
      statusMessage = favorite
          ? 'Saved outfit as favorite'
          : rejected
              ? 'Feedback saved. Similar looks will be ranked lower.'
              : worn
                  ? 'Marked outfit as worn'
                  : 'Outfit feedback saved';
    });
  }

  Future<String> askStylist(String message) async {
    var reply = '';
    await _run(() async {
      reply = await apiClient.chat(userId: userId, message: message);
    });
    return reply;
  }

  Future<String> exportLocalData() {
    return localStore.exportJson(profile: profile, wardrobe: wardrobeItems, outfits: outfits);
  }

  Future<void> clearSavedOutfits() async {
    await _run(() async {
      outfits = [];
      await localStore.clearOutfits();
      statusMessage = 'Cleared saved local outfit results';
    });
  }

  Future<void> clearLocalData() async {
    await _run(() async {
      await localStore.clearAll();
      profile = const UserProfile(
        userId: 'demo_user',
        styleMode: 'mixed',
        skinTone: 'medium warm',
        climatePreference: 'hot_humid',
        preferences: ['smart casual', 'budget-conscious'],
      );
      wardrobeItems = [];
      outfits = [];
      statusMessage = 'Cleared local profile, wardrobe and outfits';
    });
  }

  Future<void> syncStructuredDataToBackend() async {
    await _run(() async {
      var syncedItems = 0;
      final profileSynced = await _trySyncProfile();
      for (final item in wardrobeItems) {
        if (await _trySyncItem(item)) syncedItems++;
      }
      statusMessage = profileSynced
          ? 'Synced profile and $syncedItems/${wardrobeItems.length} structured wardrobe items'
          : 'Synced $syncedItems/${wardrobeItems.length} items. Profile sync failed.';
    });
  }

  Future<bool> _trySyncProfile() async {
    try {
      await apiClient.upsertProfile(profile);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _trySyncItem(WardrobeItem item) async {
    try {
      await apiClient.addWardrobeItem(item);
      return true;
    } catch (_) {
      return false;
    }
  }

  WardrobeItem _ensureLocalItemId(WardrobeItem item) {
    final slug = item.category.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    final id = item.itemId != null && item.itemId!.trim().isNotEmpty
        ? item.itemId!.trim()
        : 'local_${slug}_${DateTime.now().millisecondsSinceEpoch}';
    final needsLocalRef = item.localImageRef == null || item.localImageRef!.isEmpty || item.localImageRef!.contains('new_item');
    return item.copyWith(
      itemId: id,
      localImageRef: needsLocalRef ? 'local://wardrobe/$id.jpg' : item.localImageRef,
    );
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
