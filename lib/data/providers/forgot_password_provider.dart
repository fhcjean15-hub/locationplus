import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/data/providers/api_providers.dart';
import '../../data/services/api_service.dart';
import '../../data/repositories/forgot_password_repository.dart';
import '../../business/controllers/forgot_password_controller.dart';
import '../../business/states/forgot_password_state.dart';

/// ---------------------------------------------------------
/// 1️⃣ REPOSITORY PROVIDER
/// ---------------------------------------------------------
final forgotPasswordRepositoryProvider =
    Provider<ForgotPasswordRepository>((ref) {
  final api = ref.watch(apiServiceProvider);
  return ForgotPasswordRepository(api);
});
