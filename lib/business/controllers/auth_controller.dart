import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/local_storage_service.dart';
import '../states/auth_state.dart';
import 'dart:io';

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository repo;

  AuthController(this.repo) : super(AuthState.initial());

  // =====================================================
  // INIT AU DEMARRAGE
  // =====================================================
  Future<void> initialize() async {
    final token = await LocalStorageService.instance.getToken();

    if (token == null) {
      state = state.copyWith(initialized: true, user: null, token: null);
      return;
    }

    try {
      final userJson = await repo.getCurrentUser();
      if (userJson == null) throw Exception("Utilisateur introuvable");

      final user = User.fromJson(userJson);
      state = state.copyWith(initialized: true, token: token, user: user);
    } catch (e) {
      await LocalStorageService.instance.clearToken();
      state = state.copyWith(initialized: true, user: null, token: null);
    }
  }

  Future<void> refreshUser() async {
    try {
      final userJson = await repo.getCurrentUser();
      if (userJson == null) throw Exception("Utilisateur introuvable");

      final user = User.fromJson(userJson);

      state = state.copyWith(user: user);
    } catch (e) {
      print("Erreur refreshUser: $e");
    }
  }
  
  // =====================================================
  // LOAD ACCOUNT CATEGORY
  // =====================================================
  Future<Map<String, dynamic>?> loadAccountCategory(int? id) async {
    if (id == null) return null;

    try {
      final data = await repo.getAccountCategory(id);
      return data; // contient 'id', 'name', 'price', etc.
    } catch (e) {
      print("Erreur récupération catégorie: $e");
      return null;
    }
  }



  // =====================================================
  // LOGIN
  // =====================================================
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await repo.login(email, password);
      final token = result["token"];
      final userData = result["data"];

      if (token == null || userData == null) {
        throw Exception("Réponse invalide du serveur");
      }

      final user = User.fromJson(userData);
      await _saveAuthData({"token": token, "data": userData});

      return true;
    } catch (e) {
      String errorMessage = "Erreur inconnue";

      if (e is DioException) {
        if (e.response?.data is Map) {
          final data = e.response!.data;
          if (data["message"] != null) {
            errorMessage = data["message"];
          } else if (data["errors"] != null) {
            errorMessage = data["errors"].toString();
          }
        } else {
          errorMessage = e.message ?? "Erreur réseau";
        }
      } else {
        errorMessage = e.toString();
      }

      print("AUTH ERROR → $errorMessage");
      state = state.copyWith(isLoading: false, error: errorMessage);

      return false;
    }
  }

  // =====================================================
  // GET ALL USERS FOR ADMIN
  // =====================================================
  Future<void> fetchAllUsers() async {
    // On démarre le chargement
    state = state.copyWith(isUsersLoading: true, error: null);

    try {
      final list = await repo.getAllUsers();

      // Convertir JSON → User model
      final users = list.map((json) => User.fromJson(json)).toList();

      // Mise à jour de l’état
      state = state.copyWith(
        adminUsers: users,
        isUsersLoading: false,
        error: null,
      );
    } catch (e, stack) {
      // Optionnel : tu peux logger l’erreur
      // print("Fetch users error: $e\n$stack");

      state = state.copyWith(isUsersLoading: false, error: e.toString());
    }
  }

  // ------------------------------------------------------------
  // CREATE USER (ADMIN)
  // ------------------------------------------------------------
  Future<bool> createUser({
    required String email,
    required String accountType,
    required String password,
  }) async {
    try {
      state = state.copyWith(isUsersLoading: true, error: null);

      final newUser = await repo.createUser(
        email: email,
        accountType: accountType,
        password: password,
      );

      state = state.copyWith(
        adminUsers: [newUser, ...state.adminUsers],
        isUsersLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(isUsersLoading: false, error: e.toString());
      return false;
    }
  }

  // =====================================================
  // SAVE TOKEN + USER
  // =====================================================
  Future<void> _saveAuthData(Map<String, dynamic> result) async {
    final token = result["token"];
    final userData = result["data"];

    if (token == null || userData == null) {
      state = state.copyWith(
        isLoading: false,
        error: "Réponse du serveur invalide",
        initialized: true,
      );
      return;
    }

    final user = User.fromJson(userData);
    await LocalStorageService.instance.saveToken(token);

    state = state.copyWith(
      isLoading: false,
      user: user,
      token: token,
      error: null,
      initialized: true,
    );
  }

  // inside AuthController class

  Future<bool> updateProfile({
    String? fullName,
    String? email,
    String? phone,
    String? companyName,
    String? ifu,
    String? adresse,
    String? ville,
    String? accountCategoryId,
    File? avatarUrl,
    List<File>? documentsFiles,
    String? currentPassword,
    String? password,
    String? userId,
    bool? activated,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final userId = state.user?.id;
    if (userId == null) {
      state = state.copyWith(
        isLoading: false,
        error: "Utilisateur introuvable",
      );
      return false;
    }

    try {
      // Appel repository avec tous les champs attendus
      final result = await repo.updateProfile(
        userId: userId,
        fullName: fullName,
        email: email,
        phone: phone,
        companyName: companyName,
        ifu: ifu,
        adresse: adresse,
        ville: ville,
        accountCategoryId: accountCategoryId,
        avatarFile: avatarUrl,
        documentsFiles: documentsFiles,
        currentPassword: currentPassword,
        password: password,
        activated: activated,
      );

      final updatedUser = User.fromJson(result['data']);

      state = state.copyWith(
        isLoading: false,
        user: updatedUser,
        error: null,
        initialized: true,
      );

      return true;
    } on DioException catch (e) {
      final err = e.response?.data?["message"] ?? e.message ?? "Erreur réseau";

      state = state.copyWith(isLoading: false, error: err);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }


  Future<void> updatePaymentStatus({required String param}) async {
    try {
      final newStatus = await repo.updatePaymentStatus(payParams: param);

      final currentUser = state.user;
      if (currentUser == null) return;

      final updatedUser = currentUser.copyWith(
        paymentStatus: newStatus,
      );

      state = state.copyWith(user: updatedUser);
    } catch (e) {
      print("❌ Erreur updatePaymentStatus: $e");
    }
  }


  /// Crée une notification
  Future<bool> postNotification({
    required String userId,
    required String type,
    Map<String, dynamic>? payload,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await repo.postNotification(
        userId: userId,
        type: type,
        payload: payload,
      );

      // ⚡ Si type = compte_validé ou compte_rejeté, mettre à jour verifiedDocuments
      final notificationData = result['data'];
      if (type == "compte_validé" || type == "compte_rejeté") {
        final verified = type == "compte_validé";
        final updatedUser = state.user?.copyWith(verifiedDocuments: verified);
        state = state.copyWith(user: updatedUser);
      }

      state = state.copyWith(isLoading: false, error: null);
      return true;
    } on DioException catch (e) {
      final err = e.response?.data?["message"] ?? e.message ?? "Erreur réseau";
      state = state.copyWith(isLoading: false, error: err);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateNotification({
    required String notificationId,
    String? type,
    Map<String, dynamic>? payload,
    bool? read,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await repo.updateNotification(
        notificationId: notificationId,
        type: type,
        payload: payload,
        read: read,
      );

      // ⚡ Tu peux mettre à jour le state si nécessaire
      // Par exemple, si tu stockes la dernière notification de vérification
      if (type == 'compte_validé' || type == 'compte_rejeté') {
        state = state.copyWith(
          lastVerificationNotification: result,
          hasVerification: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> loadVerificationStatus(String userId) async {
    state = state.copyWith(isLoading: true);

    try {
      final result = await repo.getLastVerificationNotification(userId);

      state = state.copyWith(
        lastVerificationNotification: result["data"],
        hasVerification: result["hasVerification"],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<bool> toggleUserActivation({
    required String userId,
    required bool activated,
  }) async {
    try {
      await repo.toggleUserActivation(
        id: userId,
        activated: activated,
      );

      fetchAllUsers();

      return true;
    } catch (e) {
      print("❌ Erreur toggle activated: $e");
      return false;
    }
  }

  // =====================================================
  // LOGOUT AVANCÉ
  // =====================================================
  Future<void> logout() async {
    try {
      // Optionnel : informer le serveur
      await repo.logout();
    } catch (_) {
      // Erreurs réseau ignorées
    }

    // 1️⃣ Supprimer token local
    await LocalStorageService.instance.clearToken();

    // 2️⃣ Réinitialiser le state
    state = AuthState.initial().copyWith(initialized: true);

    // 3️⃣ 🔹 Optionnel : notifier d'autres providers si nécessaire
    // ref.read(favorisProvider.notifier).reset();
    // ref.read(reservationsProvider.notifier).reset();

    print("Utilisateur déconnecté avec succès.");
  }

  // =====================================================
  // ACCOUNT STATUS
  // =====================================================
  AccountStatus get accountStatus {
    final user = state.user;

    if (user == null) return AccountStatus.guest;
    if (!user.verifiedDocuments) return AccountStatus.waitingValidation;
    if (user.paymentStatus == "pending") return AccountStatus.waitingPayment;
    if (user.activated && user.paymentStatus == "paid")
      return AccountStatus.active;

    return AccountStatus.guest;
  }
}
