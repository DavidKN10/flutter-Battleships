import 'package:shared_preferences/shared_preferences.dart';

// for the implementation of login and logout

class SessionManager {
  static const String _sessionKey = "sessionToken";
  static const String _sessionUser = "sessionUser";

  // check if a user if logged in 
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionToken = prefs.getString(_sessionKey);
    return sessionToken != null;
  }

  // retrieve session token
  static Future<String> getSessionToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionKey) ?? "";
  }

  // retrieve session user
  static Future<String> getSessionUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionUser) ?? "";
  }

  // set session token
  static Future<void> setSessionToken(String token, String user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, token);
    await prefs.setString(_sessionUser, user);
  }

  // clear session token, used for loggin the user out
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    await prefs.remove(_sessionUser);
  }
}