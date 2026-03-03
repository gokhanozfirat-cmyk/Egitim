import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class Question {
  Question({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.solutionText,
    required this.subject,
    required this.timestamp,
    required this.steps,
    required this.finalAnswer,
    this.helpful,
  });

  final String id;
  final String userId;
  final String imageUrl;
  final String solutionText;
  final String subject;
  final DateTime timestamp;
  final List<String> steps;
  final String finalAnswer;
  final bool? helpful;

  factory Question.newQuestion({
    required String userId,
    required String imageUrl,
    required String solutionText,
    required String subject,
    required List<String> steps,
    required String finalAnswer,
  }) {
    return Question(
      id: const Uuid().v4(),
      userId: userId,
      imageUrl: imageUrl,
      solutionText: solutionText,
      subject: subject,
      timestamp: DateTime.now(),
      steps: steps,
      finalAnswer: finalAnswer,
    );
  }

  factory Question.fromMap(Map<String, dynamic> map, String documentId) {
    final dynamic timestampValue = map['timestamp'];
    final DateTime timestamp = switch (timestampValue) {
      Timestamp value => value.toDate(),
      DateTime value => value,
      _ => DateTime.fromMillisecondsSinceEpoch(0),
    };

    final dynamic rawSteps = map['steps'];
    return Question(
      id: (map['id'] as String?)?.trim().isNotEmpty == true
          ? (map['id'] as String).trim()
          : documentId,
      userId: (map['userId'] as String? ?? '').trim(),
      imageUrl: (map['imageUrl'] as String? ?? '').trim(),
      solutionText: (map['solutionText'] as String? ?? '').trim(),
      subject: (map['subject'] as String? ?? 'General').trim(),
      timestamp: timestamp,
      steps: rawSteps is List
          ? rawSteps.whereType<String>().map((e) => e.trim()).toList()
          : const <String>[],
      finalAnswer: (map['finalAnswer'] as String? ?? '').trim(),
      helpful: map['helpful'] as bool?,
    );
  }

  Question copyWith({
    String? id,
    String? userId,
    String? imageUrl,
    String? solutionText,
    String? subject,
    DateTime? timestamp,
    List<String>? steps,
    String? finalAnswer,
    bool? helpful,
  }) {
    return Question(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      solutionText: solutionText ?? this.solutionText,
      subject: subject ?? this.subject,
      timestamp: timestamp ?? this.timestamp,
      steps: steps ?? this.steps,
      finalAnswer: finalAnswer ?? this.finalAnswer,
      helpful: helpful ?? this.helpful,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'imageUrl': imageUrl,
      'solutionText': solutionText,
      'subject': subject,
      'steps': steps,
      'finalAnswer': finalAnswer,
      'helpful': helpful,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
