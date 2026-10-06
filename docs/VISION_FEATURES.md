# Vision features (camera + on-device ML)

Camera-based assistive features in NeuroEase. Entry point:
`lib/features/recognition/recognition_screen.dart` ("Camera help" hub).

## Architecture

```
Screen (UI only)                     lib/features/<feature>/screens/
  ↓ observes
Controller (state machine)           VisionScanController<T> + thin subclass
  ↓ uses                    ↓ uses
Service interface           VisionCamera interface
  ↓ implemented by          ↓ implemented by
ML Kit service              DeviceVisionCamera (camera plugin)
  ↓ returns
Result model (plain Dart, no ML Kit types)
```

Shared code lives in `lib/features/vision/`:

| File | Purpose |
|---|---|
| `vision_failure.dart` | Failure kinds + plain-language messages |
| `camera/vision_camera.dart` | Camera interface (mockable) |
| `camera/device_vision_camera.dart` | Only file that uses the `camera` plugin |
| `vision_scan_controller.dart` | idle → initializing → ready → scanning → result / error |
| `widgets/vision_scan_view.dart` | Shared preview + status + single big button |

Only the `mlkit_*_service.dart` files import ML Kit. Swapping the ML
library means writing one new service class.

### Interaction model: tap to scan

The user taps one button, one still photo is taken, analysed on the device,
and **deleted immediately** (in a `finally`, so also on failure). A live
frame stream was deliberately not used: it is harder to follow for users
with cognitive impairments and keeps the camera pipeline busy. A stream
mode can be added later behind the same controller.

The camera is released when the app goes to the background and re-opened
when it returns. It is *not* released while starting up, because the
operating system's permission dialog briefly makes the app inactive.

## Face detection

`lib/features/face_recognition/`

- Detects faces, counts them, and estimates head direction, smiling and
  eyes open (ML Kit classification), plus 10 landmarks (eyes, nose, mouth,
  ears, cheeks) exposed on `DetectedFace.landmarks` for future features.
- **Does not identify people.** Identity matching requires storing
  biometric templates (face embeddings). That needs explicit consent, a
  retention policy, encrypted on-device storage and a security review
  before it is built. It is intentionally out of scope; add it as a new
  service behind its own interface if the team decides to pursue it.
- Shows at most 3 face descriptions, then "and N more", to avoid
  overwhelming the user.

## Object recognition

`lib/features/object_recognition/`

Uses two Google ML Kit on-device models from the same family (no competing
CV libraries):

- **Image labeling** (`google_mlkit_image_labeling`) names what is in the
  photo ("Cup", "Chair", "Fruit"; ~400 classes) with a confidence score.
  This is what the user is told.
- **Object detection** (`google_mlkit_object_detection`) locates separate
  objects (bounding boxes) with a coarse category. Its base model only has 5
  categories ("Fashion good", "Food", "Home good", "Place", "Plant"), which
  is why it is not used on its own. Used for "N separate objects in view"
  and kept on `LocatedObject` for future overlays.

Confidence handling (safety):

| Confidence | Shown as |
|---|---|
| ≥ 0.8 | "Cup — Very likely (92%)" |
| 0.6 – 0.8 | "Cup — Likely (66%)" |
| 0.5 – 0.6 | Never stated as fact. Headline "Not sure what this is", plus at most one "It might be: …" and advice to try again |
| < 0.5 | Dropped by ML Kit |

At most 3 names are listed. Every result carries a note to double-check
before relying on it, especially for medicines or food. Thresholds live in
`ObjectRecognitionResult` / `RecognizedLabel` so Person 5 (AI Safety) can
tune them in one place.

Upgrading later: for richer object names with boxes, a custom TFLite model
can be plugged into ML Kit object detection (`LocalObjectDetectorOptions`)
inside `MlKitObjectRecognitionService` without touching UI or controller.

## Privacy and security

- All processing is on-device (ML Kit bundled models). No network calls.
- No photo, frame, face geometry or result is written to Firestore, Storage,
  logs or disk (other than the camera's temporary file, deleted right away).
- Result models have no `toJson`/`fromMap` on purpose.
- `VisionFailure.debugMessage` contains only exception types or platform
  error codes, never paths or image data.
- No Firestore rules, endpoints or credentials were added or changed.

## Platform configuration

| Platform | Change |
|---|---|
| Android | `CAMERA` permission (runtime prompt by the camera plugin); `android.hardware.camera` declared `required="false"` so the app still installs on devices without a camera. `minSdk` stays `flutter.minSdkVersion` (ML Kit needs ≥ 21; current Flutter defaults are higher). |
| iOS | `NSCameraUsageDescription` in `Info.plist`; deployment target raised 13.0 → **15.5** (ML Kit minimum). When `ios/Podfile` is generated, set `platform :ios, '15.5'` in it. ML Kit has no arm64 simulator slice: test on a real iPhone. |
| Web / desktop | Not supported by ML Kit. The screens fall back to an error state ("Camera not available" or "Could not check the photo") instead of crashing. Do not add the hub to navigation on those platforms. |

After pulling: run `flutter pub get` and commit the updated `pubspec.lock`.

## Tests

Automated tests (no camera needed) use fakes in `test/support/`:

- `test/vision/` – failure mapping, camera-plugin error codes, the full
  controller state machine (permission denied, no camera, processing
  failure, photo always deleted, lifecycle suspend/resume, dispose).
- `test/face_recognition/` – result model, controller, screen UI states.
- `test/object_recognition/` – confidence levels/thresholds, sorting,
  low-confidence handling, no detection, controller, screen UI states.
- `test/recognition_screen_test.dart` – hub.

The ML Kit service and `DeviceVisionCamera`'s real camera path are **not**
covered by automated tests; they need a physical device.

## Physical-device checklist

Run on a real Android phone (and a real iPhone if iOS is shipped):

1. Fresh install → open Camera help → Face detection: permission prompt
   appears once; Allow → live preview.
2. Deny → "Camera access needed"; Try again → prompt again; Allow → works.
3. Deny permanently ("Don't ask again" / iOS second denial) → Settings
   message; enable in Settings, return to the app → camera opens.
4. Scan with no one in view → "No face found".
5. Scan one face (front-lit) → "1 face found" + description.
6. Scan 2–5 faces → count correct; at most 3 lines listed.
7. Background the app during preview and return → preview resumes.
8. Leave the screen → camera indicator turns off.
9. Check the app cache directory after several scans → no leftover photos.
10. Airplane mode → detection still works (proves on-device).

Object recognition (Camera help → What is this?):

11. Common objects (cup, bottle, chair, phone, fruit) in good light →
    named with "Very likely"/"Likely".
12. Blurry or dark photo → "Not sure what this is" / "It might be …",
    never a confident wrong name.
13. Blank wall → "Nothing recognised".
14. Several objects on a table → "N separate objects in view".
15. First-ever scan offline on Android: models are bundled, so it should
    still work; confirm no download prompt.
