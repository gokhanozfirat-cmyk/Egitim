import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/exam_catalog.dart';
import '../core/config/env.dart';
import '../models/exam.dart';
import '../providers/app_providers.dart';
import '../widgets/auth_required_sheet.dart';
import '../widgets/question_share_fab.dart';
import 'exam_subjects_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isLoggedIn = Env.requireLogin
        ? ref.watch(authStateProvider).asData?.value != null
        : true;

    Future<void> openExam(Exam exam) async {
      if (Env.requireLogin && !isLoggedIn) {
        await showAuthRequiredSheet(context);
        if (!context.mounted) {
          return;
        }
        final bool stillGuest =
            ref.read(authStateProvider).asData?.value == null;
        if (stillGuest) {
          return;
        }
      }

      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => ExamSubjectsScreen(exam: exam)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Sinavini Sec')),
      floatingActionButton: const QuestionShareFab(heroTag: 'fab_home'),
      body: Column(
        children: <Widget>[
          if (Env.requireLogin && !isLoggedIn)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Sinav secmek icin giris yap'),
                  subtitle: const Text(
                    'Kartlara dokununca Google veya e-posta ile giris ekranina yonlendirilirsin.',
                  ),
                ),
              ),
            ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ExamCatalog.exams.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.25,
              ),
              itemBuilder: (_, int index) {
                final Exam exam = ExamCatalog.exams[index];
                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => openExam(exam),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            exam.name,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${exam.subjects.length} ders',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
