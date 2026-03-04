import 'package:flutter/material.dart';

import '../models/tutor_profile.dart';
import '../widgets/question_share_fab.dart';

class SubjectLessonsScreen extends StatelessWidget {
  const SubjectLessonsScreen({super.key, required this.profile});

  final TutorProfile profile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${profile.subject} Dersleri')),
      floatingActionButton: const QuestionShareFab(heroTag: 'fab_lessons'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              height: 250,
              child: Image.asset(
                profile.assetPath,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const ColoredBox(
                  color: Color(0xFFE5EDF6),
                  child: Center(child: Icon(Icons.person_outline, size: 48)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            profile.tutorName,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            '${profile.subject} dersi için AI destekli çalışma kartları',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          ...List<Widget>.generate(profile.lessonTitles.length, (index) {
            final String lesson = profile.lessonTitles[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(lesson),
                subtitle: Text('${profile.subject} - Konu ${index + 1}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$lesson dersi yakında açılacak.')),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
