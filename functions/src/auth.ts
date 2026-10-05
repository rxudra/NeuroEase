import { HttpsError } from 'firebase-functions/v2/https';

export function requireAuthentication(auth: unknown): void {
  if (!auth) {
    throw new HttpsError('unauthenticated', 'Authentication is required.');
  }
}