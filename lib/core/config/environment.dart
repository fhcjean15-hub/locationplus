class Environment {
  // --------------------------------------------
  // API CONFIG
  // --------------------------------------------

  /// Basé sur Laravel API
  static const String apiBaseUrl = "https://api-location-plus.lamadonebenin.com";

  /// Pour future bascule vers la prod
  static const bool isProduction = false;

  // --------------------------------------------
  // TIMEOUTS
  // --------------------------------------------
  static const int connectionTimeoutMs = 15000; // 15 sec
  static const int receiveTimeoutMs = 15000;    // 15 sec

  // --------------------------------------------
  // HELPERS
  // --------------------------------------------

  /// Construit automatiquement un endpoint complet
  static String endpoint(String path) {
    if (path.startsWith("/")) {
      return "$apiBaseUrl$path";
    }
    return "$apiBaseUrl/$path";
  }
}
