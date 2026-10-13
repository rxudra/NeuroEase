import 'dart:io';

import 'package:app/features/face_recognition/controllers/face_recognition_controller.dart';
import 'package:app/features/face_recognition/models/enrolled_person.dart';
import 'package:app/features/face_recognition/models/face_detection_result.dart';
import 'package:app/features/face_recognition/screens/face_recognition_screen.dart';
import 'package:app/features/face_recognition/services/face_enrollment_service.dart';
import 'package:app/features/face_recognition/widgets/enroll_person_dialog.dart';
import 'package:app/features/face_recognition/widgets/manage_people_dialog.dart';
import 'package:app/features/vision/vision_failure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_face_detection_service.dart';
import '../support/fake_vision_camera.dart';

const _box = Rect.fromLTWH(0, 0, 100, 100);

void main() {
  late FakeVisionCamera camera;
  late FakeFaceDetectionService detector;
  late FaceEnrollmentService enrollmentService;
  late Directory testTempDir;

  setUp(() {
    camera = FakeVisionCamera();
    detector = FakeFaceDetectionService();
    testTempDir = Directory.systemTemp.createTempSync('face_test_setup_');
    enrollmentService = FaceEnrollmentService(
      storagePath: '${testTempDir.path}/test_people.json',
    );
  });

  tearDown(() {
    if (testTempDir.existsSync()) {
      testTempDir.deleteSync(recursive: true);
    }
  });

  group('Face Enrollment & Profile Management Workflow', () {
    test('1. Enrollment model serializes to JSON and deserializes correctly', () {
      final person = EnrolledPerson(
        id: 'p1',
        name: 'Priya',
        relationship: PersonRelationship.mom,
        enrolledAt: DateTime(2026, 1, 1),
      );

      expect(person.name, 'Priya');
      expect(person.relationship, 'Mom');
      final json = person.toJson();
      expect(json['id'], 'p1');
      expect(json['name'], 'Priya');
      expect(json['relationship'], 'Mom');

      final reconstructed = EnrolledPerson.fromJson(json);
      expect(reconstructed.id, 'p1');
      expect(reconstructed.name, 'Priya');
      expect(reconstructed.relationship, 'Mom');
      expect(reconstructed == person, isTrue);
    });

    test('2. Supported relationships include required categories', () {
      expect(PersonRelationship.all, contains(PersonRelationship.mom));
      expect(PersonRelationship.all, contains(PersonRelationship.dad));
      expect(PersonRelationship.all, contains(PersonRelationship.brother));
      expect(PersonRelationship.all, contains(PersonRelationship.sister));
      expect(PersonRelationship.all, contains(PersonRelationship.caregiver));
      expect(PersonRelationship.all, contains(PersonRelationship.doctor));
      expect(PersonRelationship.all, contains(PersonRelationship.other));
    });

    test('3. Enrolling a person adds profile to service', () async {
      await enrollmentService.initialize();
      expect(enrollmentService.enrolledPeople, isEmpty);

      final person = EnrolledPerson(
        id: 'p1',
        name: 'Priya',
        relationship: PersonRelationship.mom,
        enrolledAt: DateTime(2026),
      );

      await enrollmentService.enrollPerson(person);
      expect(enrollmentService.enrolledPeople, hasLength(1));
      expect(enrollmentService.enrolledPeople.first.name, 'Priya');
      expect(enrollmentService.enrolledPeople.first.relationship, 'Mom');
    });

    test('4. Local persistence across service instances', () async {
      final tempDir = Directory.systemTemp.createTempSync('face_test_');
      final filePath = '${tempDir.path}/test_enrolled.json';

      try {
        final service1 = FaceEnrollmentService(storagePath: filePath);
        await service1.initialize();
        expect(service1.enrolledPeople, isEmpty);

        final person1 = EnrolledPerson(
          id: 'p1',
          name: 'Priya',
          relationship: PersonRelationship.mom,
          enrolledAt: DateTime(2026),
        );
        await service1.enrollPerson(person1);
        expect(service1.enrolledPeople, hasLength(1));

        // Create new instance pointing to same file to verify persistence
        final service2 = FaceEnrollmentService(storagePath: filePath);
        await service2.initialize();
        expect(service2.enrolledPeople, hasLength(1));
        expect(service2.enrolledPeople.first.id, 'p1');
        expect(service2.enrolledPeople.first.name, 'Priya');

        // Delete from service2
        await service2.deletePerson('p1');
        expect(service2.enrolledPeople, isEmpty);

        // Verify deletion persisted
        final service3 = FaceEnrollmentService(storagePath: filePath);
        await service3.initialize();
        expect(service3.enrolledPeople, isEmpty);
      } finally {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      }
    });

    test('5. Profile listing and deletion in memory', () async {
      await enrollmentService.initialize();
      final person1 = EnrolledPerson(
        id: 'p1',
        name: 'Priya',
        relationship: PersonRelationship.mom,
        enrolledAt: DateTime(2026),
      );
      final person2 = EnrolledPerson(
        id: 'p2',
        name: 'Raj',
        relationship: PersonRelationship.dad,
        enrolledAt: DateTime(2026),
      );

      await enrollmentService.enrollPerson(person1);
      await enrollmentService.enrollPerson(person2);
      expect(enrollmentService.enrolledPeople, hasLength(2));

      await enrollmentService.deletePerson('p1');
      expect(enrollmentService.enrolledPeople, hasLength(1));
      expect(enrollmentService.enrolledPeople.first.name, 'Raj');
    });

    test('6. Unknown-person result state (face detected without reliable match)', () {
      final result = FaceDetectionResult(
        faces: const [DetectedFace(boundingBox: _box)],
        analysedAt: DateTime(2026),
      );

      expect(result.hasFaces, isTrue);
      expect(result.isKnownPerson, isFalse);
      expect(result.summary, 'Person detected');
      expect(result.subtitle, 'Identity not confirmed');
    });

    test('7. Known-match result state', () {
      final person = EnrolledPerson(
        id: 'p1',
        name: 'Priya',
        relationship: 'Mom',
        enrolledAt: DateTime(2026),
      );
      final result = FaceDetectionResult(
        faces: const [DetectedFace(boundingBox: _box)],
        matchedPerson: person,
        analysedAt: DateTime(2026),
      );

      expect(result.hasFaces, isTrue);
      expect(result.isKnownPerson, isTrue);
      expect(result.summary, 'Hello, Priya');
      expect(result.subtitle, 'Mom');
    });

    test('8. No-face result state', () {
      final result = FaceDetectionResult.empty();
      expect(result.hasFaces, isFalse);
      expect(result.isKnownPerson, isFalse);
      expect(result.summary, 'No person detected');
      expect(result.subtitle, 'Move closer and make sure your face is visible.');
    });

    test('9. Mocked face recognition via FaceMatcher', () {
      final matchedPerson = EnrolledPerson(
        id: 'p1',
        name: 'Priya',
        relationship: PersonRelationship.mom,
        enrolledAt: DateTime(2026),
      );

      final serviceWithMatcher = FaceEnrollmentService(
        matcher: (face, enrolled) => matchedPerson,
      );

      const face = DetectedFace(boundingBox: _box);
      final matched = serviceWithMatcher.matchFace(face);
      expect(matched, isNotNull);
      expect(matched?.name, 'Priya');
      expect(matched?.relationship, 'Mom');
    });

    test('10. Default production matchFace returns null without faking matching', () {
      final defaultService = FaceEnrollmentService();
      const face = DetectedFace(boundingBox: _box);
      expect(defaultService.matchFace(face), isNull);
    });
  });

  group('Enrollment Dialog UI Tests', () {
    testWidgets('requires consent before save button is enabled', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      EnrolledPerson? savedPerson;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnrollPersonDialog(
              detectedFace: const DetectedFace(boundingBox: _box),
              onSave: (p) => savedPerson = p,
            ),
          ),
        ),
      );

      expect(find.text('Add Person'), findsOneWidget);
      expect(find.textContaining('Privacy Notice'), findsOneWidget);

      final saveButtonFinder = find.byKey(const Key('save-person-button'));
      expect(saveButtonFinder, findsOneWidget);

      final saveButtonWidget = tester.widget<FilledButton>(saveButtonFinder);
      expect(saveButtonWidget.onPressed, isNull);

      await tester.tap(find.byKey(const Key('consent-checkbox')));
      await tester.pump();

      await tester.enterText(find.byKey(const Key('person-name-input')), 'Priya');
      await tester.pump();

      final enabledSaveButton = tester.widget<FilledButton>(saveButtonFinder);
      expect(enabledSaveButton.onPressed, isNotNull);

      await tester.tap(saveButtonFinder);
      await tester.pumpAndSettle();

      expect(savedPerson, isNotNull);
      expect(savedPerson?.name, 'Priya');
      expect(savedPerson?.relationship, 'Mom');
    });

    testWidgets('name validation prevents saving empty name', (tester) async {
      EnrolledPerson? savedPerson;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnrollPersonDialog(
              detectedFace: const DetectedFace(boundingBox: _box),
              onSave: (p) => savedPerson = p,
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('consent-checkbox')));
      await tester.pump();

      await tester.tap(find.byKey(const Key('save-person-button')));
      await tester.pump();

      expect(find.text('Please enter a name'), findsOneWidget);
      expect(savedPerson, isNull);
    });

    testWidgets('relationship selection dropdown works correctly', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      EnrolledPerson? savedPerson;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnrollPersonDialog(
              detectedFace: const DetectedFace(boundingBox: _box),
              onSave: (p) => savedPerson = p,
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('consent-checkbox')));
      await tester.enterText(find.byKey(const Key('person-name-input')), 'Sarah');
      await tester.pump();

      // Tap dropdown to select Caregiver
      await tester.tap(find.byKey(const Key('person-relationship-dropdown')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Caregiver').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('save-person-button')));
      await tester.pumpAndSettle();

      expect(savedPerson, isNotNull);
      expect(savedPerson?.name, 'Sarah');
      expect(savedPerson?.relationship, 'Caregiver');
    });

    testWidgets('allows deleting enrolled profile from ManagePeopleDialog', (tester) async {
      String? deletedId;
      final people = [
        EnrolledPerson(id: 'p1', name: 'Priya', relationship: 'Mom', enrolledAt: DateTime(2026)),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ManagePeopleDialog(
              people: people,
              onDelete: (id) => deletedId = id,
            ),
          ),
        ),
      );

      expect(find.text('Family & Care Team'), findsOneWidget);
      expect(find.text('Priya'), findsOneWidget);
      expect(find.text('Mom'), findsOneWidget);

      await tester.tap(find.byKey(const Key('delete-person-p1')));
      await tester.pump();

      expect(deletedId, 'p1');
    });

    testWidgets('camera permission failure displays guidance', (tester) async {
      camera.initializeFailure = const VisionFailure(VisionFailureKind.permissionDenied);

      await tester.pumpWidget(
        MaterialApp(
          home: FaceRecognitionScreen(
            createController: () => FaceRecognitionController(
              camera: camera,
              detector: detector,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Camera access needed'), findsOneWidget);
    });

    testWidgets('processing failure displays guidance and retry option', (tester) async {
      detector.error = const VisionFailure(VisionFailureKind.processingFailed);

      await tester.pumpWidget(
        MaterialApp(
          home: FaceRecognitionScreen(
            createController: () => FaceRecognitionController(
              camera: camera,
              detector: detector,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Check for faces'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Could not check the photo'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });
  });
}
