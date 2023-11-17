import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  static String getString(String key, String value) {
    return _prefs.getString(key) ?? value;
  }

  static int getInt(String key, int value) {
    return _prefs.getInt(key) ?? value;
  }

  static Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  static Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  static bool getBool(String key, bool value) {
    return _prefs.getBool(key) ?? value;
  }

  static Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  static double getDouble(String key, double value) {
    return _prefs.getDouble(key) ?? value;
  }

  static Future<bool> remove(String key) async {
    return _prefs.remove(key);
  }

  static clear() {
    _prefs.clear();
  }
}
