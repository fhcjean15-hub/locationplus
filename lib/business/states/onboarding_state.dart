import 'package:equatable/equatable.dart';

class OnboardingState extends Equatable {
  final int currentPage;
  final bool isCompleted;

  const OnboardingState({
    this.currentPage = 0,
    this.isCompleted = false,
  });

  // --------- Constructeur initial ----------
  factory OnboardingState.initial() {
    return const OnboardingState(
      currentPage: 0,
      isCompleted: false,
    );
  }

  // --------- Depuis stockage local ----------
  factory OnboardingState.fromSaved(bool completed) {
    return OnboardingState(
      currentPage: 0,
      isCompleted: completed,
    );
  }

  OnboardingState copyWith({
    int? currentPage,
    bool? isCompleted,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [currentPage, isCompleted];
}
