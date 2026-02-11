import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/data/providers/forgot_password_provider.dart';
import '../../data/services/api_service.dart';
import '../../data/repositories/forgot_password_repository.dart';
import '../../business/controllers/forgot_password_controller.dart';
import '../../business/states/forgot_password_state.dart';


/// ---------------------------------------------------------
/// 2️⃣ CONTROLLER PROVIDER
/// ---------------------------------------------------------
final forgotPasswordControllerProvider =
    StateNotifierProvider<ForgotPasswordController, ForgotPasswordState>((ref) {
  final repo = ref.watch(forgotPasswordRepositoryProvider);
  return ForgotPasswordController(repo);
});

