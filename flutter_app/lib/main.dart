import 'package:flutter/material.dart';

import 'core/branding.dart';
import 'core/design_tokens.dart';
import 'data/drape_api_client.dart';
import 'data/firebase_login_service.dart';
import 'data/local_store.dart';
import 'data/secure_auth_store.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'state/app_state.dart';

void main() {
  runApp(DrapeApp(appState: AppState(DrapeApiClient(), LocalStore(), SecureAuthStore(), FirebaseLoginService())));
}

class DrapeApp extends StatefulWidget {
  const DrapeApp({super.key, required this.appState});

  final AppState appState;

  @override
  State<DrapeApp> createState() => _DrapeAppState();
}

class _DrapeAppState extends State<DrapeApp> {
  @override
  void initState() {
    super.initState();
    widget.appState.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    widget.appState.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() => setState(() {});

  // ── Theme builders ──────────────────────────────────────────
  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final palette = isDark ? DrapeColors.dark : DrapeColors.light;

    final base = isDark
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);

    return base.copyWith(
      extensions: [palette],
      colorScheme: ColorScheme.fromSeed(
        seedColor: palette.primary,
        brightness: brightness,
        primary: palette.primary,
        secondary: palette.secondary,
        surface: palette.surface,
      ),
      scaffoldBackgroundColor: palette.background,
      textTheme: base.textTheme.apply(
        bodyColor: palette.foreground,
        displayColor: palette.foreground,
        fontFamily: 'Manrope',
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: palette.background,
        foregroundColor: palette.foreground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.control)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
          borderSide: BorderSide(color: palette.primary, width: 1.6),
        ),
        labelStyle: TextStyle(color: palette.mutedForeground),
        hintStyle: TextStyle(color: palette.mutedForeground),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          backgroundColor: palette.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.control)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          foregroundColor: palette.primary,
          side: BorderSide(color: palette.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.control)),
        ),
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.card)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.surface,
        selectedColor: palette.primarySoft,
        side: BorderSide(color: palette.border),
        labelStyle: TextStyle(color: palette.foreground),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStatePropertyAll(palette.primary),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return palette.primary.withOpacity(0.4);
          }
          return palette.border;
        }),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: palette.surface,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.surface,
        contentTextStyle: TextStyle(color: palette.foreground),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: palette.mutedForeground,
        textColor: palette.foreground,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppBranding.appName,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: widget.appState.themeMode,
      home: OnboardingGate(appState: widget.appState),
      debugShowCheckedModeBanner: false,
    );
  }
}
