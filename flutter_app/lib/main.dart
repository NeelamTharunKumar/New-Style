import 'package:flutter/material.dart';

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
      title: 'BharatFit AI',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF09090B),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: Color(0xFF09090B),
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
      home: OnboardingGate(appState: appState),
      debugShowCheckedModeBanner: false,
    );
  }
}
