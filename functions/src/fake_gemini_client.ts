import { GeminiTextClient } from './gemini_service';

/** Test-only Gemini client; it never contacts Gemini or needs an API key. */
export class FakeGeminiClient implements GeminiTextClient {
  constructor(
    private readonly response = 'Local fake Gemini response.',
    private readonly delayMs = 0,
  ) {}

  models = {
    generateContent: async (): Promise<{ text?: string }> => {
      if (this.delayMs > 0) {
        await new Promise<void>((resolve) => setTimeout(resolve, this.delayMs));
      }
      return { text: this.response };
    },
  };
}