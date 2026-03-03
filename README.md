# AI Tutor App

Kunduz-like mobile app built with Flutter + Firebase + AI services.

## Tech Stack

- Flutter (Material 3)
- Firebase Auth, Firestore, Storage
- Riverpod state management
- OpenAI GPT-4o / Gemini 1.5 Pro integration
- flutter_math_fork for LaTeX rendering

## Folder Structure

```text
lib/
  app.dart
  main.dart
  core/
    config/env.dart
    constants/app_colors.dart
    constants/app_prompts.dart
    theme/app_theme.dart
  models/
    ai_solution.dart
    question.dart
  providers/
    app_providers.dart
  services/
    ai_tutor_service.dart
    firebase_service.dart
  views/
    ask_question_screen.dart
    auth_gate.dart
    home_screen.dart
    onboarding_screen.dart
    sign_in_screen.dart
    solution_screen.dart
  widgets/
    math_text_block.dart
    question_card.dart
```

## Required Setup

1. Configure Firebase for Android/iOS and add platform config files.
2. Enable Firebase Auth methods:
   - Email/Password
   - Google
3. Create Firestore and Storage rules for authenticated users.
4. Run with AI keys using `--dart-define`:

```bash
flutter run ^
  --dart-define=AI_PROVIDER=openai ^
  --dart-define=OPENAI_API_KEY=YOUR_KEY ^
  --dart-define=OPENAI_MODEL=gpt-4o
```

Gemini option:

```bash
flutter run ^
  --dart-define=AI_PROVIDER=gemini ^
  --dart-define=GEMINI_API_KEY=YOUR_KEY ^
  --dart-define=GEMINI_MODEL=gemini-1.5-pro
```

Optional Google Sign-In overrides:

- `--dart-define=GOOGLE_CLIENT_ID=...`
- `--dart-define=GOOGLE_SERVER_CLIENT_ID=...`
