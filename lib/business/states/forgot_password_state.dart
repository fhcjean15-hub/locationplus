import 'package:equatable/equatable.dart';

class ForgotPasswordState extends Equatable {
  final bool isLoading;
  final String? error;

  final String? email;          // Email de l’utilisateur
  final bool emailSent;         // Étape 1 réussie : email envoyé
  final String? code;           // 👈 Code OTP validé et stocké
  final bool codeVerified;      // Étape 2 réussie : OTP validé
  final bool passwordReset;     // Étape 3 réussie : mot de passe changé

  const ForgotPasswordState({
    required this.isLoading,
    required this.error,
    required this.email,
    required this.emailSent,
    required this.code,
    required this.codeVerified,
    required this.passwordReset,
  });

  // 🔥 État initial
  factory ForgotPasswordState.initial() {
    return const ForgotPasswordState(
      isLoading: false,
      error: null,
      email: null,
      emailSent: false,
      code: null,              // 👈 ajouté
      codeVerified: false,
      passwordReset: false,
    );
  }

  // 🔥 copyWith sécurisé
  ForgotPasswordState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? email,
    bool? emailSent,
    String? code,             // 👈 ajouté
    bool? codeVerified,
    bool? passwordReset,
  }) {
    return ForgotPasswordState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      email: email ?? this.email,
      emailSent: emailSent ?? this.emailSent,
      code: code ?? this.code,        // 👈 ajouté
      codeVerified: codeVerified ?? this.codeVerified,
      passwordReset: passwordReset ?? this.passwordReset,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        email,
        emailSent,
        code,           // 👈 ajouté
        codeVerified,
        passwordReset,
      ];
}






// import 'package:equatable/equatable.dart';
// import '../states/forgot/forgot_step.dart';

// class ForgotPasswordState extends Equatable {
//   final bool isLoading;
//   final String? error;

//   final String? email;
//   final bool emailSent;
//   final bool codeVerified;
//   final bool passwordReset;

//   final ForgotStep step;

//   const ForgotPasswordState({
//     required this.isLoading,
//     required this.error,
//     required this.email,
//     required this.emailSent,
//     required this.codeVerified,
//     required this.passwordReset,
//     required this.step,
//   });

//   factory ForgotPasswordState.initial() {
//     return const ForgotPasswordState(
//       isLoading: false,
//       error: null,
//       email: null,
//       emailSent: false,
//       codeVerified: false,
//       passwordReset: false,
//       step: ForgotStep.email,
//     );
//   }

//   ForgotPasswordState copyWith({
//     bool? isLoading,
//     String? error,
//     bool clearError = false,
//     String? email,
//     bool? emailSent,
//     bool? codeVerified,
//     bool? passwordReset,
//     ForgotStep? step,
//   }) {
//     return ForgotPasswordState(
//       isLoading: isLoading ?? this.isLoading,
//       error: clearError ? null : error ?? this.error,
//       email: email ?? this.email,
//       emailSent: emailSent ?? this.emailSent,
//       codeVerified: codeVerified ?? this.codeVerified,
//       passwordReset: passwordReset ?? this.passwordReset,
//       step: step ?? this.step,
//     );
//   }

//   @override
//   List<Object?> get props =>
//       [isLoading, error, email, emailSent, codeVerified, passwordReset, step];
// }


