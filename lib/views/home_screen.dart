import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/tutor_catalog.dart';
import '../models/question.dart';
import '../providers/app_providers.dart';
import '../widgets/question_card.dart';
import '../widgets/tutor_subject_card.dart';
import 'ask_question_screen.dart';
import 'solution_screen.dart';
import 'subject_lessons_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(questionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Tutor'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => ref.read(firebaseServiceProvider).signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: questionsAsync.when(
        data: (questions) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 96),
            children: <Widget>[
              _SectionTitle(
                title: 'Eğitim Kartları',
                subtitle: 'Derse göre eğitmen seç ve derslere git',
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 230,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: TutorCatalog.tutors.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (_, index) {
                    final profile = TutorCatalog.tutors[index];
                    return TutorSubjectCard(
                      profile: profile,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                SubjectLessonsScreen(profile: profile),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              const _SectionTitle(
                title: 'Çözülen Sorular',
                subtitle: 'Geçmiş AI çözümlerini buradan incele',
              ),
              const SizedBox(height: 10),
              if (questions.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Henüz çözülmüş soru yok.\n"Ask a question" ile başlayabilirsin.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ...questions.map((question) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: QuestionCard(
                    question: question,
                    onTap: () => _openSolution(context, question),
                  ),
                );
              }),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Failed to load questions: $error'),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const AskQuestionScreen()),
          );
        },
        icon: const Icon(Icons.camera_alt_outlined),
        label: const Text('Ask a question'),
      ),
    );
  }

  void _openSolution(BuildContext context, Question question) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            SolutionScreen(questionId: question.id, initialQuestion: question),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
