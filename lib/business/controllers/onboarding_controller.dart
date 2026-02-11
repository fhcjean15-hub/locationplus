import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../states/onboarding_state.dart';

class OnboardingController extends StateNotifier<OnboardingState> {
  OnboardingController() : super(OnboardingState.initial()) {
    loadFromStorage();
  }

  /// Charge depuis SharedPreferences si l'onboarding a déjà été complété
  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool("onboarding_completed") ?? false;

    state = OnboardingState.fromSaved(completed);
  }

  /// Met à jour la page active du slider d'onboarding
  void updatePage(int index) {
    state = state.copyWith(currentPage: index);
  }

  /// Marque l'onboarding comme terminé définitivement
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("onboarding_completed", true);

    state = state.copyWith(isCompleted: true);
  }
}
