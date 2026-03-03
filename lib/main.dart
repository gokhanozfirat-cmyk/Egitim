import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/env.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: _BootstrapApp()));
}

class _BootstrapApp extends StatefulWidget {
  const _BootstrapApp();

  @override
  State<_BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<_BootstrapApp> {
  late final Future<void> _initFuture = _initializeBackends();

  Future<void> _initializeBackends() async {
    await Firebase.initializeApp();

    if (!Env.hasSupabaseConfig) {
      throw StateError(
        'Supabase config missing. Run with --dart-define=SUPABASE_URL '
        'and --dart-define=SUPABASE_ANON_KEY.',
      );
    }

    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: _BackendSetupErrorScreen(error: snapshot.error.toString()),
          );
        }

        return const AiTutorApp();
      },
    );
  }
}

class _BackendSetupErrorScreen extends StatelessWidget {
  const _BackendSetupErrorScreen({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backend setup required')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('App could not initialize required services.'),
            const SizedBox(height: 12),
            const Text('Firebase:'),
            const Text('- android/app/google-services.json'),
            const Text('- ios/Runner/GoogleService-Info.plist'),
            const SizedBox(height: 8),
            const Text('Supabase --dart-define values:'),
            const Text('- SUPABASE_URL'),
            const Text('- SUPABASE_ANON_KEY'),
            const Text(
              '- SUPABASE_BUCKET (optional, default: question-images)',
            ),
            const SizedBox(height: 16),
            Text(
              'Error:\n$error',
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
