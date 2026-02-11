// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mobile/data/models/bien_model.dart';
// import 'package:mobile/data/repositories/bien_repository.dart';
// import '../controllers/bien_controller.dart';

// /// ---------------------------------------------------------------------------
// /// REPOSITORY PROVIDER
// /// ---------------------------------------------------------------------------
// final bienRepositoryProvider = Provider<BienRepository>((ref) {
//   final api = ref.read(apiServiceProvider);
//   return BienRepository(api);
// });

// /// ---------------------------------------------------------------------------
// /// CONTROLLER PROVIDER (STATE NOTIFIER)
// /// ---------------------------------------------------------------------------
// /// L'état est AsyncValue<List<BienModel>> pour gérer loading, data et error
// final bienControllerProvider =
//     StateNotifierProvider<BienController, AsyncValue<List<BienModel>>>(
//   (ref) {
//     final repo = ref.read(bienRepositoryProvider);
//     return BienController(repo);
//   },
// );



import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/data/providers/auth_providers.dart';
import '../../data/repositories/bien_repository.dart';
import '../controllers/bien_controller.dart';

/// ---------------------------------------------------------------------------
/// REPOSITORY PROVIDER
/// ---------------------------------------------------------------------------
final bienRepositoryProvider = Provider<BienRepository>((ref) {
  final api = ref.read(apiServiceProvider);
  return BienRepository(api);
});

/// ---------------------------------------------------------------------------
/// CONTROLLER PROVIDER (STATE NOTIFIER)
/// ---------------------------------------------------------------------------
/// L'état est maintenant AsyncValue<List<dynamic>> pour gérer loading, data et error
final bienControllerProvider =
    StateNotifierProvider<BienController, AsyncValue<List<dynamic>>>(
  (ref) {
    final repo = ref.read(bienRepositoryProvider);
    return BienController(repo);
  },
);
