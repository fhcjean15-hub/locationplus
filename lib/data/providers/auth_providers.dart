import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../data/services/api_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../business/controllers/auth_controller.dart';
import '../../business/states/auth_state.dart';

/// ---------------------------------------------------------
/// DIO PROVIDER
/// ---------------------------------------------------------
final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: "https://api-location-plus.lamadonebenin.com/api",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        "Accept": "application/json",
      },
    ),
  );
});

/// ---------------------------------------------------------
/// API SERVICE PROVIDER
/// ---------------------------------------------------------
final apiServiceProvider = Provider<ApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiService(dio);
});

/// ---------------------------------------------------------
/// AUTH REPOSITORY PROVIDER
/// ---------------------------------------------------------
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final api = ref.watch(apiServiceProvider);
  return AuthRepository(api);
});

/// ---------------------------------------------------------
/// AUTH CONTROLLER PROVIDER
/// ---------------------------------------------------------
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthController(repo);
});
