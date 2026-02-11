import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/presentation/screens/auth/utilisateurs/profile/profile_screen.dart';

import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/listings/listing_detail_screen.dart';
import '../../presentation/screens/dashboard/user_dashboard_screen.dart';
import '../../presentation/screens/dashboard/admin_dashboard_screen.dart';
import '../../presentation/screens/payment/activation_payment_screen.dart';
import '../../presentation/screens/notifications/notifications_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: "/splash",

  // IMPORTANT : empêche GoRouter d'appeler plusieurs fois un builder
  debugLogDiagnostics: false,

  routes: [

    // ===============================
    // SPLASH
    // ===============================
    GoRoute(
      path: "/splash",
      builder: (context, state) => const SplashScreen(),
    ),

    // ===============================
    // ONBOARDING
    // ===============================
    GoRoute(
      path: "/onboarding",
      builder: (context, state) => const OnboardingScreen(),
    ),

    // ===============================
    // HOME
    // ===============================
    GoRoute(
      path: "/home",
      builder: (context, state) => const HomeScreen(),
    ),

    // ===============================
    // AUTH
    // ===============================
    GoRoute(
      path: "/login",
      builder: (context, state) => const LoginScreen(),
    ),

    GoRoute(
      path: "/register",
      builder: (context, state) => const RegisterScreen(),
    ),

    GoRoute(
      path: "/forgot-password",
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    // ===============================
    // LISTING DETAILS
    // ===============================
    GoRoute(
      path: "/listing/:id",
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ListingDetailScreen(listingId: id);
      },
    ),

    // ===============================
    // USER DASHBOARD
    // ===============================
    GoRoute(
      path: "/dashboard",
      builder: (context, state) => const UserDashboardScreen(),
    ),

    // ===============================
    // ADMIN DASHBOARD
    // ===============================
    GoRoute(
      path: "/admin/dashboard",
      builder: (context, state) => const AdminDashboardScreen(),
    ),

    // ===============================
    // PAYMENT
    // ===============================
    GoRoute(
      path: "/payment/activation",
      builder: (context, state) => const ActivationPaymentScreen(),
    ),

    // ===============================
    // NOTIFICATIONS
    // ===============================
    GoRoute(
      path: "/notifications",
      builder: (context, state) => const NotificationsScreen(),
    ),

    GoRoute(
      path: "/profile",
      builder: (context, state) => const ProfileScreen(),
    ),

  ],
);
