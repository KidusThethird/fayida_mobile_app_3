import 'package:cookie_jar/cookie_jar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersistentCookieJar implements CookieJar {
  final String _cookieKey = 'cookies';

  @override
  Future<List<Cookie>> loadForRequest(Uri url) async {
    final prefs = await SharedPreferences.getInstance();
    final cookies = prefs.getStringList(_cookieKey) ?? [];
    return cookies
        .map((cookieStr) => Cookie.fromSetCookieValue(cookieStr))
        .toList();
  }

  @override
  Future<void> saveFromResponse(Uri url, List<Cookie> cookies) async {
    final prefs = await SharedPreferences.getInstance();
    final cookieStrs = cookies.map((cookie) => cookie.toString()).toList();
    await prefs.setStringList(_cookieKey, cookieStrs);
  }

  @override
  Future<void> deleteAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cookieKey); // Remove all cookies
  }

  @override
  Future<void> delete(Uri url, [bool ignoreExpiration = false]) async {
    // This logic can be implemented as needed.
    // Currently, it's a placeholder and does not delete specific cookies.
  }

  @override
  bool get ignoreExpires => false; // Set as needed
}
