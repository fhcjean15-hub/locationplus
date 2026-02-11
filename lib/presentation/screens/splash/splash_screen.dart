import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/providers/onboarding_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await Future.delayed(const Duration(seconds: 2)); // petite animation

    final onboardingController = ref.read(onboardingProvider.notifier);

    // Charger l’onboarding depuis le storage
    await onboardingController.loadFromStorage();

    final onboardingState = ref.read(onboardingProvider);

    // 🚀 1️⃣ SI ONBOARDING PAS TERMINÉ → ONBOARDING
    if (!onboardingState.isCompleted) {
      context.go("/onboarding");
      return;
    }

    // 🚀 2️⃣ ONBOARDING TERMINÉ → HOME DIRECTEMENT
    context.go("/home");
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image(
          image: AssetImage("assets/images/africalocation_logo.png"),
          width: 160,
        ),
      ),
    );
  }
}
