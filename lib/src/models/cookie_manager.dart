/// Interface for cookie management.
///
/// Implement this interface to provide custom cookie storage for
/// authentication. This allows you to use any storage mechanism
/// (secure storage, shared preferences, etc.)
///
/// Example implementation:
/// ```dart
/// class MyCookieManager implements CookieManager {
///   final FlutterSecureStorage _storage;
///
///   MyCookieManager(this._storage);
///
///   @override
///   Future<String> getCookies(String url) async {
///     final sid = await _storage.read(key: 'sid');
///     final userId = await _storage.read(key: 'user_id');
///
///     if (sid != null && userId != null) {
///       return 'sid=$sid; user_id=$userId';
///     }
///     return '';
///   }
///
///   @override
///   Future<void> saveCookies(String url, List<String> cookies) async {
///     for (final cookie in cookies) {
///       if (cookie.startsWith('sid=')) {
///         final sid = cookie.split(';')[0].split('=')[1];
///         await _storage.write(key: 'sid', value: sid);
///       }
///       if (cookie.startsWith('user_id=')) {
///         final userId = cookie.split(';')[0].split('=')[1];
///         await _storage.write(key: 'user_id', value: userId);
///       }
///     }
///   }
/// }
/// ```
abstract class CookieManager {
  /// Gets cookies for the given URL as a string.
  ///
  /// Should return cookies in the format: `'sid=value; user_id=value'`
  Future<String> getCookies(String url);

  /// Saves cookies from a response.
  ///
  /// The [cookies] parameter contains a list of cookie strings from the
  /// server response headers.
  Future<void> saveCookies(String url, List<String> cookies);
}
