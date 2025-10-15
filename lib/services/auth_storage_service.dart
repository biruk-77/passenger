// FILE: lib/services/auth_storage_service.dart

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/passenger.dart';

class AuthStorageService {
  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _accessTokenKey = 'secure_access_token_v1';
  static const _refreshTokenKey = 'secure_refresh_token_v1';
  static const _passengerIdKey = 'secure_passenger_id_v1';
  static const _cachedProfileKey = 'secure_cached_passenger_profile_v1';

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    final futures = <Future<void>>[];
    futures.add(_secureStorage.write(key: _accessTokenKey, value: accessToken));

    // Only write or delete the refresh token if it's part of the operation
    if (refreshToken != null) {
      futures.add(
        _secureStorage.write(key: _refreshTokenKey, value: refreshToken),
      );
    }

    await Future.wait(futures);
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  // ▼▼▼ THIS IS THE FIX ▼▼▼
  // This function is now empty. It will NOT delete the access token,
  // allowing it to be used for the silent login as your backend requires.
  Future<void> onlydatas() async {
   
  }
  // ▲▲▲ THIS IS THE FIX ▲▲▲

  Future<void> savePassengerId(String id) async {
    await _secureStorage.write(key: _passengerIdKey, value: id);
  }

  Future<String?> getPassengerId() async {
    return await _secureStorage.read(key: _passengerIdKey);
  }

  Future<void> saveProfileCache(Map<String, dynamic> profileData) async {
    final String profileJson = jsonEncode(profileData);
    await _secureStorage.write(key: _cachedProfileKey, value: profileJson);
  }

  Future<Passenger?> getCachedProfile() async {
    try {
      final profileJson = await _secureStorage.read(key: _cachedProfileKey);
      if (profileJson != null) {
        return Passenger.fromJson(jsonDecode(profileJson));
      }
      return null;
    } catch (e) {
      await _secureStorage.delete(key: _cachedProfileKey);
      return null;
    }
  }

  /// ✅ This method is now for a "hard logout" (e.g., forget device).
  Future<void> clearAllAuthData() async {
    await Future.wait([
      _secureStorage.delete(key: _accessTokenKey),
      _secureStorage.delete(key: _refreshTokenKey),
      _secureStorage.delete(key: _passengerIdKey),
      _secureStorage.delete(key: _cachedProfileKey),
    ]);
  }
}
