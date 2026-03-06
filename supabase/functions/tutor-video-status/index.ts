import { corsHeaders, jsonResponse } from '../_shared/cors.ts';

type RequestBody = {
  jobId?: string;
};

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
    const body = (await request.json()) as RequestBody;
    const jobId = (body.jobId ?? '').trim();

    if (jobId.length === 0) {
      return jsonResponse(
        { errorMessage: 'jobId is required.' },
        { status: 400 },
      );
    }

    const status = await getClipStatus(didApiKey, jobId);
    return jsonResponse(status);
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

async function getClipStatus(
  apiKey: string,
  jobId: string,
): Promise<Record<string, unknown>> {
  const response = await fetch(`https://api.d-id.com/clips/${jobId}`, {
    method: 'GET',
    headers: {
      Authorization: `Basic ${apiKey}`,
      Accept: 'application/json',
    },
  });

  const raw = await response.text();
  if (!response.ok) {
    throw new Error(`D-ID clip status failed: ${raw}`);
  }

  const json = JSON.parse(raw) as Record<string, unknown>;
  return {
    status: String(json.status ?? 'unknown').trim(),
    videoUrl:
      readString(json, 'result_url') ??
      readString(json, 'resultUrl') ??
      readString(json, 'video_url') ??
      readString(json, 'videoUrl'),
    errorMessage:
      readString(json, 'error') ??
      readNestedString(json, 'error', 'description') ??
      readNestedString(json, 'error', 'message'),
  };
}

function readString(
  source: Record<string, unknown>,
  key: string,
): string | null {
  const value = source[key];
  if (typeof value != 'string') {
    return null;
  }
  const trimmed = value.trim();
  return trimmed.length === 0 ? null : trimmed;
}

function readNestedString(
  source: Record<string, unknown>,
  key: string,
  nestedKey: string,
): string | null {
  const value = source[key];
  if (!value || typeof value !== 'object' || Array.isArray(value)) {
    return null;
  }
  const nested = (value as Record<string, unknown>)[nestedKey];
  if (typeof nested !== 'string') {
    return null;
  }
  const trimmed = nested.trim();
  return trimmed.length === 0 ? null : trimmed;
}

function toErrorMessage(error: unknown): string {
  if (error instanceof Error) {
    return error.message;
  }
  return String(error);
}
