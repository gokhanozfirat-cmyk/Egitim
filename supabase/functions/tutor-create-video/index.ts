import { corsHeaders, jsonResponse } from '../_shared/cors.ts';

type ConversationMessage = {
  role?: string;
  content?: string;
};

type RequestBody = {
  examName?: string;
  subjectName?: string;
  activeTopic?: string | null;
  userMessage?: string;
  conversationHistory?: ConversationMessage[];
};

const geminiModel = Deno.env.get('GEMINI_MODEL') ?? 'gemini-2.5-flash';
const didVoiceId = Deno.env.get('DID_VOICE_ID') ?? 'tr-TR-EmelNeural';

Deno.serve(async (request: Request): Promise<Response> => {
  if (request.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (request.method !== 'POST') {
    return jsonResponse(
      { errorMessage: 'Only POST is supported.' },
      { status: 405 },
    );
  }

  try {
    const didApiKey = requiredEnv('DID_API_KEY');
    const didPresenterId = requiredEnv('DID_PRESENTER_ID');
    const geminiApiKey = requiredEnv('GEMINI_API_KEY');

    const body = (await request.json()) as RequestBody;
    const userMessage = (body.userMessage ?? '').trim();
    if (userMessage.length === 0) {
      return jsonResponse(
        { errorMessage: 'userMessage is required.' },
        { status: 400 },
      );
    }

    const prompt = buildTutorPrompt(body);
    const answerText = await generateGeminiResponse(geminiApiKey, prompt);
    const jobId = await createDidClip(didApiKey, didPresenterId, answerText);

    return jsonResponse({
      jobId,
      answerText,
      status: 'created',
    });
  } catch (error) {
    return jsonResponse(
      {
        status: 'error',
        errorMessage: toErrorMessage(error),
      },
      { status: 500 },
    );
  }
});

function requiredEnv(name: string): string {
  const value = Deno.env.get(name)?.trim() ?? '';
  if (value.length === 0) {
    throw new Error(`${name} is missing in Supabase secrets.`);
  }
  return value;
}

function buildTutorPrompt(body: RequestBody): string {
  const examName = (body.examName ?? 'Genel').trim();
  const subjectName = (body.subjectName ?? 'Matematik').trim();
  const activeTopic = (body.activeTopic ?? '').trim();
  const userMessage = (body.userMessage ?? '').trim();
  const history = Array.isArray(body.conversationHistory)
    ? body.conversationHistory
    : [];

  const safeHistory = history
    .slice(-8)
    .map((ConversationMessage message) => {
      const role = (message.role ?? 'user').trim();
      const content = (message.content ?? '').trim();
      return `${role}: ${content}`;
    })
    .join('\n');

  return [
    'Sen Turkce konusan deneyimli bir matematik ogretmenisin.',
    'Cevaplari acik, adim adim ve ogrencinin seviyesine uygun ver.',
    'Gereksiz uzun yazma. Konu anlatirken ornek, ipucu ve mini kontrol sorusu ekle.',
    `Sinav: ${examName}`,
    `Brans: ${subjectName}`,
    activeTopic.length === 0 ? null : `Aktif konu: ${activeTopic}`,
    safeHistory.length === 0 ? null : `Sohbet gecmisi:\n${safeHistory}`,
    `Ogrenci mesaji: ${userMessage}`,
    'Cevapta Markdown kullanma.',
  ].filter((value): value is string => value !== null).join('\n\n');
}

async function generateGeminiResponse(
  apiKey: string,
  prompt: string,
): Promise<string> {
  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(geminiModel)}:generateContent?key=${apiKey}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [
          {
            parts: [{ text: prompt }],
          },
        ],
        generationConfig: {
          temperature: 0.35,
        },
      }),
    },
  );

  const raw = await response.text();
  if (!response.ok) {
    throw new Error(`Gemini request failed: ${raw}`);
  }

  const json = JSON.parse(raw) as Record<string, unknown>;
  const candidates = Array.isArray(json.candidates)
    ? (json.candidates as Array<Record<string, unknown>>)
    : [];
  if (candidates.length === 0) {
    throw new Error('Gemini returned no candidates.');
  }

  const content = (candidates[0].content ?? {}) as Record<string, unknown>;
  const parts = Array.isArray(content.parts)
    ? (content.parts as Array<Record<string, unknown>>)
    : [];
  if (parts.length === 0) {
    throw new Error('Gemini returned no parts.');
  }
  const text = String(parts[0]?.text ?? '').trim();
  if (text.length === 0) {
    throw new Error('Gemini returned empty text.');
  }
  return text;
}

async function createDidClip(
  apiKey: string,
  presenterId: string,
  answerText: string,
): Promise<string> {
  const response = await fetch('https://api.d-id.com/clips', {
    method: 'POST',
    headers: {
      Authorization: `Basic ${apiKey}`,
      'Content-Type': 'application/json',
      Accept: 'application/json',
    },
    body: JSON.stringify({
      presenter_id: presenterId,
      script: {
        type: 'text',
        input: answerText,
        provider: {
          type: 'microsoft',
          voice_id: didVoiceId,
        },
      },
      config: {
        stitch: true,
      },
    }),
  });

  const raw = await response.text();
  if (!response.ok) {
    throw new Error(`D-ID create clip failed: ${raw}`);
  }

  const json = JSON.parse(raw) as Record<string, unknown>;
  const clipId = String(json.id ?? '').trim();
  if (clipId.length === 0) {
    throw new Error('D-ID did not return a clip id.');
  }
  return clipId;
}

function toErrorMessage(error: unknown): string {
  if (error instanceof Error) {
    return error.message;
  }
  return String(error);
}
