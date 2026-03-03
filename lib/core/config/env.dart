enum AiProvider { openAi, gemini }

class Env {
  const Env._();

  static const String aiProviderRaw = String.fromEnvironment(
    'AI_PROVIDER',
    defaultValue: 'openai',
  );
  static const String openAiApiKey = String.fromEnvironment('OPENAI_API_KEY');
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const String openAiModel = String.fromEnvironment(
    'OPENAI_MODEL',
    defaultValue: 'gpt-4o',
  );
  static const String geminiModel = String.fromEnvironment(
    'GEMINI_MODEL',
    defaultValue: 'gemini-1.5-pro',
  );
  static const String googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
  );
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );

  static AiProvider get aiProvider {
    if (aiProviderRaw.toLowerCase() == 'gemini') {
      return AiProvider.gemini;
    }
    return AiProvider.openAi;
  }
}
