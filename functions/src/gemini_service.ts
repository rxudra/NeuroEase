import { GoogleGenAI } from '@google/genai';

import { buildPrompt } from './prompt_policy';

const MODEL_NAME = 'gemini-2.5-flash';
const GEMINI_REQUEST_TIMEOUT_MS = 30000;

export interface GeminiTextClient {
  models: {
    generateContent(request: {
      model: string;
      contents: string;
    }): Promise<{ text?: string }>;
  };
}

export class GeminiService {
  constructor(
    private readonly createClient: (apiKey: string) => GeminiTextClient =
      (apiKey) => new GoogleGenAI({ apiKey }),
  ) {}

  async generateResponse(userPrompt: string, apiKey: string): Promise<string> {
    const client = this.createClient(apiKey);
    let timer: NodeJS.Timeout;
    try {
      const result = await Promise.race([
        client.models.generateContent({
          model: MODEL_NAME,
          contents: buildPrompt(userPrompt),
        }),
        new Promise<never>((_, reject) => {
          timer = setTimeout(
            () => reject(new Error('Gemini request timed out.')),
            GEMINI_REQUEST_TIMEOUT_MS,
          );
        }),
      ]);

      const response = result.text?.trim();
      if (!response) {
        throw new Error('Gemini returned an empty response.');
      }
      return response;
    } finally {
      clearTimeout(timer!);
    }
  }
}

const geminiService = new GeminiService();

export function generateGeminiResponse(
  userPrompt: string,
  apiKey: string,
): Promise<string> {
  return geminiService.generateResponse(userPrompt, apiKey);
}