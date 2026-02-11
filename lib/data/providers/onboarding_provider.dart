import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../business/controllers/onboarding_controller.dart';
import '../../business/states/onboarding_state.dart';

final onboardingProvider =
    StateNotifierProvider<OnboardingController, OnboardingState>(
  (ref) => OnboardingController(),
);
