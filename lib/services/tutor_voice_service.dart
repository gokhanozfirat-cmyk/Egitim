import 'dart:io';

import 'package:flutter/services.dart';

enum TutorVoiceGender { male, female, neutral }

class TutorVoiceService {
  static const MethodChannel _channel = MethodChannel('ai_tutor/tts');

  Future<void> speak(
    String text, {
    TutorVoiceGender gender = TutorVoiceGender.neutral,
  }) async {
    final String cleaned = text.trim();
    if (cleaned.isEmpty || !Platform.isAndroid) {
      return;
    }

    await _channel.invokeMethod<void>('speak', <String, dynamic>{
      'text': cleaned,
      'rate': 0.95,
      'pitch': 1.0,
      'gender': gender.name,
    });
  }

  Future<void> stop() async {
    if (!Platform.isAndroid) {
      return;
    }
    await _channel.invokeMethod<void>('stop');
  }
}
