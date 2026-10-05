# NeuroEase Functions Development

This backend is for local development only until production Gemini credentials and deployment approval are available.

## Install

From the repository root:

```powershell
cd functions
npm install
cd ..
flutter pub get
```

The Gemini key is not required for building or running validation tests. A real Gemini response requires the `GEMINI_API_KEY` secret in the emulator environment, but no production key should be committed.

## Start the local emulators

From the repository root:

```powershell
firebase emulators:start --only auth,firestore,functions
```

The configured ports are:

- Authentication: `9099`
- Firestore: `8080`
- Functions: `5001`
- Emulator UI: `4000`

Run the Flutter app against the emulators with:

```powershell
flutter run --dart-define=USE_FIREBASE_EMULATORS=true
```

For an Android emulator, use the host machine address:

```powershell
flutter run --dart-define=USE_FIREBASE_EMULATORS=true --dart-define=FIREBASE_EMULATOR_HOST=10.0.2.2
```

Create a test user in the Authentication Emulator UI or with the emulator API. Do not use production users or private Firestore data. Sign in with that test user in the app before calling `generateAiResponse`; unsigned requests should be rejected.

Run backend validation tests with:

```powershell
cd functions
npm test
```

Stop the emulators with `Ctrl+C`. These instructions do not deploy any Firebase service.