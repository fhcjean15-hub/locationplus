import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/data/models/bien_model.dart';
import '../../data/repositories/bien_repository.dart';

/// ---------------------------------------------------------------------------
/// STATE NOTIFIER POUR LES BIENS
/// ---------------------------------------------------------------------------
class BienController extends StateNotifier<AsyncValue<List<dynamic>>> {
  final BienRepository repository;

  BienController(this.repository) : super(const AsyncValue.loading()) {
    // fetchUserBiens();
  }

  // ---------------------------------------------------------------------------
  // FETCH USER BIENS
  // ---------------------------------------------------------------------------
  Future<void> fetchUserBiens() async {
    try {
      state = const AsyncValue.loading();

      final biensData = await repository.getUserBiens();

      // Transforme en List<BienModel>, sécurise la conversion
      final biens = biensData
          .map((json) => BienModel.fromJson(json as Map<String, dynamic>))
          .toList();

      state = AsyncValue.data(biens);
    } catch (e, st) {
      // Ne laisse jamais l'exception remonter
      state = AsyncValue.data([]); // renvoie liste vide en cas d'erreur
      print("❌ Erreur fetchUserBiens: $e");
    }
  }


    // ---------------------------------------------------------------------------
  // FETCH USER BIENS
  // ---------------------------------------------------------------------------
  Future<void> fetchCompanyBiens({required int id}) async {
    try {
      state = const AsyncValue.loading();

      final biensData = await repository.getCompanyBiens(
        id: id,
      );

      // Transforme en List<BienModel>, sécurise la conversion
      final biens = biensData
          .map((json) => BienModel.fromJson(json as Map<String, dynamic>))
          .toList();

      state = AsyncValue.data(biens);
    } catch (e, st) {
      // Ne laisse jamais l'exception remonter
      state = AsyncValue.data([]); // renvoie liste vide en cas d'erreur
      print("❌ Erreur fetchUserBiens: $e");
    }
  }

  // ---------------------------------------------------------------------------
  // CREATE BIEN
  // ---------------------------------------------------------------------------
  Future<bool> createBien({
    required String category,
    required String transactionType,
    required String title,
    required String description,
    required double price,
    required String city,
    required Map<String, dynamic> attributes,
    List<XFile>? images,
  }) async {
    try {
      // état temporaire de chargement
      state = AsyncValue.loading();

      await repository.createBien(
        category: category,
        transactionType: transactionType,
        title: title,
        description: description,
        price: price,
        city: city,
        attributes: attributes,
        images: images,
      );

      await fetchUserBiens();
      return true;
    } catch (e) {
      print("❌ Erreur création bien: $e");
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // UPDATE BIEN
  // ---------------------------------------------------------------------------
  Future<bool> updateBien({
    required int id,
    required String title,
    required String description,
    required double price,
    required String city,
    required Map<String, dynamic> attributes,
    List<XFile>? newImages, // nouvelles images à uploader
    List<String>? keepImages, // images existantes à conserver
  }) async {
    try {
      state = const AsyncValue.loading();

      await repository.updateBien(
        id: id,
        title: title,
        description: description,
        price: price,
        city: city,
        attributes: attributes,
        newImages: newImages,
        keepImages: keepImages,
      );

      await fetchUserBiens();
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      print("❌ Erreur update bien: $e");
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // DELETE BIEN
  // ---------------------------------------------------------------------------
  Future<bool> deleteBien(int id) async {
    try {
      state = AsyncValue.loading(); // déclenche le loading
      final success = await repository.deleteBien(id);

      if (success) {
        // Recharge les biens après suppression
        final biens = await repository.getUserBiens();
        state = AsyncValue.data(biens); // <- met à jour le state avec les biens
      }
      print("$success");
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<void> fetchAllUserBiens() async {
    try {
      state = const AsyncLoading();
      final biens = await repository.getAllUserBiens();
      state = AsyncData(biens);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> fetchAllBiensPublic() async {
    try {
      state = const AsyncLoading();
      final biens = await repository.getAllBiensPublic();
      state = AsyncData(biens);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> toggleBienActivation({
    required int id,
    required bool actif,
  }) async {
    try {
      await repository.toggleBienActivation(id: id, actif: actif);
      await fetchAllUserBiens(); // 🔥 refresh auto
    } catch (e) {
      print("❌ Erreur toggle actif: $e");
    }
  }

  


}
