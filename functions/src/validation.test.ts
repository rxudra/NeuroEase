import assert from 'node:assert/strict';
import test from 'node:test';

import { validateAIRequest } from './validation';

test('validates and trims a prompt', () => {
  assert.deepEqual(validateAIRequest({ prompt: '  hello  ' }), {
    prompt: 'hello',
  });
});

test('rejects missing, empty, and oversized prompts', () => {
  assert.throws(() => validateAIRequest(null));
  assert.throws(() => validateAIRequest({ prompt: ' ' }));
  assert.throws(() => validateAIRequest({ prompt: 'x'.repeat(4001) }));
});

test('does not accept private context fields as part of the request contract', () => {
  assert.deepEqual(validateAIRequest({ prompt: 'hello', patientId: 'private' }), {
    prompt: 'hello',
  });
});