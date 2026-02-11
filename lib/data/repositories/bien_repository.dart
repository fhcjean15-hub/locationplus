import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../models/bien_model.dart';

class BienRepository {
  final ApiService api;

  BienRepository(this.api);

  // ---------------------------------------------------------------------------
  // CREATE BIEN (MULTIPART)
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> createBien({
    required String category,
    required String transactionType,
    required String title,
    required String description,
    required double price,
    required String city,
    required Map<String, dynamic> attributes,
    List<XFile>? images,
  }) async {
    try {
      final formData = FormData();

      // ---------------- TEXT FIELDS ----------------
      formData.fields.addAll([
        MapEntry('category', category),
        MapEntry('transaction_type', transactionType),
        MapEntry('title', title),
        MapEntry('description', description),
        MapEntry('price', price.toString()),
        MapEntry('city', city),
      ]);

      // ✅ ATTRIBUTES (ARRAY COMPATIBLE LARAVEL)
      attributes.forEach((key, value) {
        if (value is bool) {
          formData.fields.add(MapEntry('attributes[$key]', value ? '1' : '0'));
        } else {
          formData.fields.add(MapEntry('attributes[$key]', value.toString()));
        }
      });

      // ---------------- IMAGES ----------------
      if (images != null && images.isNotEmpty) {
        for (final image in images) {
          formData.files.add(
            MapEntry(
              'images[]',
              await MultipartFile.fromFile(image.path, filename: image.name),
            ),
          );
        }
      }

      _logFormData(formData);

      // ---------------- API CALL ----------------
      final response = await api.post(
        '/api/biens',
        formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      return Map<String, dynamic>.from(response);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // UPDATE BIEN (MULTIPART)
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> updateBien({
    required int id,
    required String title,
    required String description,
    required double price,
    String? city,
    required Map<String, dynamic> attributes,
    List<XFile>? newImages,
    List<String>? keepImages,
  }) async {
    try {
      final formData = FormData();

      // ---------------- TEXT FIELDS ----------------
      formData.fields.addAll([
        MapEntry('title', title),
        MapEntry('description', description),
        MapEntry('price', price.toString()),
        if (city != null) MapEntry('city', city),
        const MapEntry('_method', 'PUT'), // Laravel PUT override
      ]);

      // ---------------- ATTRIBUTES ----------------
      attributes.forEach((key, value) {
        formData.fields.add(
          MapEntry(
            'attributes[$key]',
            value is bool ? (value ? '1' : '0') : value.toString(),
          ),
        );
      });

      // ---------------- IMAGES ----------------
      // 1️⃣ nouvelles images
      if (newImages != null && newImages.isNotEmpty) {
        for (final image in newImages) {
          formData.files.add(
            MapEntry(
              'images[]',
              await MultipartFile.fromFile(image.path, filename: image.name),
            ),
          );
        }
      }

      // 2️⃣ images existantes à conserver
      if (keepImages != null && keepImages.isNotEmpty) {
        for (final url in keepImages) {
          formData.fields.add(MapEntry('keep_images[]', url));
        }
      }

      _logFormData(formData); // si tu as une fonction de debug

      final response = await api.post(
        '/api/biens/$id',
        formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      return Map<String, dynamic>.from(response['data']);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // GET USER BIENS
  // ---------------------------------------------------------------------------
  Future<List<dynamic>> getUserBiens() async {
    try {
      final response = await api.get('/api/mesbiens/user');
      print("📦 getUserBiens response: $response");

      // Toujours retourner une liste même si response['data'] est null
      if (response is Map && response['data'] != null) {
        return response['data'] as List<dynamic>;
      }

      // Si la réponse n’a pas de clé 'data', retourne la réponse comme liste
      if (response is List) {
        return response;
      }

      // Sinon, retourne une liste vide
      return [];
    } on DioException catch (e) {
      _handleDioError(e);
      return []; // jamais throw, retourne une liste vide
    } catch (e) {
      print("❌ getUserBiens unexpected error: $e");
      return []; // jamais throw
    }
  }

  // ---------------------------------------------------------------------------
  // GET company BIENS
  // ---------------------------------------------------------------------------
  Future<List<dynamic>> getCompanyBiens({required int id}) async {
    try {
      final response = await api.get('/api/cesbiens/${id}');
      print("📦 getUserBiens response: $response");

      // Toujours retourner une liste même si response['data'] est null
      if (response is Map && response['data'] != null) {
        return response['data'] as List<dynamic>;
      }

      // Si la réponse n’a pas de clé 'data', retourne la réponse comme liste
      if (response is List) {
        return response;
      }

      // Sinon, retourne une liste vide
      return [];
    } on DioException catch (e) {
      _handleDioError(e);
      return []; // jamais throw, retourne une liste vide
    } catch (e) {
      print("❌ getCompanyBiens unexpected error: $e");
      return []; // jamais throw
    }
  }

  // ---------------------------------------------------------------------------
  // DELETE BIEN
  // ---------------------------------------------------------------------------
  Future<bool> deleteBien(int id) async {
    try {
      final response = await api.delete('/api/biens/$id');

      return true;
    } on DioException catch (e) {
      _handleDioError(e);
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // DEBUG FORMDATA
  // ---------------------------------------------------------------------------
  void _logFormData(FormData formData) {
    print("📦 ----- BIEN FORM DATA DEBUG -----");

    for (final field in formData.fields) {
      print("📝 ${field.key}: ${field.value}");
    }

    for (final file in formData.files) {
      print("📎 ${file.key}: ${file.value.filename}");
    }

    print("📦 ----- END BIEN FORM DATA -----");
  }

  // ---------------------------------------------------------------------------
  // ERROR HANDLING
  // ---------------------------------------------------------------------------
  Never _handleDioError(DioException e) {
    print("🔥 BIEN API ERROR");
    print("➡ STATUS : ${e.response?.statusCode}");
    print("➡ DATA   : ${e.response?.data}");
    print("➡ MSG    : ${e.message}");

    final data = e.response?.data;

    if (data is Map && data['errors'] is Map<String, dynamic>) {
      final errors = data['errors'] as Map<String, dynamic>;
      final firstError = errors.values.first;
      throw Exception(
        firstError is List ? firstError.first : firstError.toString(),
      );
    }

    if (data is Map && data['message'] != null) {
      throw Exception(data['message']);
    }

    if (data is String) {
      throw Exception(data);
    }

    throw Exception("Erreur réseau inconnue");
  }

  Future<List<BienModel>> getAllUserBiens() async {
    try {
      final response = await api.get('/api/biens');

      final List data = (response['data'] as List); // <-- extraire la liste
      return data.map((e) => BienModel.fromJson(e)).toList();
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  // Récupère tous les biens via URL publique
  Future<List<BienModel>> getAllBiensPublic() async {
    try {
      final response = await api.get('/api/biens/libre');

      // Assure-toi que c'est bien une liste
      final data = response['data'];
      print('data: $data');
      if (data is List) {
        return data
            .map((e) => BienModel.fromJson(e))
            .toList();
      } else {
        // Si jamais ce n'est pas une liste
        return [];
      }
    } on DioException catch (e) {
      throw Exception('Erreur lors de la récupération des biens: ${e.message}');
    }
  }

  Future<void> toggleBienActivation({
    required int id,
    required bool actif,
  }) async {
    try {
      await api.post('/api/admin/biens/$id/actif', {
        'actif': actif! ? '1' : '0',
        '_method': 'PUT',
      });
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }
}
