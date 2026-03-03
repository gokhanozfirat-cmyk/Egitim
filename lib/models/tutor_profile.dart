class TutorProfile {
  const TutorProfile({
    required this.subject,
    required this.assetPath,
    required this.tutorName,
    required this.lessonTitles,
  });

  final String subject;
  final String assetPath;
  final String tutorName;
  final List<String> lessonTitles;
}
