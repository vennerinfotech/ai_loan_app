import '../services/api_service.dart';

class MediaUtility {
  static String get serverBaseUrl => ApiService.baseUrl.replaceAll('/api', '');

  /// Normalizes a media URL or path.
  /// - Returns empty string if the input path is empty or null.
  /// - If the path is already a full URL (http/https), returns it as-is.
  /// - If the path is a local asset path (starts with assets/), returns it as-is.
  /// - If the path is a local filesystem path (starts with /data/, /user/, etc.), returns it as-is.
  /// - Otherwise, prepends the serverBaseUrl.
  static String normalizeUrl(String? path) {
    if (path == null || path.isEmpty) {
      return '';
    }

    // Full URLs
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    // Local assets
    if (path.startsWith('assets/')) {
      return path;
    }

    // Local file system path (e.g. image picker path /data/user/...)
    if (path.startsWith('/data/') ||
        path.startsWith('/user/') ||
        path.contains('/cache/') ||
        path.startsWith('file:///')) {
      return path;
    }

    // If it's a relative path from the server
    var cleanPath = path.startsWith('/') ? path : '/$path';
    return '$serverBaseUrl$cleanPath';
  }
}
