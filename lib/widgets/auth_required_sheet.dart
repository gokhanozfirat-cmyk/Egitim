import 'package:flutter/material.dart';

import '../views/sign_in_screen.dart';

Future<void> showAuthRequiredSheet(BuildContext context) async {
  final AuthMode? selectedMode = await showModalBottomSheet<AuthMode>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Devam etmek icin giris yapman gerekiyor.',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(AuthMode.signIn),
                icon: const Icon(Icons.login),
                label: const Text('Giris Yap'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(AuthMode.register),
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Kayit Ol'),
              ),
            ],
          ),
        ),
      );
    },
  );

  if (!context.mounted || selectedMode == null) {
    return;
  }

  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => SignInScreen(initialMode: selectedMode),
    ),
  );
}
