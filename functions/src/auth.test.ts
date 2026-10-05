import assert from 'node:assert/strict';
import test from 'node:test';

import { requireAuthentication } from './auth';

test('rejects unauthenticated requests', () => {
  assert.throws(
    () => requireAuthentication(undefined),
    (error: unknown) =>
      typeof error === 'object' &&
      error !== null &&
      'code' in error &&
      error.code === 'unauthenticated',
  );
});

test('accepts authenticated requests', () => {
  assert.doesNotThrow(() => requireAuthentication({ uid: 'emulator-user' }));
});