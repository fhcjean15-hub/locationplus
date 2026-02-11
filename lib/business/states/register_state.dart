import 'package:equatable/equatable.dart';

class RegisterState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<dynamic> categories;

  const RegisterState({
    this.isLoading = false,
    this.error,
    this.categories = const [],
  });

  RegisterState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    List<dynamic>? categories,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      categories: categories ?? this.categories,
    );
  }

  @override
  List<Object?> get props => [isLoading, error, categories];
}
