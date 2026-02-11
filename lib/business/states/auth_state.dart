import '../../data/models/user_model.dart';

enum AccountStatus {
  guest,
  waitingValidation,
  waitingPayment,
  active,
}

class AuthState {
  final bool initialized;
  final bool isLoading;
  final String? error;
  final User? user;
  final String? token;

  // 🔥 Ajout pour la gestion admin
  final List<User> adminUsers;
  final bool isUsersLoading;

  // 🔥 Ajout pour la gestion des notifications de validation
  final Map<String, dynamic>? lastVerificationNotification;
  final bool hasVerification;

  const AuthState({
    this.initialized = false,
    this.isLoading = false,
    this.error,
    this.user,
    this.token,

    // ⚠️ Toujours initialiser ici
    this.adminUsers = const [],
    this.isUsersLoading = false,

    // 🔥 Notifications
    this.lastVerificationNotification,
    this.hasVerification = false,
  });

  // 🔥 État initial complet
  factory AuthState.initial() => const AuthState(
        initialized: false,
        isLoading: false,
        error: null,
        user: null,
        token: null,

        adminUsers: [],
        isUsersLoading: false,

        lastVerificationNotification: null,
        hasVerification: false,
      );

  // 🔥 copyWith mis à jour
  AuthState copyWith({
    bool? initialized,
    bool? isLoading,
    String? error,
    User? user,
    String? token,
    List<User>? adminUsers,
    bool? isUsersLoading,
    Map<String, dynamic>? lastVerificationNotification,
    bool? hasVerification,
  }) {
    return AuthState(
      initialized: initialized ?? this.initialized,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      user: user ?? this.user,
      token: token ?? this.token,
      adminUsers: adminUsers ?? this.adminUsers,
      isUsersLoading: isUsersLoading ?? this.isUsersLoading,
      lastVerificationNotification:
          lastVerificationNotification ?? this.lastVerificationNotification,
      hasVerification: hasVerification ?? this.hasVerification,
    );
  }

  // 🔥 clearError reste propre
  AuthState clearError() {
    return copyWith(error: null);
  }

  @override
  String toString() {
    return "AuthState("
        "initialized: $initialized, "
        "loading: $isLoading, "
        "user: $user, "
        "token: $token, "
        "adminUsers: ${adminUsers.length} users, "
        "isUsersLoading: $isUsersLoading, "
        "lastVerificationNotification: $lastVerificationNotification, "
        "hasVerification: $hasVerification, "
        "error: $error"
        ")";
  }
}





// import '../../data/models/user_model.dart';

// enum AccountStatus {
//   guest,
//   waitingValidation,
//   waitingPayment,
//   active,
// }

// class AuthState {
//   final bool initialized;
//   final bool isLoading;
//   final String? error;
//   final User? user;
//   final String? token;

//   // 🔥 Ajout pour la gestion admin
//   final List<User> adminUsers;
//   final bool isUsersLoading;

//   // 🔥 Ajout pour la gestion des notifications de validation
//   final Map<String, dynamic>? lastVerificationNotification;
//   final bool hasVerification;

//   const AuthState({
//     this.initialized = false,
//     this.isLoading = false,
//     this.error,
//     this.user,
//     this.token,

//     // ⚠️ Toujours initialiser ici
//     this.adminUsers = const [],
//     this.isUsersLoading = false,

//     // 🔥 Notifications
//     this.lastVerificationNotification,
//     this.hasVerification = false,
//   });

//   // 🔥 État initial complet
//   factory AuthState.initial() => const AuthState(
//         initialized: false,
//         isLoading: false,
//         error: null,
//         user: null,
//         token: null,

//         adminUsers: [],
//         isUsersLoading: false,

//         lastVerificationNotification: null,
//         hasVerification: false,
//       );

//   // 🔥 copyWith mis à jour
//   AuthState copyWith({
//     bool? initialized,
//     bool? isLoading,
//     String? error,
//     User? user,
//     String? token,
//     List<User>? adminUsers,
//     bool? isUsersLoading,
//     Map<String, dynamic>? lastVerificationNotification,
//     bool? hasVerification,
//   }) {
//     return AuthState(
//       initialized: initialized ?? this.initialized,
//       isLoading: isLoading ?? this.isLoading,
//       error: error ?? this.error,
//       user: user ?? this.user,
//       token: token ?? this.token,
//       adminUsers: adminUsers ?? this.adminUsers,
//       isUsersLoading: isUsersLoading ?? this.isUsersLoading,
//       lastVerificationNotification:
//           lastVerificationNotification ?? this.lastVerificationNotification,
//       hasVerification: hasVerification ?? this.hasVerification,
//     );
//   }

//   // 🔥 clearError reste propre
//   AuthState clearError() {
//     return copyWith(error: null);
//   }

//   @override
//   String toString() {
//     return "AuthState("
//         "initialized: $initialized, "
//         "loading: $isLoading, "
//         "user: $user, "
//         "token: $token, "
//         "adminUsers: ${adminUsers.length} users, "
//         "isUsersLoading: $isUsersLoading, "
//         "lastVerificationNotification: $lastVerificationNotification, "
//         "hasVerification: $hasVerification, "
//         "error: $error"
//         ")";
//   }
// }
