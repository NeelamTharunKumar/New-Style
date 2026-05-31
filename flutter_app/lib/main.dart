import 'package:flutter/material.dart';

import 'core/branding.dart';
import 'core/design_tokens.dart';
import 'data/bharatfit_api_client.dart';
import 'data/firebase_login_service.dart';
import 'data/local_store.dart';
import 'data/secure_auth_store.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'state/app_state.dart';

void main() {
  runApp(BharatFitApp(appState: AppState(BharatFitApiClient(), LocalStore(), SecureAuthStore(), FirebaseLoginService())));
}

class BharatFitApp extends StatelessWidget {
  const BharatFitApp({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppBranding.appName,
      theme: ThemeData.light(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
        ),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: ThemeData.light().textTheme.apply(
              bodyColor: AppColors.foreground,
              displayColor: AppColors.foreground,
              fontFamily: 'Manrope',
            ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.foreground,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.control)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.control),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.control),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.control)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.control)),
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.card)),
        ),
      ),
      home: OnboardingGate(appState: appState),
      debugShowCheckedModeBanner: false,
    );
  }
}
