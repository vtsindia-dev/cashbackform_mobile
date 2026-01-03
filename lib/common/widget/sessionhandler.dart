import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userIdKey = 'user_id';
  static const String _firstNameKey = 'first_name';
  static const String _lastNameKey = 'last_name';
  static const String _phoneKey = 'phone';
  static const String _emailKey = 'email';
  static const String _genderKey = 'gender';
  static const String _roleKey = 'role';
  static const String _dobKey = 'dob';
  static const String _pinCodeKey = 'pin_code';
  static const String _addressKey = 'address';
  static const String _profileImageKey = 'profile_image';
  static const String _loginTimeKey = 'login_time';
  static const String _tokenKey = 'auth_token'; // Changed from 'token' to 'auth_token' for clarity
  static const String _userDataKey = 'user_data'; // Add this to store full user data

  // Save user session with detailed logging
  static Future<void> saveUserSession(Map<String, dynamic> userData, {String? token}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      print('🔄 === SAVING SESSION ===');
      print('📱 User Data received: ${userData.toString()}');
      print('🔑 Token received: $token');
      print('📋 User Data keys: ${userData.keys.toList()}');

      // Save individual fields
      await prefs.setBool(_isLoggedInKey, true);

      // Save user ID - check multiple possible fields
      String? userId = userData['id']?.toString() ??
          userData['user_id']?.toString() ??
          userData['userId']?.toString();
      await prefs.setString(_userIdKey, userId ?? '');
      print('👤 User ID saved: $userId');

      // Save name
      String? fullName = userData['name']?.toString() ??
          userData['full_name']?.toString() ??
          '${userData['first_name'] ?? ''} ${userData['last_name'] ?? ''}'.trim();
      final nameParts = fullName.split(' ');
      await prefs.setString(_firstNameKey, nameParts.isNotEmpty ? nameParts[0] : '');
      await prefs.setString(_lastNameKey, nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '');
      print('👤 Name saved: $fullName');

      // Save contact info
      await prefs.setString(_phoneKey, userData['phone']?.toString() ?? userData['mobile']?.toString() ?? '');
      await prefs.setString(_emailKey, userData['email']?.toString() ?? '');
      print('📞 Phone saved: ${userData['phone']}');
      print('📧 Email saved: ${userData['email']}');

      // Save gender (convert to int)
      int gender = 1; // default
      if (userData['gender'] != null) {
        if (userData['gender'] is int) {
          gender = userData['gender'];
        } else if (userData['gender'] is String) {
          gender = int.tryParse(userData['gender']) ?? 1;
        }
      }
      await prefs.setInt(_genderKey, gender);
      print('⚧ Gender saved: $gender');

      // Save role
      int role = 1; // default
      if (userData['role'] != null) {
        if (userData['role'] is int) {
          role = userData['role'];
        } else if (userData['role'] is String) {
          role = int.tryParse(userData['role']) ?? 1;
        }
      }
      await prefs.setInt(_roleKey, role);
      print('🎭 Role saved: $role');

      // Save additional info
      await prefs.setString(_dobKey, userData['dob']?.toString() ?? userData['date_of_birth']?.toString() ?? '');
      await prefs.setString(_pinCodeKey, userData['pin']?.toString() ?? userData['pincode']?.toString() ?? userData['zip_code']?.toString() ?? '');
      await prefs.setString(_addressKey, userData['address']?.toString() ?? '');
      await prefs.setString(_profileImageKey, userData['avatar']?.toString() ?? userData['profile_image']?.toString() ?? userData['image']?.toString() ?? '');

      print('🎂 DOB saved: ${userData['dob']}');
      print('📍 PIN saved: ${userData['pin']}');
      print('🏠 Address saved: ${userData['address']}');
      print('🖼️ Profile image saved: ${userData['avatar']}');

      // CRITICAL: Save token
      if (token != null && token.isNotEmpty) {
        await prefs.setString(_tokenKey, token);
        print('✅ Token saved successfully: ${token.substring(0, min(token.length, 20))}...');
      } else {
        // Check if token is in userData
        String? tokenFromData = userData['token']?.toString() ??
            userData['access_token']?.toString() ??
            userData['auth_token']?.toString();
        if (tokenFromData != null && tokenFromData.isNotEmpty) {
          await prefs.setString(_tokenKey, tokenFromData);
          print('✅ Token from userData saved: ${tokenFromData.substring(0, min(tokenFromData.length, 20))}...');
        } else {
          print('⚠️ WARNING: No token found to save!');
        }
      }

      // Save login time
      await prefs.setString(_loginTimeKey, DateTime.now().toIso8601String());

      // Save complete user data as JSON for debugging
      await prefs.setString(_userDataKey, json.encode(userData));

      // Verify everything was saved
      await _verifySessionSaved();

      print('✅ === SESSION SAVED SUCCESSFULLY ===');
    } catch (e) {
      print('❌ Error saving session: $e');
      rethrow;
    }
  }

  // Verify session was saved correctly
  static Future<void> _verifySessionSaved() async {
    final prefs = await SharedPreferences.getInstance();

    print('🔍 === VERIFYING SESSION ===');
    print('🔑 Token exists: ${prefs.containsKey(_tokenKey)}');
    print('🔑 Token value: ${prefs.getString(_tokenKey)?.substring(0, min(prefs.getString(_tokenKey)?.length ?? 0, 20))}...');
    print('👤 User ID exists: ${prefs.containsKey(_userIdKey)}');
    print('👤 User ID value: ${prefs.getString(_userIdKey)}');
    print('✅ IsLoggedIn: ${prefs.getBool(_isLoggedInKey)}');

    // Print all stored keys
    final allKeys = prefs.getKeys();
    print('📋 All stored keys: $allKeys');

    for (final key in allKeys) {
      if (key == _tokenKey) {
        final token = prefs.getString(key);
        print('   $key: ${token?.substring(0, min(token?.length ?? 0, 20))}...');
      } else {
        print('   $key: ${prefs.get(key)}');
      }
    }
    print('✅ === VERIFICATION COMPLETE ===');
  }

  // Check if user is logged in
// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      print('🔍 === CHECKING LOGIN STATUS ===');

      // Changed variable name from 'isLoggedIn' to 'loggedInFlag' to avoid conflict
      final loggedInFlag = prefs.getBool(_isLoggedInKey) ?? false;
      final userId = prefs.getString(_userIdKey);
      final token = prefs.getString(_tokenKey);

      print('   IsLoggedIn flag: $loggedInFlag');
      print('   User ID: $userId');
      print('   Token exists: ${token != null}');
      print('   Token length: ${token?.length ?? 0}');

      final result = loggedInFlag &&
          userId != null &&
          userId.isNotEmpty &&
          token != null &&
          token.isNotEmpty;

      print('   Final result: $result');
      print('🔍 === END LOGIN CHECK ===');

      return result;
    } catch (e) {
      print('❌ Error checking login status: $e');
      return false;
    }
  }
  // Get authentication token
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      print('🔐 === GETTING TOKEN ===');

      final token = prefs.getString(_tokenKey);

      print('   Token from storage: $token');
      print('   Token is null: ${token == null}');
      print('   Token is empty: ${token?.isEmpty ?? true}');
      print('   All keys in storage: ${prefs.getKeys()}');

      if (token == null || token.isEmpty) {
        print('⚠️ WARNING: Token is null or empty!');

        // Debug: print all preferences
        for (final key in prefs.getKeys()) {
          final value = prefs.get(key);
          print('   $key: $value');
        }

        return null;
      }

      print('✅ Token retrieved successfully: ${token.substring(0, min(token.length, 20))}...');
      print('🔐 === END TOKEN RETRIEVAL ===');

      return token;
    } catch (e) {
      print('❌ Error getting token: $e');
      return null;
    }
  }

  // Get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      print('📋 === GETTING USER DATA ===');

      final loggedIn = await isLoggedIn();
      if (!loggedIn) {
        print('❌ User not logged in');
        return null;
      }

      // Try to get from JSON first
      final jsonData = prefs.getString(_userDataKey);
      if (jsonData != null && jsonData.isNotEmpty) {
        try {
          final userData = json.decode(jsonData) as Map<String, dynamic>;
          print('✅ User data retrieved from JSON');
          return userData;
        } catch (e) {
          print('❌ Error parsing JSON: $e');
        }
      }

      // Fallback to individual fields
      final userData = {
        'id': prefs.getString(_userIdKey),
        'first_name': prefs.getString(_firstNameKey),
        'last_name': prefs.getString(_lastNameKey),
        'phone': prefs.getString(_phoneKey),
        'email': prefs.getString(_emailKey),
        'gender': prefs.getInt(_genderKey),
        'role': prefs.getInt(_roleKey),
        'dob': prefs.getString(_dobKey),
        'pin_code': prefs.getString(_pinCodeKey),
        'address': prefs.getString(_addressKey),
        'profile_image': prefs.getString(_profileImageKey),
        'token': prefs.getString(_tokenKey),
      };

      print('✅ User data constructed from individual fields');
      print('📋 === END USER DATA RETRIEVAL ===');

      return userData;
    } catch (e) {
      print('❌ Error getting user data: $e');
      return null;
    }
  }

  // Clear session (logout)
  static Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      print('🗑️ === CLEARING SESSION ===');

      // Get values before clearing for logging
      final tokenBefore = prefs.getString(_tokenKey);
      final userIdBefore = prefs.getString(_userIdKey);

      print('   Token before clear: $tokenBefore');
      print('   User ID before clear: $userIdBefore');

      // Clear all session keys
      await prefs.remove(_isLoggedInKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_firstNameKey);
      await prefs.remove(_lastNameKey);
      await prefs.remove(_phoneKey);
      await prefs.remove(_emailKey);
      await prefs.remove(_genderKey);
      await prefs.remove(_roleKey);
      await prefs.remove(_dobKey);
      await prefs.remove(_pinCodeKey);
      await prefs.remove(_addressKey);
      await prefs.remove(_profileImageKey);
      await prefs.remove(_loginTimeKey);
      await prefs.remove(_tokenKey);
      await prefs.remove(_userDataKey);

      // Verify cleared
      final tokenAfter = prefs.getString(_tokenKey);
      final userIdAfter = prefs.getString(_userIdKey);

      print('   Token after clear: $tokenAfter');
      print('   User ID after clear: $userIdAfter');
      print('   All keys after clear: ${prefs.getKeys()}');

      print('✅ Session cleared successfully');
      print('🗑️ === END SESSION CLEAR ===');
    } catch (e) {
      print('❌ Error clearing session: $e');
    }
  }

  // Check if session is expired
  static Future<bool> isSessionExpired() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final loginTimeString = prefs.getString(_loginTimeKey);

      if (loginTimeString == null) {
        print('⚠️ No login time found, session considered expired');
        return true;
      }

      try {
        final loginDateTime = DateTime.parse(loginTimeString);
        final now = DateTime.now();
        final difference = now.difference(loginDateTime);

        // Session expires after 30 days
        final isExpired = difference.inDays > 30;

        print('⏰ Session expiry check:');
        print('   Login time: $loginDateTime');
        print('   Current time: $now');
        print('   Days since login: ${difference.inDays}');
        print('   Is expired: $isExpired');

        return isExpired;
      } catch (e) {
        print('❌ Error parsing login time: $e');
        return true;
      }
    } catch (e) {
      print('❌ Error checking session expiry: $e');
      return true;
    }
  }

  // Get specific user field
  static Future<String?> getUserField(String field) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(field);
      print('📄 Getting field "$field": $value');
      return value;
    } catch (e) {
      print('❌ Error getting field "$field": $e');
      return null;
    }
  }

  // Debug method to print all session data
  static Future<void> debugSession() async {
    print('🔍 Debugging session...');

    // Get token WITHOUT clearing it
    final token = await getToken();
    final userId = await getUserId();
    final allKeys = await _getAllKeys();

    print('    Token before check: ${token != null ? "${token.substring(0, 10)}..." : "null"}');
    print('    User ID before check: $userId');
    print('    Total stored keys: ${allKeys.length}');

    // DO NOT call clearSession() here
    // await clearSession(); // REMOVE THIS LINE IF IT EXISTS
  }

  // Helper method to get all stored keys (for debugging)
  static Future<Map<String, dynamic>> _getAllKeys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();
      final Map<String, dynamic> keyValues = {};

      for (var key in allKeys) {
        final value = prefs.get(key);
        keyValues[key] = value;
      }

      return keyValues;
    } catch (e) {
      print('Error getting all keys: $e');
      return {};
    }
  }
  // Update specific field
  static Future<void> updateField(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (value is String) {
        await prefs.setString(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      } else if (value is List<String>) {
        await prefs.setStringList(key, value);
      }

      print('✏️ Updated field "$key" to: $value');
    } catch (e) {
      print('❌ Error updating field "$key": $e');
    }
  }

  // Force save token (useful for debugging)
  static Future<void> forceSaveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_userIdKey, 'debug_user');

      print('🔧 Force saved token: ${token.substring(0, min(token.length, 20))}...');
      await debugSession();
    } catch (e) {
      print('❌ Error force saving token: $e');
    }
  }

  static Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      print('👤 === GETTING USER ID ===');

      final userId = prefs.getString(_userIdKey);

      print('   User ID from storage: $userId');
      print('   User ID is null: ${userId == null}');
      print('   User ID is empty: ${userId?.isEmpty ?? true}');

      if (userId == null || userId.isEmpty) {
        print('⚠️ WARNING: User ID is null or empty!');

        // Debug: try to get from user data JSON
        final jsonData = prefs.getString(_userDataKey);
        if (jsonData != null && jsonData.isNotEmpty) {
          try {
            final userData = json.decode(jsonData) as Map<String, dynamic>;
            final idFromJson = userData['id']?.toString() ??
                userData['user_id']?.toString() ??
                userData['userId']?.toString();
            if (idFromJson != null && idFromJson.isNotEmpty) {
              // Save it for future use
              await prefs.setString(_userIdKey, idFromJson);
              print('✅ User ID retrieved from JSON and saved: $idFromJson');
              return idFromJson;
            }
          } catch (e) {
            print('❌ Error parsing JSON for user ID: $e');
          }
        }

        return null;
      }

      print('✅ User ID retrieved successfully: $userId');
      print('👤 === END USER ID RETRIEVAL ===');

      return userId;
    } catch (e) {
      print('❌ Error getting user ID: $e');
      return null;
    }
  }
}