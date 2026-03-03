import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/env.dart';
import '../core/constants/app_prompts.dart';
import '../models/ai_solution.dart';

class AiTutorService {
  AiTutorService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<AiSolution> solveQuestion({required String imageUrl}) async {
    switch (Env.aiProvider) {
      case AiProvider.gemini:
        return _solveWithGemini(imageUrl: imageUrl);
      case AiProvider.openAi:
        return _solveWithOpenAi(imageUrl: imageUrl);
    }
  }

  Future<AiSolution> _solveWithOpenAi({required String imageUrl}) async {
    if (Env.openAiApiKey.isEmpty) {
      throw StateError('OPENAI_API_KEY is missing. Pass it via --dart-define.');
    }

    final Uri uri = Uri.parse('https://api.openai.com/v1/chat/completions');
    final Map<String, dynamic> payload = <String, dynamic>{
      'model': Env.openAiModel,
      'temperature': 0.2,
      'messages': <Map<String, dynamic>>[
        <String, dynamic>{
          'role': 'system',
          'content': AppPrompts.teacherSystemPrompt,
        },
        <String, dynamic>{
          'role': 'user',
          'content': <Map<String, dynamic>>[
            <String, dynamic>{
              'type': 'text',
              'text': 'Solve the question in this image URL: $imageUrl',
            },
            <String, dynamic>{
              'type': 'image_url',
              'image_url': <String, dynamic>{'url': imageUrl},
            },
          ],
        },
      ],
      'response_format': <String, dynamic>{
        'type': 'json_schema',
        'json_schema': <String, dynamic>{
          'name': 'question_solution',
          'strict': true,
          'schema': <String, dynamic>{
            'type': 'object',
            'additionalProperties': false,
            'required': <String>[
              'subject',
              'steps',
              'final_answer',
              'solution_text',
            ],
            'properties': <String, dynamic>{
              'subject': <String, dynamic>{'type': 'string'},
              'steps': <String, dynamic>{
                'type': 'array',
                'items': <String, dynamic>{'type': 'string'},
              },
              'final_answer': <String, dynamic>{'type': 'string'},
              'solution_text': <String, dynamic>{'type': 'string'},
            },
          },
        },
      },
    };

    final http.Response response = await _client.post(
      uri,
      headers: <String, String>{
        'Authorization': 'Bearer ${Env.openAiApiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode >= 300) {
      throw Exception(
        'OpenAI request failed: ${_extractErrorMessage(response)}',
      );
    }

    final Map<String, dynamic> responseJson =
        jsonDecode(response.body) as Map<String, dynamic>;
    final List<dynamic> choices =
        responseJson['choices'] as List<dynamic>? ?? <dynamic>[];
    if (choices.isEmpty) {
      throw const FormatException('OpenAI returned no choices.');
    }

    final Map<String, dynamic> firstChoice =
        choices.first as Map<String, dynamic>;
    final Map<String, dynamic> message =
        firstChoice['message'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final String content = (message['content'] as String? ?? '').trim();
    if (content.isEmpty) {
      throw const FormatException('OpenAI returned an empty response.');
    }

    return AiSolution.fromJson(_extractJsonObject(content));
  }

  Future<AiSolution> _solveWithGemini({required String imageUrl}) async {
    if (Env.geminiApiKey.isEmpty) {
      throw StateError('GEMINI_API_KEY is missing. Pass it via --dart-define.');
    }

    final Uri uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/'
      '${Uri.encodeComponent(Env.geminiModel)}:generateContent?key=${Env.geminiApiKey}',
    );

    final Map<String, dynamic> payload = <String, dynamic>{
      'contents': <Map<String, dynamic>>[
        <String, dynamic>{
          'parts': <Map<String, dynamic>>[
            <String, dynamic>{
              'text':
                  '${AppPrompts.teacherSystemPrompt}\n'
                  'Image URL: $imageUrl\n'
                  'Return valid JSON only.',
            },
          ],
        },
      ],
      'generationConfig': <String, dynamic>{
        'temperature': 0.2,
        'responseMimeType': 'application/json',
      },
    };

    final http.Response response = await _client.post(
      uri,
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode >= 300) {
      throw Exception(
        'Gemini request failed: ${_extractErrorMessage(response)}',
      );
    }

    final Map<String, dynamic> responseJson =
        jsonDecode(response.body) as Map<String, dynamic>;
    final List<dynamic> candidates =
        responseJson['candidates'] as List<dynamic>? ?? <dynamic>[];
    if (candidates.isEmpty) {
      throw const FormatException('Gemini returned no candidates.');
    }

    final Map<String, dynamic> firstCandidate =
        candidates.first as Map<String, dynamic>;
    final Map<String, dynamic> content =
        firstCandidate['content'] as Map<String, dynamic>? ??
        <String, dynamic>{};
    final List<dynamic> parts =
        content['parts'] as List<dynamic>? ?? <dynamic>[];
    if (parts.isEmpty) {
      throw const FormatException('Gemini returned empty parts.');
    }

    final Map<String, dynamic> firstPart = parts.first as Map<String, dynamic>;
    final String text = (firstPart['text'] as String? ?? '').trim();
    if (text.isEmpty) {
      throw const FormatException('Gemini returned an empty text payload.');
    }

    return AiSolution.fromJson(_extractJsonObject(text));
  }

  Map<String, dynamic> _extractJsonObject(String raw) {
    final String cleaned = raw.trim();
    final String withoutFence = cleaned
        .replaceAll(RegExp(r'^```json\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'^```\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s*```$'), '')
        .trim();

    final Match? match = RegExp(r'\{[\s\S]*\}').firstMatch(withoutFence);
    final String candidate = match?.group(0) ?? withoutFence;

    final dynamic decoded = jsonDecode(candidate);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Model output is not a JSON object.');
    }
    return decoded;
  }

  String _extractErrorMessage(http.Response response) {
    try {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final dynamic error = decoded['error'];
        if (error is Map<String, dynamic>) {
          return error['message'] as String? ?? response.body;
        }
      }
    } catch (_) {
      // Fall through to raw body.
    }
    return response.body;
  }
}
