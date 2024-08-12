import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  final List<String> interests;
  final List<String> strengths;

  UserPreferences({
    required this.interests,
    required this.strengths,
  });

  static const _keyInterests = 'user_interests';
  static const _keyStrengths = 'user_strengths';
  static const _keyTokens = 'auth_tokens';
  static const _keyStaySignedIn = 'stay_signed_in';
  static const _keySelectedCareer = 'selected_career';

  Future<void> saveTokens(String refreshToken, String accessToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTokens, '$refreshToken|$accessToken');
  }

  Future<Map<String, dynamic>> loadTokens() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tokensString = prefs.getString(_keyTokens);
    if (tokensString != null) {
      List<String> tokens = tokensString.split('|');
      return {'refresh': tokens[0], 'access': tokens[1]};
    }
    return {};
  }

  Future<void> saveStaySignedIn(bool staySignedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyStaySignedIn, staySignedIn);
  }

  Future<bool> loadStaySignedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyStaySignedIn) ?? false;
  }

  Map<String, dynamic> toJson() {
    return {
      'interests': interests,
      'strengths': strengths,
    };
  }

  Future<void> saveSelectedCareer(String careerName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedCareer, careerName);
  }

  Future<String?> loadSelectedCareer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySelectedCareer);
  }

  static void clearUserSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyTokens);
    await prefs.remove(_keyStaySignedIn);
    await prefs.remove(_keySelectedCareer);
    await prefs.remove(_keyInterests);
    await prefs.remove(_keyStrengths);
  }
}
