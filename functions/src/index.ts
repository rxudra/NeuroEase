import { defineSecret } from 'firebase-functions/params';
import { HttpsError, onCall } from 'firebase-functions/v2/https';

import { requireAuthentication } from './auth';
import { generateGeminiResponse } from './gemini_service';
import { AIRequest } from './models/ai_request';
import { AIResponse } from './models/ai_response';
import { validateAIRequest } from './validation';

const geminiApiKey = defineSecret('GEMINI_API_KEY');

export const generateAiResponse = onCall(
  {
    region: 'asia-south1',
    secrets: [geminiApiKey],
    timeoutSeconds: 35,
  },
  async (request) => {
    requireAuthentication(request.auth);

    let input: AIRequest;
    try {
      input = validateAIRequest(request.data);
    } catch (_) {
      throw new HttpsError('invalid-argument', 'The prompt is invalid.');
    }

    try {
      const response: AIResponse = {
        response: await generateGeminiResponse(input.prompt, geminiApiKey.value()),
      };
      return response;
    } catch (_) {
      console.error('Gemini request failed.');
      throw new HttpsError('internal', 'The AI service is unavailable.');
    }
  },
);