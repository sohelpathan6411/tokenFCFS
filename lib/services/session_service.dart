import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  Future<void> storeSession(selectLoginRole) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'lastLoginRole', selectLoginRole); // Store last login role as admin
    // Add more session information as needed
  }

  Future<String?> getLastLoginRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('lastLoginRole'); // Default role is admin
  }

  Future<void> logout() async {
    // Clear session information
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
