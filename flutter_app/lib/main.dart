import 'package:flutter/material.dart';

import 'data/bharatfit_api_client.dart';
import 'data/firebase_login_service.dart';
import 'data/local_store.dart';
import 'data/secure_auth_store.dart';
import 'presentation/screens/home_dashboard.dart';
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
      ),
      home: HomeDashboard(appState: appState),
      debugShowCheckedModeBanner: false,
    );
  }
}
