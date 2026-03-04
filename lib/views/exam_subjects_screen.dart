import 'package:flutter/material.dart';

import '../models/exam.dart';
import '../widgets/question_share_fab.dart';
import 'math_tutor_screen.dart';

class ExamSubjectsScreen extends StatelessWidget {
  const ExamSubjectsScreen({super.key, required this.exam});

  final Exam exam;

  bool _isMathSubject(String value) {
    final String normalized = value.toLowerCase();
    return normalized.contains('matematik');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(exam.name)),
      floatingActionButton: const QuestionShareFab(heroTag: 'fab_subjects'),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (_, index) {
          final String subject = exam.subjects[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(subject),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                if (_isMathSubject(subject)) {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => MathTutorScreen(
                        examName: exam.name,
                        subjectName: subject,
                      ),
                    ),
                  );
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Bu brans icin AI egitmen ekrani yakinda acilacak.',
                    ),
                  ),
                );
              },
            ),
          );
        },
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemCount: exam.subjects.length,
      ),
    );
  }
}
