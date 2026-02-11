import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/register_repository.dart';
import '../providers/auth_controller_provider.dart';

class RegisterController extends StateNotifier<AsyncValue<void>> {
  final RegisterRepository repo;
  final Ref ref;

  RegisterController(this.repo, this.ref) : super(const AsyncData(null));

  // =====================================================
  // 1️⃣ CHARGER LES CATÉGORIES SELON LE TYPE
  // =====================================================
  Future<AsyncValue<List<dynamic>>> loadCategories(String type) async {
    try {
      final categories = await repo.getCategories(type);
      return AsyncData(categories);
    } catch (e, st) {
      return AsyncError(e, st);
    }
  }

  // =====================================================
  // 2️⃣ INSCRIPTION AGENT INDÉPENDANT
  // =====================================================
  Future<bool> registerAgent(Map<String, dynamic> data) async {
    state = const AsyncLoading();

    try {
      // 1) APPEL API
      await repo.registerAgent(data);

      // 2) LOGIN AUTO
      final success = await _autoLogin(data);

      if (!success) {
        state = AsyncError(
          "Compte créé mais login automatique impossible",
          StackTrace.current,
        );
        return false;
      }

      state = const AsyncData(null);
      return true;

    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  // =====================================================
  // 3️⃣ INSCRIPTION AGENCE
  // =====================================================
  Future<bool> registerAgence(Map<String, dynamic> data) async {
    state = const AsyncLoading();

    try {
      // 1) APPEL API
      await repo.registerAgence(data);

      // 2) LOGIN AUTO
      final success = await _autoLogin(data);

      if (!success) {
        state = AsyncError(
          "Compte créé mais login automatique impossible",
          StackTrace.current,
        );
        return false;
      }

      state = const AsyncData(null);
      return true;

    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  // =====================================================
  // 4️⃣ LOGIN AUTOMATIQUE APRÈS INSCRIPTION
  // =====================================================
  Future<bool> _autoLogin(Map<String, dynamic> data) async {
    final email = data["email"];
    final password = data["password"];

    if (email == null || password == null) {
      return false;
    }

    final auth = ref.read(authControllerProvider.notifier);
    return await auth.login(email, password);
  }
}
