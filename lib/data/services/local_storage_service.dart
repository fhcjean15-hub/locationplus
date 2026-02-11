import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  // ======================================================
  // SINGLETON
  // ======================================================
  LocalStorageService._privateConstructor();
  static final LocalStorageService instance =
      LocalStorageService._privateConstructor();

  // ======================================================
  // SAVE TOKEN
  // ======================================================
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  // ======================================================
  // GET TOKEN
  // ======================================================
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // ======================================================
  // REMOVE TOKEN
  // ======================================================
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }

  // ======================================================
  // SAVE ANY JSON STRING (optional future use)
  // ======================================================
  Future<void> saveData(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  // ======================================================
  // GET ANY SAVED JSON STRING
  // ======================================================
  Future<String?> loadData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  // ======================================================
  // CLEAR ALL STORAGE (very useful for logout)
  // ======================================================
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
