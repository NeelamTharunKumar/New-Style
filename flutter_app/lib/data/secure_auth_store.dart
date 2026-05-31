import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthCredentials {
  const AuthCredentials({
    this.apiKey = '',
    this.authToken = '',
    this.authMode = 'open_dev',
    this.userId = '',
  });

  final String apiKey;
  final String authToken;
  final String authMode;
  final String userId;

  bool get hasBearerToken => authToken.trim().isNotEmpty;
  bool get hasApiKey => apiKey.trim().isNotEmpty;

  AuthCredentials copyWith({String? apiKey, String? authToken, String? authMode, String? userId}) {
    return AuthCredentials(
      apiKey: apiKey ?? this.apiKey,
      authToken: authToken ?? this.authToken,
      authMode: authMode ?? this.authMode,
      userId: userId ?? this.userId,
    );
  }
}

class SecureAuthStore {
  SecureAuthStore({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  static const _apiKeyKey = 'bharatfit.secure.apiKey.v1';
  static const _authTokenKey = 'bharatfit.secure.authToken.v1';
  static const _authModeKey = 'bharatfit.secure.authMode.v1';
  static const _userIdKey = 'bharatfit.secure.userId.v1';

  final FlutterSecureStorage _storage;

  Future<AuthCredentials> load() async {
    return AuthCredentials(
      apiKey: await _storage.read(key: _apiKeyKey) ?? '',
      authToken: await _storage.read(key: _authTokenKey) ?? '',
      authMode: await _storage.read(key: _authModeKey) ?? 'open_dev',
      userId: await _storage.read(key: _userIdKey) ?? '',
    );
  }

  Future<void> save(AuthCredentials credentials) async {
    await _storage.write(key: _apiKeyKey, value: credentials.apiKey);
    await _storage.write(key: _authTokenKey, value: credentials.authToken);
    await _storage.write(key: _authModeKey, value: credentials.authMode);
    await _storage.write(key: _userIdKey, value: credentials.userId);
  }

  Future<void> clear() async {
    await _storage.delete(key: _apiKeyKey);
    await _storage.delete(key: _authTokenKey);
    await _storage.delete(key: _authModeKey);
    await _storage.delete(key: _userIdKey);
  }
}
