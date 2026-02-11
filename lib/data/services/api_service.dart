import 'package:dio/dio.dart';
import '../../core/config/environment.dart';
import 'local_storage_service.dart';

class ApiService {
  late final Dio dio;

  ApiService(Dio baseDio) {
    dio = baseDio;

    // ------------------------------------------------------
    // INTERCEPTOR → ajoute automatiquement le token
    // ------------------------------------------------------
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await LocalStorageService.instance.getToken();

          if (token != null && token.isNotEmpty) {
            options.headers["Authorization"] = "Bearer $token";
          }

          return handler.next(options);
        },

        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  // ---------------------------------------------------------
  // GET
  // ---------------------------------------------------------
  Future<dynamic> get(String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.get(Environment.endpoint(endpoint),
      queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw Exception(_extractMessage(e));
    }
  }

  // ---------------------------------------------------------
  // POST
  // ---------------------------------------------------------
  // Future<dynamic> post(String endpoint, Map<String, dynamic> data, {dynamic data, Options? options}) async {
  //   try {
  //     final response = await dio.post(
  //       Environment.endpoint(endpoint),
  //       data: data,
  //     );
  //     return response.data;
  //   } on DioException catch (e) {
  //     throw Exception(_extractMessage(e));
  //   }
  // }
  Future<dynamic> post(String endpoint, dynamic data, {Options? options}) async {
  try {
    final response = await dio.post(
      Environment.endpoint(endpoint),
      data: data, // data peut être Map<String,dynamic> ou FormData
      options: options,
    );
    return response.data;
  } on DioException catch (e) {
    throw Exception(_extractMessage(e));
  }
}


  // ---------------------------------------------------------
  // PUT
  // ---------------------------------------------------------
  Future<dynamic> put(String endpoint, {dynamic data, Options? options}) async {
    try {
      final response = await dio.put(
        Environment.endpoint(endpoint),
        data: data,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(_extractMessage(e));
    }
  }


  // ---------------------------------------------------------
  // DELETE
  // ---------------------------------------------------------
  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await dio.delete(Environment.endpoint(endpoint));
      return response.data;
    } on DioException catch (e) {
      throw Exception(_extractMessage(e));
    }
  }

  // ---------------------------------------------------------
  // EXTRACT ERROR MESSAGE
  // ---------------------------------------------------------
  String _extractMessage(DioException e) {
    final data = e.response?.data;

    if (data is Map && (data["message"] != null)) {
      return data["message"].toString();
    }

    if (e.message != null) return e.message!;
    return "Erreur réseau";
  }
}



