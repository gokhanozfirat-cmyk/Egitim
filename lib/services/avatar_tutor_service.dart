import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/env.dart';
import '../models/avatar_tutor_job.dart';

class AvatarTutorService {
  AvatarTutorService({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;

  SupabaseClient get client => _client ?? Supabase.instance.client;

  Future<AvatarTutorJob> createVideo({
    required String examName,
    required String subjectName,
    required String? activeTopic,
    required String userMessage,
    required List<Map<String, String>> conversationHistory,
  }) async {
    _assertSupabaseReady();

    final dynamic response = await client.functions.invoke(
      'tutor-create-video',
      body: <String, dynamic>{
        'examName': examName,
        'subjectName': subjectName,
        'activeTopic': activeTopic,
        'userMessage': userMessage,
        'conversationHistory': conversationHistory,
      },
    );

    final Map<String, dynamic> data = _extractData(response);
    return AvatarTutorJob.fromMap(data);
  }

  Future<AvatarTutorJobStatus> getVideoStatus(String jobId) async {
    _assertSupabaseReady();

    final dynamic response = await client.functions.invoke(
      'tutor-video-status',
      body: <String, dynamic>{'jobId': jobId},
    );

    final Map<String, dynamic> data = _extractData(response);
    return AvatarTutorJobStatus.fromMap(data);
  }

  Future<AvatarTutorJobStatus> waitUntilDone(
    String jobId, {
    Duration pollInterval = const Duration(seconds: 3),
    Duration timeout = const Duration(minutes: 2),
  }) async {
    final Stopwatch stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < timeout) {
      final AvatarTutorJobStatus status = await getVideoStatus(jobId);
      if (status.isDone || status.isError) {
        return status;
      }
      await Future<void>.delayed(pollInterval);
    }

    return const AvatarTutorJobStatus(
      status: 'timeout',
      errorMessage: 'Video hazirlanirken zaman asimi olustu.',
    );
  }

  void _assertSupabaseReady() {
    if (!Env.hasSupabaseConfig) {
      throw StateError(
        'Supabase ayarlari eksik. SUPABASE_URL ve SUPABASE_PUBLISHABLE_KEY ver.',
      );
    }
  }

  Map<String, dynamic> _extractData(dynamic response) {
    if (response is FunctionResponse) {
      final dynamic data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      if (data is Map) {
        return data.cast<String, dynamic>();
      }
    }

    if (response is Map<String, dynamic>) {
      return response;
    }
    if (response is Map) {
      return response.cast<String, dynamic>();
    }

    throw const FormatException('Supabase function beklenen formatta donmedi.');
  }
}
