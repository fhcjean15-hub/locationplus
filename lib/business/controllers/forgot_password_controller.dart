import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/forgot_password_repository.dart';
import '../states/forgot_password_state.dart';

class ForgotPasswordController extends StateNotifier<ForgotPasswordState> {
  final ForgotPasswordRepository repo;

  ForgotPasswordController(this.repo) : super(ForgotPasswordState.initial());

  // ---------------------------------------------------------
  // 1️⃣ ENVOI DE L’EMAIL
  // ---------------------------------------------------------
  Future<bool> sendEmail(String email) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      await repo.sendEmail(email);

      state = state.copyWith(
        isLoading: false,
        email: email,
        emailSent: true,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // ---------------------------------------------------------
  // 2️⃣ VÉRIFICATION DU CODE OTP
  // ---------------------------------------------------------
  Future<bool> verifyCode(String code) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      if (state.email == null) {
        throw Exception("Email non trouvé dans l’état.");
      }

      await repo.verifyOtp(
        email: state.email!,
        code: code,
      );

      state = state.copyWith(
        isLoading: false,
        code: code,          // 🔥 Sauvegarde pour l’étape 3
        codeVerified: true,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // ---------------------------------------------------------
  // 3️⃣ RESET PASSWORD
  // ---------------------------------------------------------
  Future<bool> resetPassword(String password) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      if (state.email == null) {
        throw Exception("Email manquant.");
      }
      if (state.code == null) {
        throw Exception("Code OTP manquant.");
      }
      if (!state.codeVerified) {
        throw Exception("Code non encore vérifié.");
      }

      await repo.resetPassword(
        email: state.email!,
        code: state.code!,
        password: password,
      );

      state = state.copyWith(
        isLoading: false,
        passwordReset: true,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }
}
