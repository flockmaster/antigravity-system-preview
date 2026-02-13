class AppConstants {
  static const String imageBaseUrl = '';

  static String getImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http') || url.startsWith('assets/') || url.startsWith('file://')) {
      return url;
    }
    // If it's a relative path and we have a base URL, prepend it.
    // If base URL is empty, just return url (or maybe it is a local file path?)
    if (imageBaseUrl.isEmpty) return url;
    return '$imageBaseUrl/$url';
  }
}
