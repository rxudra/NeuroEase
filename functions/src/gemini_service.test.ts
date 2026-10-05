import assert from 'node:assert/strict';
import test from 'node:test';

import { GeminiService, GeminiTextClient } from './gemini_service';
import { FakeGeminiClient } from './fake_gemini_client';

function fakeClient(text?: string): GeminiTextClient {
  return {
    models: {
      async generateContent() {
        return { text };
      },
    },
  };
}

test('returns a generated response without exposing the API key', async () => {
  let receivedKey = '';
  const service = new GeminiService((apiKey) => {
    receivedKey = apiKey;
    return fakeClient('Hello from Gemini.');
  });

  const response = await service.generateResponse('Hello', 'test-only-key');

  assert.equal(response, 'Hello from Gemini.');
  assert.equal(receivedKey, 'test-only-key');
});

test('rejects an empty Gemini response', async () => {
  const service = new GeminiService(() => fakeClient('  '));

  await assert.rejects(service.generateResponse('Hello', 'test-only-key'));
});

test('supports the local fake Gemini client without network access', async () => {
  const service = new GeminiService(() => new FakeGeminiClient('Local response.'));

  assert.equal(
    await service.generateResponse('Hello', 'test-only-key'),
    'Local response.',
  );
});