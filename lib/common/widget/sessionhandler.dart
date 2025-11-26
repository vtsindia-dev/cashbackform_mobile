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
  static const String _tokenKey = 'token';

  static Future<void> saveUserSession(Map<String, dynamic> userData, {String? token}) async {
    final prefs = await SharedPreferences.getInstance();

    print('Saving session with token: $token');

    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_userIdKey, userData['id']?.toString() ?? '');
    final fullName = userData['name']?.toString() ?? '';
    final nameParts = fullName.split(' ');
    await prefs.setString(_firstNameKey, nameParts.isNotEmpty ? nameParts[0] : '');
    await prefs.setString(_lastNameKey, nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '');

    await prefs.setString(_phoneKey, userData['phone']?.toString() ?? '');
    await prefs.setString(_emailKey, userData['email']?.toString() ?? '');
    await prefs.setInt(_genderKey, int.tryParse(userData['gender']?.toString() ?? '1') ?? 1);
    await prefs.setInt(_roleKey, int.tryParse(userData['role']?.toString() ?? '1') ?? 1);

    await prefs.setString(_dobKey, userData['dob']?.toString() ?? '');
    await prefs.setString(_pinCodeKey, userData['pin']?.toString() ?? '');
    await prefs.setString(_addressKey, userData['address']?.toString() ?? '');
    await prefs.setString(_profileImageKey, userData['avatar']?.toString() ?? '');

    if (token != null) {
      await prefs.setString(_tokenKey, token);
      print('Token saved successfully');
    } else {
      print('WARNING: Token is null, not saving token');
    }

    await prefs.setString(_loginTimeKey, DateTime.now().toIso8601String());

    print('Session saved successfully');
    print('User ID: ${userData['id']}');
    print('IsLoggedIn: ${prefs.getBool(_isLoggedInKey)}');
    final savedToken = prefs.getString(_tokenKey);
    print('Saved token in preferences: $savedToken');
  }
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    final userId = prefs.getString(_userIdKey);

    print('=== IS LOGGED IN DEBUG ===');
    print('isLoggedIn: $isLoggedIn');
    print('userId: $userId');
    print('userId is not empty: ${userId != null && userId.isNotEmpty}');

    final result = isLoggedIn && userId != null && userId.isNotEmpty;
    print('Final isLoggedIn result: $result');

    return result;
  }
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();

    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    final userId = prefs.getString(_userIdKey);

    print('=== GET USER DATA DEBUG ===');
    print('isLoggedIn from prefs: $isLoggedIn');
    print('userId from prefs: $userId');
    print('All keys in prefs: ${prefs.getKeys()}');

    if (!isLoggedIn) {
      print('❌ Not logged in, returning null');
      return null;
    }

    if (userId == null || userId.isEmpty) {
      print('❌ User ID is null or empty, returning null');
      return null;
    }
    for (final key in [
      _userIdKey, _firstNameKey, _lastNameKey, _phoneKey, _emailKey,
      _genderKey, _roleKey, _dobKey, _pinCodeKey, _addressKey, _profileImageKey, _tokenKey
    ]) {
      final value = prefs.get(key);
      print('$key: $value');
    }

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

    print('✅ Constructed userData: $userData');
    if (userData['id'] == null || userData['id']!.toString().isEmpty) {
      print('❌ User ID is missing in constructed data');
      return null;
    }

    return userData;
  }
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();

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
  }

  static Future<bool> isSessionExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final loginTimeString = prefs.getString(_loginTimeKey);

    if (loginTimeString == null) return true;

    try {
      final loginDateTime = DateTime.parse(loginTimeString);
      final now = DateTime.now();
      final difference = now.difference(loginDateTime);
      return difference.inDays > 30;
    } catch (e) {
      return true;
    }
  }

  static Future<String?> getUserField(String field) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(field);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
}