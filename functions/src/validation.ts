import { AIRequest } from './models/ai_request';
import { MAX_PROMPT_LENGTH } from './prompt_policy';

export function validateAIRequest(data: unknown): AIRequest {
  if (data === null || typeof data !== 'object') {
    throw new Error('Request must be an object.');
  }

  const prompt = (data as { prompt?: unknown }).prompt;
  if (typeof prompt !== 'string') {
    throw new Error('Prompt must be a string.');
  }

  const normalizedPrompt = prompt.trim();
  if (
    normalizedPrompt.length === 0 ||
    normalizedPrompt.length > MAX_PROMPT_LENGTH
  ) {
    throw new Error('Prompt length is invalid.');
  }

  return { prompt: normalizedPrompt };
}