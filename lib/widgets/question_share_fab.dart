import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/env.dart';
import '../providers/app_providers.dart';
import '../views/question_share_screen.dart';
import 'auth_required_sheet.dart';

class QuestionShareFab extends ConsumerWidget {
  const QuestionShareFab({super.key, required this.heroTag});

  final String heroTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.extended(
      heroTag: heroTag,
      onPressed: () async {
        if (Env.requireLogin) {
          final user = ref.read(authStateProvider).asData?.value;
          if (user == null) {
            await showAuthRequiredSheet(context);
            if (!context.mounted) {
              return;
            }
            final updatedUser = ref.read(authStateProvider).asData?.value;
            if (updatedUser == null) {
              return;
            }
          }
        }

        if (!context.mounted) {
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const QuestionShareScreen()),
        );
      },
      tooltip: 'Soru Sor',
      icon: const Icon(Icons.add_comment_outlined),
      label: const Text(
        'Soru Sor',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
