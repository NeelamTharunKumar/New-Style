import 'package:flutter/material.dart';

import '../../core/design_tokens.dart';

import '../../data/secure_auth_store.dart';
import '../../state/app_state.dart';
import '../widgets/status_banner.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _apiKeyController;
  late final TextEditingController _userIdController;
  late final TextEditingController _tokenController;
  String _mode = 'dev_bearer';

  @override
  void initState() {
    super.initState();
    final creds = widget.appState.authCredentials;
    _apiKeyController = TextEditingController(text: creds.apiKey);
    _userIdController = TextEditingController(text: creds.userId.isNotEmpty ? creds.userId : widget.appState.userId);
    _tokenController = TextEditingController(text: creds.authMode == 'static_bearer' ? creds.authToken : '');
    _mode = creds.authMode == 'static_bearer' ? 'static_bearer' : 'dev_bearer';
    widget.appState.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.appState.removeListener(_refresh);
    _apiKeyController.dispose();
    _userIdController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  Future<void> _login() async {
    if (_mode == 'dev_bearer') {
      await widget.appState.loginWithDevUser(userId: _userIdController.text, apiKey: _apiKeyController.text);
      return;
    }
    if (_mode == 'firebase') {
      await widget.appState.loginWithFirebaseAnonymously(apiKey: _apiKeyController.text);
      return;
    }
    await widget.appState.saveAuthCredentials(
      AuthCredentials(
        apiKey: _apiKeyController.text.trim(),
        authToken: _tokenController.text.trim(),
        authMode: 'static_bearer',
        userId: _userIdController.text.trim(),
      ),
      updateProfileUserId: _userIdController.text.trim().isNotEmpty,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;
    return Scaffold(
      appBar: AppBar(title: const Text('Login & Secure Token Storage')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          StatusBanner(error: state.error, message: state.statusMessage, isBusy: state.isBusy),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Secure local login', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(
                  'Tokens are stored with flutter_secure_storage. For production, replace dev/static tokens with Firebase/Auth0/Supabase login.',
                  style: TextStyle(color: AppColors.mutedForeground, height: 1.4),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _mode,
                  decoration: const InputDecoration(labelText: 'Login mode', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'dev_bearer', child: Text('Dev bearer: dev:<user_id>')),
                    DropdownMenuItem(value: 'static_bearer', child: Text('Static bearer token')),
                    DropdownMenuItem(value: 'firebase', child: Text('Firebase anonymous sign-in')),
                  ],
                  onChanged: (value) => setState(() => _mode = value ?? 'dev_bearer'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _userIdController,
                  decoration: const InputDecoration(
                    labelText: 'User ID',
                    hintText: _mode == 'firebase' ? 'Firebase UID is filled after login' : 'demo_user',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                if (_mode == 'firebase') ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Firebase mode requires replacing flutter_app/lib/firebase_options.dart with FlutterFire config and backend BHARATFIT_AUTH_MODE=firebase.',
                        style: TextStyle(color: Colors.orange.shade200),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (_mode == 'static_bearer') ...[
                  TextField(
                    controller: _tokenController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Bearer token',
                      helperText: 'For backend BHARATFIT_AUTH_MODE=static_bearer',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: _apiKeyController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'API key (optional)',
                    helperText: 'Only needed if backend BHARATFIT_API_KEY is set',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Current secure session', style: TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        Text('Mode: ${state.authCredentials.authMode}'),
                        Text('User: ${state.authCredentials.userId.isEmpty ? state.userId : state.authCredentials.userId}'),
                        Text('Bearer token saved: ${state.authCredentials.hasBearerToken ? 'yes' : 'no'}'),
                        Text('API key saved: ${state.authCredentials.hasApiKey ? 'yes' : 'no'}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: state.isBusy ? null : _login,
                    icon: const Icon(Icons.login),
                    label: Text(_mode == 'firebase' ? 'Sign in with Firebase' : 'Save login securely'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: state.isBusy ? null : state.logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout / clear secure tokens'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
