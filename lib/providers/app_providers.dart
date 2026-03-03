import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/question.dart';
import '../services/ai_tutor_service.dart';
import '../services/firebase_service.dart';

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

final aiTutorServiceProvider = Provider<AiTutorService>((ref) {
  return AiTutorService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseServiceProvider).authStateChanges();
});

final questionsProvider = StreamProvider<List<Question>>((ref) {
  final User? user = ref.watch(authStateProvider).value;
  if (user == null) {
    return Stream<List<Question>>.value(const <Question>[]);
  }
  return ref.watch(firebaseServiceProvider).watchQuestionsForUser(user.uid);
});

final questionProvider = StreamProvider.family<Question?, String>((
  ref,
  questionId,
) {
  return ref.watch(firebaseServiceProvider).watchQuestionById(questionId);
});
