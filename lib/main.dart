import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/business/providers/auth_controller_provider.dart';
import 'package:mobile/presentation/theme/colors.dart';

import 'core/config/app_router.dart';
import 'core/config/dio_client.dart';
import 'package:syncfusion_flutter_core/core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();

  // 🔥 Charger la session AVANT l'affichage
  await container.read(authControllerProvider.notifier).initialize();

  // SyncfusionLicense.registerLicense("LICENCE_GRATUITE_ICI");

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Africa Location',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,

      // ===================== THEME GLOBAL =====================
      theme: ThemeData(
        useMaterial3: true,

        primaryColor: AppColors.primary,

        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondaryBlue,
        ),

        scaffoldBackgroundColor: Colors.white,

        // ---------------- AppBar ----------------
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textDark,
          elevation: 0,
        ),

        // ---------------- Inputs ----------------
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 1.5,
            ),
          ),
          labelStyle: const TextStyle(color: AppColors.textDark),
        ),

        // ---------------- Curseur / sélection texte ----------------
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColors.primary,
          selectionColor: AppColors.primary.withOpacity(0.3),
          selectionHandleColor: AppColors.primary,
        ),

        // ---------------- Boutons ----------------
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        // ---------------- Checkbox / Switch / Radio ----------------
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.all(AppColors.primary),
          checkColor: WidgetStateProperty.all(Colors.white),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.all(AppColors.primary),
          trackColor: WidgetStateProperty.all(
            AppColors.primary.withOpacity(0.4),
          ),
        ),
        radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.all(AppColors.primary),
        ),

        // ---------------- DatePicker ----------------
        datePickerTheme: DatePickerThemeData(
          backgroundColor: Colors.white,
          headerBackgroundColor: AppColors.primary,
          headerForegroundColor: Colors.white,
          todayForegroundColor:
              WidgetStateProperty.all(AppColors.primary),
          todayBorder:
              const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}






// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mobile/business/providers/auth_controller_provider.dart';

// import 'core/config/app_router.dart';
// import 'core/config/dio_client.dart'; // 🔥 assure-toi de pointer vers ton dio_client.dart
// import 'package:syncfusion_flutter_core/core.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // 🔥 Charge le CSRF cookie / XSRF-TOKEN de Sanctum AVANT de lancer l'app
//   await DioClient().init();

//   final container = ProviderContainer();

//   // 🔥 CHARGER LA SESSION AVANT L'AFFICHAGE
//   await container.read(authControllerProvider.notifier).initialize();

//   // SyncfusionLicense.registerLicense("LICENCE_GRATUITE_ICI");
  
//   // 🔥 3) Lancer l'app AVEC ce container
//   runApp(
//     UncontrolledProviderScope(
//       container: container,
//       child: const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp.router(
//       title: 'Africa Location',
//       debugShowCheckedModeBanner: false,
//       routerConfig: appRouter,
//     );
//   }
// }
