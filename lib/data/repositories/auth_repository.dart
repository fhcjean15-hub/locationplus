import 'package:dio/dio.dart';
import 'package:mobile/data/services/local_storage_service.dart';
import 'dart:io';
import 'dart:convert';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthRepository {
  final ApiService api;

  AuthRepository(this.api);

  // GET ALL USERS (ADMIN)
  Future<List<Map<String, dynamic>>> getAllUsers({int page = 1}) async {
    final token = await LocalStorageService.instance.getToken();
    print("🌐 Token utilisé pour /users: $token"); // debug

    // On ajoute la pagination si nécessaire
    final res = await api.get("/api/users");

    if (res is Map && res["data"] is List) {
      // On retourne uniquement la liste d'utilisateurs
      final data = res["data"];
      print("data: $data");
      return List<Map<String, dynamic>>.from(res["data"]);
    }

    throw Exception(
      "Format inattendu lors de la récupération des utilisateurs",
    );
  }

  // =====================================================
  // INIT PAYMENT
  // =====================================================
  Future<Map<String, dynamic>> initPayment({required double amount}) async {
    try {
      final res = await api.post("/api/payments/init", {"amount": amount});

      return Map<String, dynamic>.from(res);
    } on DioException catch (e) {
      print("🔥 PAYMENT ERROR:");
      print("➡ STATUS : ${e.response?.statusCode}");
      print("➡ DATA   : ${e.response?.data}");
      print("➡ MESSAGE: ${e.message}");

      final data = e.response?.data;

      if (data is Map && data["message"] != null) {
        throw Exception(data["message"]);
      }

      throw Exception("Erreur lors de l'initialisation du paiement");
    }
  }
  


  // ------------------------------------------------------------
  // CREATE USER (ADMIN)
  // ------------------------------------------------------------
  Future<User> createUser({
    required String email,
    required String accountType,
    required String password,
  }) async {
    final response = await api.post(
      '/api/admin/users/africa/location/africa/location',
      {"email": email, "account_type": accountType, "password": password},
    );

    final data = response['message'];
    print("data: $data");

    return User.fromJson(response['data']);
  }

  // LOGIN
  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await api.post("/api/login", {
      "email": email,
      "password": password,
    });

    return Map<String, dynamic>.from(res);
  }

  // REGISTER
  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final res = await api.post("/api/register", data);
    return Map<String, dynamic>.from(res);
  }

  // GET CURRENT USER
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final res = await api.get("/api/user");
    return Map<String, dynamic>.from(res);
  }

  // LOGOUT
  Future<void> logout() async {
    try {
      await api.post("/api/logout", {});
    } catch (_) {
      // on ignore → on cleanup local
    }
  }

  void _logFormData(FormData formData) {
    print("📦 ----- FORM DATA DEBUG -----");

    formData.fields.forEach((f) {
      print("📝 FIELD: ${f.key} = ${f.value}");
    });

    formData.files.forEach((f) {
      print("📎 FILE: ${f.key} -> filename: ${f.value.filename}");
    });

    print("📦 ----- END FORM DATA -----");
  }

  /// Met à jour le profil utilisateur
  Future<Map<String, dynamic>> updateProfile({
    String? fullName,
    String? email,
    String? phone,
    String? companyName,
    String? ifu,
    String? adresse,
    String? ville,
    String? accountCategoryId,
    File? avatarFile,
    List<File>? documentsFiles,
    String? currentPassword,
    String? password,
    bool? activated,
    required String userId,
  }) async {
    try {
      final formData = FormData();

      // Simuler PUT via POST
      formData.fields.add(MapEntry('_method', 'PUT'));
      // Champs texte facultatifs
      if (fullName != null)
        formData.fields.add(MapEntry('full_name', fullName));
      if (email != null) formData.fields.add(MapEntry('email', email));
      if (phone != null) formData.fields.add(MapEntry('phone', phone));
      if (companyName != null)
        formData.fields.add(MapEntry('company_name', companyName));
      if (ifu != null) formData.fields.add(MapEntry('ifu', ifu));
      if (adresse != null) formData.fields.add(MapEntry('adresse', adresse));
      if (ville != null) formData.fields.add(MapEntry('ville', ville));
      if (accountCategoryId != null) {
        formData.fields.add(
          MapEntry('account_category_id', accountCategoryId?.toString() ?? ''),
        );
      }
      if (activated != null) {
        formData.fields.add(MapEntry('activated', activated! ? '1' : '0'));
      }

      // Fichiers documents (plusieurs)
      if (documentsFiles != null && documentsFiles.isNotEmpty) {
        for (var i = 0; i < documentsFiles.length; i++) {
          final file = documentsFiles[i];
          formData.files.add(
            MapEntry(
              'documents_urls[]',
              await MultipartFile.fromFile(
                file.path,
                filename: file.path.split('/').last,
              ),
            ),
          );
        }
      }

      // Avatar
      if (avatarFile != null) {
        formData.files.add(
          MapEntry(
            'avatar_url',
            await MultipartFile.fromFile(
              avatarFile.path,
              filename: avatarFile.path.split('/').last,
            ),
          ),
        );
      }

      // Password
      if (currentPassword != null)
        formData.fields.add(MapEntry('current_password', currentPassword));
      if (password != null) formData.fields.add(MapEntry('password', password));
      if (password != null)
        formData.fields.add(MapEntry('password_confirmation', password));

      // _logFormData(formData);
      // Requête PUT
      final response = await api.post(
        "/api/users/$userId",
        formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final data = response['data'];
      print("data: $data");

      return Map<String, dynamic>.from(response);
    } on DioException catch (e) {
      print("🔥 DIO ERROR FULL:");
      print("➡ STATUS : ${e.response?.statusCode}");
      print("➡ DATA   : ${e.response?.data}");
      print("➡ ERROR  : ${e.error}");
      print("➡ MESSAGE: ${e.message}");

      final data = e.response?.data;

      // Cas 1 : Laravel ValidationErrors
      if (data is Map && data["errors"] is Map<String, dynamic>) {
        final errors = data["errors"] as Map<String, dynamic>;
        final firstErrorList = errors.values.first;
        final firstMessage = firstErrorList is List
            ? firstErrorList.first
            : firstErrorList;

        throw Exception(firstMessage.toString());
      }

      // Cas 2 : message simple
      if (data is Map && data["message"] != null) {
        throw Exception(data["message"]);
      }

      // Cas 3 : texte brut (rare)
      if (data is String) {
        throw Exception(data);
      }

      throw Exception("Erreur réseau inconnue");
    }
  }

  Future<String> updatePaymentStatus({
    String? payParams
  }) async {
    final response = await api.post('/user/update-payment-status', {
      payParams
    });

    final data = response['data'];

    return data?.payment_status as String;
  }


  // =====================================================
  // GET ACCOUNT CATEGORY OF CURRENT USER
  // =====================================================
  Future<Map<String, dynamic>> getAccountCategoryById(int id) async {
    final res = await api.get("/api/account-categories/$id");
    return Map<String, dynamic>.from(res['data']);
  }

  Future<Map<String, dynamic>> getAccountCategory(int id) async {
    final res = await api.get("/api/account-categories/$id");
    final data = res['data'];
    print("$data");
    return Map<String, dynamic>.from(res['data']);
  }

  Future<Map<String, dynamic>> toggleUserActivation({
    required String id,
    required bool activated,
  }) async {
    try {
      final response = await api.post('/api/admin/users/$id/activated', {
        'activated': activated! ? '1' : '0',
        '_method': 'PUT',
      });

      final data = response['data'];

      return Map<String, dynamic>.from(response);
    } on DioException catch (e) {
      rethrow;
    }
  }

  /// Crée une nouvelle notification
  Future<Map<String, dynamic>> postNotification({
    required String userId,
    required String
    type, // 'paiement','demande','signalement','admin_action','compte_validé','compte_rejeté'
    Map<String, dynamic>? payload,
  }) async {
    try {
      final response = await api.post("/api/notifications", {
        "user_id": userId,
        "type": type,
        "payload": payload ?? {},
      });

      return Map<String, dynamic>.from(response);
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data["message"] != null) {
        throw Exception(data["message"]);
      }
      throw Exception(e.message ?? "Erreur réseau");
    }
  }

  // =====================================================
  // METTRE À JOUR UNE NOTIFICATION (FORMDATA)
  // =====================================================
  Future<Map<String, dynamic>> updateNotification({
    required String notificationId,
    String? type,
    Map<String, dynamic>? payload,
    bool? read,
  }) async {
    final formData = FormData();

    if (type != null) {
      formData.fields.add(MapEntry('type', type));
    }
    if (payload != null) {
      // On encode le payload en JSON pour le FormData
      formData.fields.add(MapEntry('payload', jsonEncode(payload)));
    }
    if (read != null) {
      formData.fields.add(MapEntry('read', read ? '1' : '0'));
    }

    _logFormData(formData);

    final response = await api.put(
      "/api/notifications/$notificationId",
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    return Map<String, dynamic>.from(response['data']);
  }

  Future<Map<String, dynamic>> getLastVerificationNotification(
    String userId,
  ) async {
    try {
      final response = await api.get(
        '/api/notifications/last-verification/$userId',
      );

      return {
        "data": response['data'],
        "hasVerification": response['has_verification'],
      };
    } catch (e) {
      rethrow;
    }
  }
}
