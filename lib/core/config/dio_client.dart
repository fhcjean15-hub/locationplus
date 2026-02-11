import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'environment.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late final Dio dio;

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: Environment.apiBaseUrl,
        connectTimeout: Duration(milliseconds: Environment.connectionTimeoutMs),
        receiveTimeout: Duration(milliseconds: Environment.receiveTimeoutMs),
        headers: {
          "Accept": "application/json",
        },
      ),
    );

    _setupInterceptors();
  }

  // // ---------------------------------------------------------
  // // CHARGER LE CSRF COOKIE DE SANCTUM
  // // ---------------------------------------------------------
  // Future<void> init() async {
  //   try {
  //     final res = await dio.get("/sanctum/csrf-cookie");

  //     // Laravel renvoie XSRF-TOKEN dans Set-Cookie
  //     final cookies = res.headers["set-cookie"];
  //     if (cookies != null) {
  //       final xsrf = _extractCookieValue(cookies, "XSRF-TOKEN");
  //       if (xsrf != null) {
  //         dio.options.headers["X-XSRF-TOKEN"] = xsrf;
  //         print("🔐 XSRF token chargé !");
  //       }
  //     }
  //   } catch (e) {
  //     print("Erreur lors du chargement CSRF: $e");
  //   }
  // }

  // Extrait un cookie par son nom
  String? _extractCookieValue(List<String> cookies, String key) {
    for (final c in cookies) {
      if (c.startsWith("$key=")) {
        return c.split("=").elementAt(1).split(";").first;
      }
    }
    return null;
  }

  // ---------------------------------------------------------
  // INTERCEPTORS
  // ---------------------------------------------------------
  void _setupInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        // TOKEN BEARER AUTOMATIQUE
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString("token");

          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }

          handler.next(options);
        },

        // ERREURS LARAVEL
        onError: (error, handler) {
          final response = error.response;

          if (response != null && response.data is Map) {
            final Map data = response.data;

            if (data.containsKey("errors")) {
              handler.reject(
                DioException(
                  requestOptions: error.requestOptions,
                  message: data["errors"].toString(),
                  response: response,
                ),
              );
              return;
            }

            if (data.containsKey("message")) {
              handler.reject(
                DioException(
                  requestOptions: error.requestOptions,
                  message: data["message"],
                  response: response,
                ),
              );
              return;
            }
          }

          handler.next(error);
        },
      ),
    );
  }

  // ---------------------------------------------------------
  // SINGLE ACCESS POINT
  // ---------------------------------------------------------
  Dio get client => dio;
}
