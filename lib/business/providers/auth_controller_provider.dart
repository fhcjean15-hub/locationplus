import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/data/repositories/auth_repository.dart';
import '../controllers/auth_controller.dart';
import '../../data/providers/auth_providers.dart';
import '../states/auth_state.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthController(repo);
});


/// ---------------------------------------------------------
/// AUTH REPOSITORY PROVIDER
/// ---------------------------------------------------------
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final api = ref.watch(apiServiceProvider);
  return AuthRepository(api);
});
