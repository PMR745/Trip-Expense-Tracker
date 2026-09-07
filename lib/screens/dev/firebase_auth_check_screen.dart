import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:trip_expense_tracker/main.dart' show firebaseInitError;

/// Temporary verification screen for TET-37.
///
/// Its only job is to prove that Firebase initialises and that both sign-in
/// providers return a uid. It is deliberately ugly and has no place in the
/// finished app — TET-39 replaces it with the real sign-in screen and this
/// file, along with the entry point that reaches it, should be deleted then.
class FirebaseAuthCheckScreen extends StatefulWidget {
  const FirebaseAuthCheckScreen({super.key});

  @override
  State<FirebaseAuthCheckScreen> createState() =>
      _FirebaseAuthCheckScreenState();
}

class _FirebaseAuthCheckScreenState extends State<FirebaseAuthCheckScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _busy = false;
  String? _error;
  bool _googleInitialised = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Runs [action] with the busy flag set and any failure captured for display.
  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signUpWithEmail() => _run(() async {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      });

  Future<void> _signInWithEmail() => _run(() async {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      });

  Future<void> _signInWithGoogle() => _run(() async {
        // google_sign_in 7.x requires initialize() once before authenticate().
        // On Android the server client id comes from google-services.json via
        // the generated default_web_client_id resource.
        if (!_googleInitialised) {
          await GoogleSignIn.instance.initialize();
          _googleInitialised = true;
        }

        final GoogleSignInAccount account =
            await GoogleSignIn.instance.authenticate();

        // 7.x exposes only an idToken — there is no accessToken any more.
        final String? idToken = account.authentication.idToken;
        if (idToken == null) {
          throw StateError(
            'Google sign-in returned no idToken. This usually means the '
            'Firebase project has no web client configured.',
          );
        }

        await FirebaseAuth.instance.signInWithCredential(
          GoogleAuthProvider.credential(idToken: idToken),
        );
      });

  Future<void> _signOut() => _run(() async {
        await FirebaseAuth.instance.signOut();
        if (_googleInitialised) {
          await GoogleSignIn.instance.signOut();
        }
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase check (TET-37)')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (firebaseInitError != null)
                _Banner(
                  color: Colors.red,
                  title: 'Firebase failed to initialise',
                  body: firebaseInitError!,
                )
              else
                const _Banner(
                  color: Colors.green,
                  title: 'Firebase initialised',
                  body: 'google-services.json was read successfully.',
                ),
              const SizedBox(height: 20),

              // Live auth state, so the uid is visible as proof of sign-in.
              StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  final User? user = snapshot.data;
                  if (user == null) {
                    return const _Banner(
                      color: Colors.grey,
                      title: 'Signed out',
                      body: 'No current user.',
                    );
                  }
                  return _Banner(
                    color: Colors.blue,
                    title: 'Signed in',
                    body: 'uid: ${user.uid}\n'
                        'email: ${user.email ?? "(none)"}\n'
                        'provider: ${user.providerData.map((p) => p.providerId).join(", ")}',
                  );
                },
              ),
              const SizedBox(height: 24),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              if (_busy)
                const Center(child: CircularProgressIndicator())
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: _signUpWithEmail,
                      child: const Text('Sign up with email'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _signInWithEmail,
                      child: const Text('Sign in with email'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _signInWithGoogle,
                      child: const Text('Sign in with Google'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: _signOut,
                      child: const Text('Sign out'),
                    ),
                  ],
                ),

              if (_error != null) ...[
                const SizedBox(height: 20),
                _Banner(
                  color: Colors.orange,
                  title: 'Last error',
                  body: _error!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.color,
    required this.title,
    required this.body,
  });

  final Color color;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(body, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
