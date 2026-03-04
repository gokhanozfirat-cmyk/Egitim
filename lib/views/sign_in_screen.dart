import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';

enum AuthMode { signIn, register }

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key, this.initialMode = AuthMode.signIn});

  final AuthMode initialMode;

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late AuthMode _authMode;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _authMode = widget.initialMode;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _mapError(Object error) {
    final String message = error.toString();
    if (message.contains('No Firebase App')) {
      return 'Firebase baglantisi kurulmamis. Once Firebase ayarlarini tamamla.';
    }
    if (message.contains('network-request-failed')) {
      return 'Ag hatasi. Internet baglantini kontrol et.';
    }
    return message;
  }

  Future<void> _submitEmailAuth() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final service = ref.read(firebaseServiceProvider);
      if (_authMode == AuthMode.signIn) {
        await service.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await service.createAccountWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_mapError(error))));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _submitGoogleAuth() async {
    setState(() => _isSubmitting = true);
    try {
      await ref.read(firebaseServiceProvider).signInWithGoogle();
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_mapError(error))));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool signInMode = _authMode == AuthMode.signIn;
    return Scaffold(
      appBar: AppBar(title: const Text('Giris / Kayit')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  signInMode ? 'Hesabina giris yap' : 'Yeni hesap olustur',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Google veya e-posta ile devam edebilirsin.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                SegmentedButton<AuthMode>(
                  segments: const <ButtonSegment<AuthMode>>[
                    ButtonSegment<AuthMode>(
                      value: AuthMode.signIn,
                      icon: Icon(Icons.login),
                      label: Text('Giris Yap'),
                    ),
                    ButtonSegment<AuthMode>(
                      value: AuthMode.register,
                      icon: Icon(Icons.person_add_alt_1),
                      label: Text('Kayit Ol'),
                    ),
                  ],
                  selected: <AuthMode>{_authMode},
                  onSelectionChanged: _isSubmitting
                      ? null
                      : (Set<AuthMode> selection) {
                          setState(() => _authMode = selection.first);
                        },
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'E-posta',
                    hintText: 'ogrenci@email.com',
                  ),
                  validator: (String? value) {
                    final String text = value?.trim() ?? '';
                    if (text.isEmpty || !text.contains('@')) {
                      return 'Gecerli bir e-posta gir.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Sifre',
                    hintText: 'En az 6 karakter',
                  ),
                  validator: (String? value) {
                    final String text = value ?? '';
                    if (text.length < 6) {
                      return 'Sifre en az 6 karakter olmali.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: _isSubmitting ? null : _submitEmailAuth,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          signInMode
                              ? 'E-posta ile Giris Yap'
                              : 'E-posta ile Kayit Ol',
                        ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Center(child: Text('veya')),
                ),
                OutlinedButton.icon(
                  onPressed: _isSubmitting ? null : _submitGoogleAuth,
                  icon: const Icon(Icons.account_circle_outlined),
                  label: const Text('Google ile Devam Et'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          setState(() {
                            _authMode = signInMode
                                ? AuthMode.register
                                : AuthMode.signIn;
                          });
                        },
                  child: Text(
                    signInMode
                        ? 'Hesabin yok mu? Kayit ol'
                        : 'Hesabin var mi? Giris yap',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
