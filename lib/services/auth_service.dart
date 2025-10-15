// lib/services/auth_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'socket_service.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';
import 'auth_storage_service.dart';
import '../models/passenger.dart';
import 'package:flutter/foundation.dart';
import 'package:jwt_decode/jwt_decode.dart';

enum AuthStatus {
  unknown,
  unauthenticated,
  authenticated,
  needsProfileCompletion,
}

class AuthService with ChangeNotifier {
  static const String _source = "AuthService";
  final AuthStorageService _storageService = AuthStorageService();
  final SocketService _socketService;

  final StreamController<AuthStatus> _authStatusController =
      StreamController<AuthStatus>.broadcast();

  Passenger? _currentPassenger;
  Passenger? get currentPassenger => _currentPassenger;
  Stream<AuthStatus> get authStatusStream => _authStatusController.stream;
  AuthStorageService get storage => _storageService;

  AuthService(this._socketService) {
    _checkInitialAuthStatus();
  }
  Future<void> _processSuccessfulAuthentication({
    required String accessToken,
    String? refreshToken,
    Map<String, dynamic>? passengerJson,
  }) async {
    await _storageService.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    _socketService.connect(accessToken);

    if (passengerJson != null) {
      final passenger = Passenger.fromJson(passengerJson);
      _currentPassenger = passenger;
      await _storageService.savePassengerId(passenger.id);
      await _storageService.saveProfileCache(passengerJson);

      // ✅ --- DEBUG LOGGING ---
      Logger.success(
        _source,
        "Email login successful for ${passenger.name}. Auth status will be updated.",
      );

      // ✅ --- FIX: Added safety check ---
      if (!_authStatusController.isClosed) {
        if (passenger.name.isEmpty ||
            passenger.name.toLowerCase().contains('passenger') ||
            passenger.email.isEmpty) {
          Logger.info(_source, "🔵 Navigating to profile completion screen");
          _authStatusController.add(AuthStatus.needsProfileCompletion);
        } else {
          Logger.info(_source, "🟢 Navigating to home screen");
          _authStatusController.add(AuthStatus.authenticated);
          // After successful authentication, check the passenger data
          Logger.info(
            _source,
            "Passenger data: ${_currentPassenger?.toJson()}",
          );
        }
      }
    } else {
      await getPassengerProfile();
    }
  }

  Future<Map<String, dynamic>> loginWithRefreshToken() async {
    Logger.info(_source, "🔁 Orchestrating silent login with refresh token...");

    final success = await refreshToken(); // Call our new robust function

    if (success) {
      // We don't need to do anything else. `refreshToken` already called
      // `_processSuccessfulAuthentication`, which sets the correct auth status
      // and will navigate the user to the HomeScreen or CompleteProfileScreen.
      Logger.success(_source, "Silent login successful.");
      return {'success': true};
    } else {
      // THIS IS THE CRITICAL FIX FOR THE FAILURE CASE
      Logger.warning(
        _source,
        "Silent login failed. Forcing hard logout and showing login screen.",
      );
      await logout(
        hard: true,
      ); // Clears bad tokens and sets status to unauthenticated
      return {
        'success': false,
        'message': 'Session expired. Please log in again.',
      };
    }
  }

  Future<bool> refreshToken() async {
    Logger.info(
      _source,
      "🔄 Attempting to refresh session with stored tokens...",
    );

    // 1. Get ALL required data from storage. Your API needs all three.
    final storedAccessToken = await _storageService.getAccessToken();
    final storedRefreshToken = await _storageService.getRefreshToken();
    final cachedProfile = await _storageService.getCachedProfile();

    // 2. CRITICAL CHECK: If any piece is missing, we cannot proceed.
    if (storedAccessToken == null) {
      Logger.error(
        _source,
        "🚨 Refresh failed: No (expired) access token found to authorize the refresh request.",
      );
      return false;
    }
    if (storedRefreshToken == null) {
      Logger.error(_source, "🚨 Refresh failed: No refresh token found.");
      return false;
    }
    if (cachedProfile == null) {
      Logger.error(
        _source,
        "🚨 Refresh failed: No cached profile found to get phone number.",
      );
      return false;
    }

    final String phoneNumber = cachedProfile.phone;
    final refreshUrl = Uri.parse('${ApiConstants.authBaseUrl}/auth/login');

    try {
      Logger.info(
        _source,
        "🚀 Sending refresh request for phone: $phoneNumber",
      );

      // 3. Send the request with BOTH the expired Access Token and the Refresh Token.
      // This is a common security pattern.
      final response = await http.post(
        refreshUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer $storedAccessToken', // <-- THIS WAS THE MISSING PIECE
          'X-Refresh-Token': storedRefreshToken,
        },
        body: jsonEncode({'phone': phoneNumber}),
      );

      // 4. Process the response
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final newAccessToken = body['token'];
        final newRefreshToken = body['refreshToken'];

        if (newAccessToken != null && newRefreshToken != null) {
          await _processSuccessfulAuthentication(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
            passengerJson: body['passenger'],
          );
          Logger.success(
            _source,
            "✅ Session refresh successful. New tokens stored.",
          );
          return true;
        }
      }

      // 5. If it fails, the tokens are invalid.
      Logger.error(
        _source,
        "🚨 Session refresh failed (status ${response.statusCode}). The tokens are likely invalid.",
      );
      return false;
    } catch (e) {
      Logger.error(_source, "🚨 Network error during session refresh.", e);
      return false;
    }
  }

  /// ✅ --- MODIFIED: Implements soft and hard logout with a crash fix ---
  Future<void> logout({bool hard = false}) async {
    if (hard) {
      await _storageService.clearAllAuthData();
      Logger.info(
        _source,
        "👋 User HARD logged out. All session data cleared.",
      );
    } else {
      await _storageService.onlydatas();
      Logger.info(_source, "👋 User SOFT logged out. Refresh token is kept.");
    }
    _currentPassenger = null;
    _socketService.disconnect();

    // ✅ --- FIX: Check if the stream controller is closed before adding an event ---
    if (!_authStatusController.isClosed) {
      _authStatusController.add(AuthStatus.unauthenticated);
    }
  }

  Future<void> _checkInitialAuthStatus() async {
    await Future.delayed(const Duration(milliseconds: 50));

    final accessToken = await _storageService.getAccessToken();

    // Case 1: No access token stored. Try silent login immediately.
    if (accessToken == null) {
      Logger.info(_source, "No access token found. Attempting silent login...");
      await loginWithRefreshToken(); // This will handle success or failure internally
      return;
    }

    // Case 2: Access token exists, but it's expired.
    if (_isTokenExpired(accessToken)) {
      Logger.warning(
        _source,
        "Access token is EXPIRED. Attempting silent login...",
      );
      await loginWithRefreshToken(); // This will handle success or failure internally
      return;
    }

    // Case 3: Access token exists and is valid. Proceed directly.
    Logger.success(
      _source,
      "Valid access token found. Proceeding with profile fetch.",
    );
    _socketService.connect(accessToken);
    await getPassengerProfile(isInitialCheck: true);
  }

  /// ✅ --- Handles email login ---
  Future<Map<String, dynamic>> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final authUrl = Uri.parse(
      '${ApiConstants.authBaseUrl}/auth/passenger/login',
    );
    try {
      final response = await http.post(
        authUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      final body = jsonDecode(response.body);
      if (response.statusCode != 200)
        return {
          'success': false,
          'message': body['message'] ?? 'Invalid credentials.',
        };
      final accessToken = body['token'];
      final refreshToken = body['refreshToken'];
      if (accessToken == null)
        return {
          'success': false,
          'message': 'Invalid token response from server.',
        };
      await _processSuccessfulAuthentication(
        accessToken: accessToken,
        refreshToken: refreshToken,
        passengerJson: body['passenger'],
      );
      return {'success': true};
    } catch (e) {
      return {'success': false, 'message': 'Network error.'};
    }
  }

  Future<Map<String, dynamic>> completeInitialProfile({
    required String name,
    String? email,
  }) async {
    final token = await _storageService.getAccessToken();
    if (token == null) {
      return {
        'success': false,
        'message': 'Authentication session lost. Please log in again.',
      };
    }

    final url = Uri.parse('${ApiConstants.authBaseUrl}/passengers/profile/me');
    final Map<String, dynamic> body = {'name': name};
    if (email != null && email.isNotEmpty) {
      body['email'] = email;
    }

    Logger.info(_source, "🚀 Completing initial profile with name: $name");

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // --- THIS IS THE CORRECT AND FINAL LOGIC ---

        // 1. SUCCESS! The server has the new name.
        Logger.success(_source, "✅ Profile completion successful on server.");

        // 2. We now have the *new* and *complete* passenger data in the response.
        // We update our local state immediately. This is critical.
        final passenger = Passenger.fromJson(responseBody);
        _currentPassenger = passenger;

        // 3. We MUST save this new, complete profile to the local cache.
        // This prevents the app from re-fetching old data if it restarts quickly.
        await _storageService.saveProfileCache(responseBody);

        // 4. Finally, push the 'authenticated' status to the stream.
        // This tells the AuthWrapper to navigate to HomeScreen.

        // --- END OF CORRECT LOGIC ---

        return {'success': true};
      } else {
        // Handle server-side errors
        Logger.error(
          _source,
          "Profile completion failed on server: ${responseBody['message']}",
        );
        return {
          'success': false,
          'message': responseBody['message'] ?? 'Profile update failed.',
        };
      }
    } catch (e) {
      // Handle network errors
      Logger.error(_source, "Network error during profile completion.", e);
      return {
        'success': false,
        'message': 'A network error occurred. Please check your connection.',
      };
    }
  }

  Future<Map<String, dynamic>> verifyOtpAndLogin({
    required String phone,
    required String otp,
  }) async {
    final verifyUrl = Uri.parse('${ApiConstants.authBaseUrl}/auth/verify-otp');
    final loginUrl = Uri.parse('${ApiConstants.authBaseUrl}/auth/login');

    Logger.info(_source, "🚀 Starting OTP verification for 📱 $phone");

    try {
      // --- STEP 1: VERIFY OTP ---
      Logger.info(_source, "🔍 Verifying OTP code: $otp ...");

      final verifyResponse = await http.post(
        verifyUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'otp': otp}),
      );

      Logger.info(
        _source,
        "📥 OTP verification response: ${verifyResponse.statusCode}",
      );

      if (verifyResponse.statusCode != 200) {
        dynamic body;
        try {
          body = jsonDecode(verifyResponse.body);
        } catch (e) {
          Logger.warning(_source, "⚠️ Failed to decode OTP response JSON: $e");
          body = {};
        }

        final message = body['message'] ?? '❗ Invalid or expired OTP.';
        Logger.warning(_source, "❌ OTP verification failed: $message");
        return {'success': false, 'message': message};
      }

      final verifyBody = jsonDecode(verifyResponse.body);
      final tempAccessToken = verifyBody['accessToken'];
      final tempRefreshToken = verifyBody['refreshToken'];

      if (tempAccessToken == null || tempRefreshToken == null) {
        Logger.error(
          _source,
          "🚫 Missing temporary tokens in verify response: $verifyBody",
        );
        return {
          'success': false,
          'message': 'Server error ⚠️ Invalid verification response.',
        };
      }

      Logger.success(_source, "✅ OTP verified successfully!");

      // --- STEP 2: PERFORM LOGIN ---
      Logger.info(_source, "🔑 Performing secure login for $phone...");

      final loginResponse = await http.post(
        loginUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tempAccessToken',
          'X-Refresh-Token': tempRefreshToken,
        },
        body: jsonEncode({'phone': phone}),
      );

      Logger.info(
        _source,
        "📥 Login response status: ${loginResponse.statusCode}",
      );

      dynamic loginBody;
      try {
        loginBody = jsonDecode(loginResponse.body);
      } catch (e) {
        Logger.warning(_source, "⚠️ Failed to decode login response JSON: $e");
        loginBody = {};
      }

      if (loginResponse.statusCode != 200) {
        final msg = loginBody['message'] ?? 'Login failed ❌';
        Logger.warning(_source, "❌ Login failed: $msg");
        return {'success': false, 'message': msg};
      }

      final finalAccessToken = loginBody['token'];
      final finalRefreshToken = loginBody['refreshToken'];

      if (finalAccessToken == null || finalRefreshToken == null) {
        Logger.error(_source, "🚫 Missing final tokens in login response.");
        return {
          'success': false,
          'message': 'Server error ⚠️ Invalid login response.',
        };
      }

      // --- STEP 3: SAVE TOKENS AND CONNECT SOCKET ---
      Logger.info(_source, "💾 Saving tokens and initializing socket...");
      await _storageService.saveTokens(
        accessToken: finalAccessToken,
        refreshToken: finalRefreshToken,
      );
      _socketService.connect(finalAccessToken);
      Logger.success(
        _source,
        "🔐 Tokens saved & socket connected successfully.",
      );

      // --- STEP 4: FETCH USER PROFILE ---
      Logger.info(_source, "🧠 Fetching user profile to verify completion...");
      final profileResult = await getPassengerProfile();

      bool isProfileComplete = false;
      if (profileResult['success'] == true && profileResult['data'] != null) {
        final Passenger passenger = profileResult['data'];
        final name = passenger.name.trim();
        Logger.info(
          _source,
          "👤 Profile name: '${name.isEmpty ? '❌ Empty' : name}'",
        );

        if (name.trim().isNotEmpty && !name.toLowerCase().contains('unnamed')) {
          isProfileComplete = true;
          AuthStatus.authenticated;
        }
      } else {
        Logger.warning(
          _source,
          "⚠️ Could not verify profile completeness: ${profileResult['message']}",
        );
        AuthStatus.needsProfileCompletion;
      }

      // --- STEP 5: UPDATE STATUS & RETURN ---
      Logger.info(
        _source,
        "📊 Profile completion: ${isProfileComplete ? '✅ Complete' : '🟠 Incomplete'}",
      );

      if (!_authStatusController.isClosed) {
        _authStatusController.add(
          isProfileComplete
              ? AuthStatus.authenticated
              : AuthStatus.needsProfileCompletion,
        );
      }

      Logger.success(
        _source,
        "🎉 OTP + Login flow finished successfully for $phone!",
      );
      return {
        'success': true,
        'profileComplete': isProfileComplete,
        'message': isProfileComplete
            ? '✅ Login successful!'
            : '🟠 Login successful — please complete your profile.',
      };
    } catch (e, stack) {
      Logger.error(_source, "💥 Unexpected error during OTP flow.", e, stack);
      return {
        'success': false,
        'message': '🌐 Network or unexpected error occurred. Try again.',
      };
    }
  }

  /// ✅ --- RESTORED: This is needed by passenger_login_screen.dart ---
  Future<Map<String, dynamic>> loginWithPhone(String phone) async {
    // Note: This method is now primarily for direct login attempts if needed,
    // but the main login flow on the login screen uses `loginWithRefreshToken` first.
    final url = Uri.parse('${ApiConstants.authBaseUrl}/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );
      final body = jsonDecode(response.body);
      if (response.statusCode != 200) {
        return {
          'success': false,
          'message': body['message'] ?? 'Direct login failed.',
        };
      }
      final String? accessToken = body['token'];
      final String? refreshToken = body['refreshToken'];
      if (accessToken == null || refreshToken == null) {
        return {'success': false, 'message': 'Missing tokens in response.'};
      }
      await _processSuccessfulAuthentication(
        accessToken: accessToken,
        refreshToken: refreshToken,
        passengerJson: body['passenger'],
      );
      return {'success': true};
    } catch (e) {
      return {'success': false, 'message': '🌐 Network error.'};
    }
  }

  /// ✅ --- FIXED: The `isRegistering` parameter is no longer needed ---
  Future<Map<String, dynamic>> requestOtp(String phone) async {
    final url = Uri.parse('${ApiConstants.authBaseUrl}/auth/request-otp');
    Logger.info(_source, "📲 Requesting OTP for $phone");
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );
      final body = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'OTP sent successfully.'};
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Failed to request OTP.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  Future<Map<String, dynamic>> getPassengerProfile({
    bool isInitialCheck = false,
  }) async {
    print(
      "🚀 [Profile] Starting getPassengerProfile (initialCheck: $isInitialCheck)",
    );

    final token = await _storageService.getAccessToken();
    if (token == null) {
      print("⚠️ [Auth] No access token found.");

      if (isInitialCheck) {
        print("🔄 [Auth] Attempting silent login with refresh token...");
        final silentLoginResult = await loginWithRefreshToken();
        if (silentLoginResult['success']) {
          print("✅ [Auth] Silent login successful, retrying profile fetch...");
          return {'success': true};
        }
      }

      if (!_authStatusController.isClosed) {
        _authStatusController.add(AuthStatus.unauthenticated);
      }

      print("❌ [Auth] Not authenticated — redirecting to login.");
      return {'success': false, 'message': 'Not authenticated 😞'};
    }

    final url = Uri.parse('${ApiConstants.authBaseUrl}/passengers/profile/me');
    print("🌐 [API] Fetching profile from: $url");

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      print("📥 [Response] Status Code: ${response.statusCode}");

      // Try decoding body safely
      dynamic body;
      try {
        body = jsonDecode(response.body);
      } catch (e) {
        print("⚠️ [Decode] Failed to parse JSON: $e");
        body = {};
      }

      // ✅ SUCCESS CASE
      if (response.statusCode == 200) {
        final passenger = Passenger.fromJson(body);
        _currentPassenger = passenger;
        notifyListeners();

        await _storageService.savePassengerId(passenger.id.toString());
        await _storageService.saveProfileCache(body);

        final name = passenger.name.trim();
        print(
          "👤 [Passenger] Name: ${name.isEmpty ? '❌ Empty name' : '✅ $name'}",
        );
        print("🆔 [Passenger] ID: ${passenger.id}");

        if (!_authStatusController.isClosed) {
          if (name.isEmpty || name.toLowerCase().contains('passenger')) {
            print("🟠 [Auth] Profile incomplete — needs profile completion.");
            _authStatusController.add(AuthStatus.needsProfileCompletion);
          } else {
            print("✅ [Auth] Authenticated successfully.");
            _authStatusController.add(AuthStatus.authenticated);
          }
        }

        print("🎉 [Success] Profile loaded successfully!");
        return {
          'success': true,
          'data': passenger,
          'message': 'Profile loaded successfully ✅',
        };
      }
      // 🔐 TOKEN EXPIRED OR UNAUTHORIZED
      else if (response.statusCode == 401 || response.statusCode == 403) {
        print("🧠 [Auth] Token expired or invalid — attempting refresh...");
        final refreshed = await loginWithRefreshToken();
        if (refreshed['success']) {
          print(
            "🔁 [Auth] Token refreshed successfully — retrying profile fetch...",
          );
          return await getPassengerProfile();
        } else {
          print("❌ [Auth] Refresh token failed — logging out.");
          await logout(hard: true);
          return {'success': false, 'message': 'Session expired 🔒'};
        }
      }

      // ❗ OTHER API ERRORS
      final errorMsg = body['message'] ?? 'Failed to load profile ❌';
      print(
        "❗ [Error] Server responded with ${response.statusCode}: $errorMsg",
      );

      return {'success': false, 'message': errorMsg};
    } catch (e) {
      // 🌐 NETWORK FAILURE OR OFFLINE MODE
      print("💥 [Exception] Network or unexpected error: $e");

      if (isInitialCheck) {
        print("📦 [Cache] Trying to load cached profile...");
        final cachedProfile = await _storageService.getCachedProfile();
        if (cachedProfile != null) {
          print("📡 [Cache] Using cached profile data ✅");
          _currentPassenger = cachedProfile;
          if (!_authStatusController.isClosed) {
            _authStatusController.add(AuthStatus.authenticated);
          }
          return {
            'success': true,
            'data': cachedProfile,
            'message': 'Using cached data 📦',
          };
        }
        print("❌ [Cache] No cached data found.");
      }

      if (!_authStatusController.isClosed) {
        _authStatusController.add(AuthStatus.unauthenticated);
      }

      return {
        'success': false,
        'message': 'Network error 💔 Could not fetch profile.',
      };
    }
  }

  Future<Map<String, dynamic>> registerWithEmailPassword({
    required String name,
    required String phone,
    required String password,
    String? email,
  }) async {
    final url = Uri.parse(
      '${ApiConstants.authBaseUrl}/auth/passenger/register',
    );
    Logger.info(_source, "🚀 Attempting to register and log in user: $email");
    try {
      final requestBody = {
        'name': name,
        'phone': phone,
        'email': email,
        'password': password,
      };
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      final body = jsonDecode(response.body);

      // ✅ --- MAJOR FIX STARTS HERE ---
      // The backend should return 201 Created AND the login tokens.
      if (response.statusCode == 201) {
        final accessToken = body['token'];
        final refreshToken = body['refreshToken'];

        if (accessToken == null) {
          return {
            'success': false,
            'message':
                'Registration successful, but login failed. Please log in manually.',
          };
        }

        // Use the same central logic as a normal login to set up the session.
        await _processSuccessfulAuthentication(
          accessToken: accessToken,
          refreshToken: refreshToken,
          passengerJson: body['passenger'],
        );

        // The AuthWrapper will now automatically navigate to the HomeScreen.
        return {'success': true};
      } else {
        // Handle standard registration errors (e.g., email already exists)
        return {
          'success': false,
          'message': body['message'] ?? 'Registration failed.',
        };
      }
      // --- END OF FIX ---
    } catch (e) {
      Logger.error(_source, "Registration failed with a network error", e);
      return {'success': false, 'message': 'Network error.'};
    }
  }

  Future<Map<String, dynamic>> updatePassengerProfile({
    String? name,
    String? phone,
    String? email,
    List<Map<String, String>>? emergencyContacts,
  }) async {
    final token = await _storageService.getAccessToken();
    if (token == null) {
      return {'success': false, 'message': 'Not authenticated.'};
    }

    final url = Uri.parse('${ApiConstants.authBaseUrl}/passengers/profile/me');

    final Map<String, dynamic> body = {};
    if (name != null && name.isNotEmpty) body['name'] = name;
    if (phone != null && phone.isNotEmpty) body['phone'] = phone;
    if (email != null && email.isNotEmpty) body['email'] = email;
    if (emergencyContacts != null)
      body['emergencyContacts'] = jsonEncode(emergencyContacts);

    if (body.isEmpty) {
      return {'success': true, 'message': '✅ No changes to save.'};
    }
    print("👆👍👍👍👍👍👍👍👍👍👍👍👍👍👍👍R$body");

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // --- ✅ THIS IS THE CRITICAL FIX ---
        // 1. The server successfully updated the profile.
        Logger.success(
          _source,
          "✅ Profile successfully updated on the server.",
        );

        // 2. We now have the *new* and *complete* passenger data in the response.
        final passenger = Passenger.fromJson(responseBody);
        _currentPassenger = passenger;

        // 3. We MUST save this new, complete profile to the local cache.
        // This is what prevents the loop on the next app start.
        await _storageService.saveProfileCache(responseBody);

        // 4. Since the profile is now complete, we push the 'authenticated' status.
        // This tells the AuthWrapper to navigate to the HomeScreen.
        if (!_authStatusController.isClosed) {
          _authStatusController.add(AuthStatus.authenticated);
        }
        // --- END OF FIX ---

        return {'success': true, 'message': "✅ Profile updated successfully!"};
      } else {
        return {
          'success': false,
          'message':
              '⚠️ ${responseBody['message'] ?? 'Profile update failed.'}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'An error occurred.'};
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await _storageService.getAccessToken();
    if (token == null)
      return {'success': false, 'message': 'Not authenticated.'};
    final url = Uri.parse(
      '${ApiConstants.authBaseUrl}/passengers/update-password',
    );
    final body = {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    };
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseBody['message'] ?? 'Password updated!',
        };
      }
      return {
        'success': false,
        'message': responseBody['message'] ?? 'Password update failed.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error.'};
    }
  }

  bool _isTokenExpired(String token) {
    try {
      // Decode the token to get its payload
      final Map<String, dynamic> payload = Jwt.parseJwt(token);

      // 'exp' is the standard key for expiration time (in seconds since epoch)
      if (payload.containsKey('exp')) {
        final int expiryTimestamp = payload['exp'];

        // Create a DateTime object from the timestamp (multiply by 1000 for milliseconds)
        final DateTime expiryDate = DateTime.fromMillisecondsSinceEpoch(
          expiryTimestamp * 1000,
        );

        // Check if the current time is after the expiry date
        return DateTime.now().isAfter(expiryDate);
      }

      // If there's no 'exp' claim, we can't verify it, so let the server decide.
      return false;
    } catch (e) {
      // If decoding fails, the token is invalid and should be treated as expired.
      Logger.error(_source, "Failed to decode JWT token.", e);
      return true;
    }
  }

  void forceSetAuthenticated() {
    if (!_authStatusController.isClosed)
      _authStatusController.add(AuthStatus.authenticated);
  }

  Future<String?> getPassengerId() => _storageService.getPassengerId();

  void dispose() => _authStatusController.close();
}
