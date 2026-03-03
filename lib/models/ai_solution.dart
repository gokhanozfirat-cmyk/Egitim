class AiSolution {
  const AiSolution({
    required this.subject,
    required this.steps,
    required this.finalAnswer,
    required this.solutionText,
  });

  final String subject;
  final List<String> steps;
  final String finalAnswer;
  final String solutionText;

  factory AiSolution.fromJson(Map<String, dynamic> json) {
    final dynamic rawSteps = json['steps'];
    return AiSolution(
      subject: (json['subject'] as String? ?? 'General').trim(),
      steps: rawSteps is List
          ? rawSteps.whereType<String>().map((e) => e.trim()).toList()
          : const <String>[],
      finalAnswer: (json['final_answer'] as String? ?? '').trim(),
      solutionText: (json['solution_text'] as String? ?? '').trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'subject': subject,
      'steps': steps,
      'final_answer': finalAnswer,
      'solution_text': solutionText,
    };
  }
}
