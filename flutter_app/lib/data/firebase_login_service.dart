import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';

class FirebaseLoginResult {
  const FirebaseLoginResult({required this.userId, required this.idToken, this.email});

  final String userId;
  final String idToken;
  final String? email;
}

class FirebaseLoginService {
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    _initialized = true;
  }

  Future<FirebaseLoginResult> signInAnonymously() async {
    await initialize();
    final credential = await FirebaseAuth.instance.signInAnonymously();
    final user = credential.user;
    if (user == null) throw StateError('Firebase did not return a user');
    final token = await user.getIdToken();
    if (token == null || token.isEmpty) throw StateError('Firebase did not return an ID token');
    return FirebaseLoginResult(userId: user.uid, idToken: token, email: user.email);
  }

  Future<FirebaseLoginResult?> currentSession() async {
    await initialize();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final token = await user.getIdToken();
    if (token == null || token.isEmpty) return null;
    return FirebaseLoginResult(userId: user.uid, idToken: token, email: user.email);
  }

  Future<void> signOut() async {
    await initialize();
    await FirebaseAuth.instance.signOut();
  }
}
