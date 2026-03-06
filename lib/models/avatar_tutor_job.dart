class AvatarTutorJob {
  const AvatarTutorJob({
    required this.jobId,
    required this.answerText,
    required this.status,
  });

  final String jobId;
  final String answerText;
  final String status;

  factory AvatarTutorJob.fromMap(Map<String, dynamic> map) {
    return AvatarTutorJob(
      jobId: (map['jobId'] as String? ?? '').trim(),
      answerText: (map['answerText'] as String? ?? '').trim(),
      status: (map['status'] as String? ?? 'created').trim(),
    );
  }
}

class AvatarTutorJobStatus {
  const AvatarTutorJobStatus({
    required this.status,
    this.videoUrl,
    this.errorMessage,
  });

  final String status;
  final String? videoUrl;
  final String? errorMessage;

  bool get isDone => status.toLowerCase() == 'done' && (videoUrl ?? '').isNotEmpty;

  bool get isError => const <String>{'error', 'failed'}.contains(status.toLowerCase());

  factory AvatarTutorJobStatus.fromMap(Map<String, dynamic> map) {
    return AvatarTutorJobStatus(
      status: (map['status'] as String? ?? 'unknown').trim(),
      videoUrl: (map['videoUrl'] as String?)?.trim(),
      errorMessage: (map['errorMessage'] as String?)?.trim(),
    );
  }
}
