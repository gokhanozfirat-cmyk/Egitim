import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/config/env.dart';

class ChatGptService {
  ChatGptService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const String _defaultSystemPrompt =
      'Sen net, sabirli ve ogretici bir ogretmensin. '
      'Cevabi adim adim, sade ve anlasilir ver.';

  Future<String> askText(String question) async {
    if (question.trim().isEmpty) {
      throw ArgumentError('Question text is empty.');
    }

    return _requestImageOrText(
      userContent: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'text', 'text': question.trim()},
      ],
      systemPrompt: _defaultSystemPrompt,
    );
  }

  Future<String> askImage(File imageFile, {String? prompt}) async {
    final List<int> bytes = await imageFile.readAsBytes();
    final String base64Image = base64Encode(bytes);

    return _requestImageOrText(
      userContent: <Map<String, dynamic>>[
        <String, dynamic>{
          'type': 'text',
          'text': prompt?.trim().isNotEmpty == true
              ? prompt!.trim()
              : 'Bu soruyu adim adim coz ve kisa acikla.',
        },
        <String, dynamic>{
          'type': 'image_url',
          'image_url': <String, dynamic>{
            'url': 'data:image/jpeg;base64,$base64Image',
          },
        },
      ],
      systemPrompt: _defaultSystemPrompt,
    );
  }

  Future<String> askConversation({
    required String systemPrompt,
    required List<Map<String, String>> messages,
  }) async {
    if (messages.isEmpty) {
      throw ArgumentError('Conversation is empty.');
    }
    if (Env.openAiApiKey.isEmpty) {
      throw StateError('OPENAI_API_KEY missing. Pass via --dart-define.');
    }

    final Uri uri = Uri.parse('https://api.openai.com/v1/chat/completions');
    final List<Map<String, dynamic>> payloadMessages = <Map<String, dynamic>>[
      <String, dynamic>{'role': 'system', 'content': systemPrompt.trim()},
      ...messages.map((Map<String, String> message) {
        return <String, dynamic>{
          'role': message['role'] ?? 'user',
          'content': message['content'] ?? '',
        };
      }),
    ];

    final Map<String, dynamic> payload = <String, dynamic>{
      'model': Env.openAiModel,
      'temperature': 0.35,
      'messages': payloadMessages,
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
      throw Exception('ChatGPT request failed: ${response.body}');
    }

    return _extractTextFromResponse(response.body);
  }

  Future<String> _requestImageOrText({
    required List<Map<String, dynamic>> userContent,
    required String systemPrompt,
  }) async {
    if (Env.openAiApiKey.isEmpty) {
      throw StateError('OPENAI_API_KEY missing. Pass via --dart-define.');
    }

    final Uri uri = Uri.parse('https://api.openai.com/v1/chat/completions');

    final Map<String, dynamic> payload = <String, dynamic>{
      'model': Env.openAiModel,
      'temperature': 0.3,
      'messages': <Map<String, dynamic>>[
        <String, dynamic>{'role': 'system', 'content': systemPrompt},
        <String, dynamic>{'role': 'user', 'content': userContent},
      ],
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
      throw Exception('ChatGPT request failed: ${response.body}');
    }

    return _extractTextFromResponse(response.body);
  }

  String _extractTextFromResponse(String rawBody) {
    final Map<String, dynamic> data =
        jsonDecode(rawBody) as Map<String, dynamic>;
    final List<dynamic> choices =
        data['choices'] as List<dynamic>? ?? <dynamic>[];
    if (choices.isEmpty) {
      throw const FormatException('Empty response from ChatGPT.');
    }

    final Map<String, dynamic> message =
        (choices.first as Map<String, dynamic>)['message']
            as Map<String, dynamic>? ??
        <String, dynamic>{};

    final String text = (message['content'] as String? ?? '').trim();
    if (text.isEmpty) {
      throw const FormatException('ChatGPT returned empty answer.');
    }

    return text;
  }
}
