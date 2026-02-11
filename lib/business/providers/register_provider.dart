import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/data/providers/register_provider.dart';
import '../../data/repositories/register_repository.dart';
import '../../business/controllers/register_controller.dart';
import '../../business/states/register_state.dart';
import '../../data/services/api_service.dart';
import '../../data/providers/register_provider.dart';

/// ---------------------------------------------------------
/// REGISTER CONTROLLER PROVIDER
/// ---------------------------------------------------------
final registerControllerProvider =
    StateNotifierProvider<RegisterController, AsyncValue<void>>((ref) {
  final repo = ref.watch(registerRepositoryProvider);
  return RegisterController(repo, ref);
});


/// ---------------------------------------------------------
/// PROVIDER : CHARGER LES CATÉGORIES SELON LE TYPE
/// ---------------------------------------------------------
final registerCategoriesProvider =
    FutureProvider.family<List<dynamic>, String>((ref, String type) async {
  final controller = ref.watch(registerControllerProvider.notifier);

  final result = await controller.loadCategories(type);

  print("data: $result");

  // Retourne la liste s’il y a des données
  if (result is AsyncData<List<dynamic>>) {
    return result.value;
  }

  // En cas d’erreur → rethrow pour afficher l’erreur dans l’UI
  if (result is AsyncError) {
    throw result.error!;
  }

  // Par défaut
  return [];
});
