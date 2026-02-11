import 'package:dio/dio.dart';
import '../services/api_service.dart';

class ForgotPasswordRepository {
  final ApiService api;

  ForgotPasswordRepository(this.api);

  // ---------------------------------------------------------
  // 1️⃣ Envoi de l'email pour recevoir l'OTP
  // ---------------------------------------------------------
  Future<Map<String, dynamic>> sendEmail(String email) async {
    final response = await api.post("/api/forgot-password", {
      "email": email,
    });

    return response; // doit contenir { success: true }
  }

  // ---------------------------------------------------------
  // 2️⃣ Vérification du code OTP
  // ---------------------------------------------------------
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String code,
  }) async {
    final response = await api.post("/api/verify-otp", {
      "email": email,
      "otp": code,
    });

    return response; // doit contenir { verified: true }
  }

  // ---------------------------------------------------------
  // 3️⃣ Réinitialisation du mot de passe
  // ---------------------------------------------------------
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    final response = await api.post("/api/reset-password", {
      "email": email,
      "otp": code,
      "password": password,
      "password_confirmation": password,
    });

    return response; // doit contenir { reset: true }
  }
}
