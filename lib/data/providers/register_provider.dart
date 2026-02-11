import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:mobile/data/providers/api_providers.dart';
import '../../data/services/api_service.dart';
import '../repositories/register_repository.dart';

final registerRepositoryProvider = Provider<RegisterRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return RegisterRepository(dio);
});
