import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../backend/data/firestore_caregiver_service.dart';
import '../../backend/data/firestore_emergency_event_service.dart';
import '../../backend/data/firestore_user_repository.dart';
import '../../backend/repositories/caregiver_repository.dart';
import '../../backend/repositories/emergency_event_repository.dart';
import '../../backend/repositories/user_repository.dart';
import '../../emergency/models/emergency_event_model.dart';
import '../models/alert_model.dart';
import '../models/caregiver_model.dart';
import '../models/caregiver_relationship_model.dart';
import '../models/family_member_model.dart';
import '../models/health_summary_model.dart';
import '../models/patient_status_model.dart';

class CaregiverService {
  CaregiverService._private() {
    _init();
  }

  static final CaregiverService instance = CaregiverService._private();

  CaregiverModel caregiver = CaregiverModel(
    id: '',
    name: 'Caregiver',
    phone: '',
    role: 'Primary Caregiver',
  );

  final List<PatientStatusModel> patients = [];
  final Map<String, HealthSummaryModel> health = {};
  final List<AlertModel> alerts = [];
  final List<FamilyMemberModel> family = [];
  final List<CaregiverRelationshipModel> relationshipLinks = [];

  FirebaseAuth? get _authInstance {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  User? get _currentUser {
    try {
      return _authInstance?.currentUser;
    } catch (_) {
      return null;
    }
  }

  final CaregiverRepository _repo = FirestoreCaregiverService();
  final UserRepository _userRepo = FirestoreUserRepository();
  final EmergencyEventRepository _emergencyRepo =
      FirestoreEmergencyEventService();

  StreamSubscription<List<AlertModel>>? _alertsSub;
  StreamSubscription<CaregiverModel?>? _profileSub;
  StreamSubscription<List<CaregiverRelationshipModel>>? _linksSub;
  StreamSubscription<List<FamilyMemberModel>>? _familySub;
  final Map<String, StreamSubscription<List<EmergencyEventModel>>>
  _patientEmergencySubs = {};

  final StreamController<List<AlertModel>> _streamController =
      StreamController<List<AlertModel>>.broadcast();

  final StreamController<List<PatientStatusModel>> _patientsStreamController =
      StreamController<List<PatientStatusModel>>.broadcast();

  final StreamController<List<FamilyMemberModel>> _familyStreamController =
      StreamController<List<FamilyMemberModel>>.broadcast();

  Stream<List<AlertModel>> get stream => _streamController.stream;
  Stream<List<PatientStatusModel>> get patientsStream =>
      _patientsStreamController.stream;
  Stream<List<FamilyMemberModel>> get familyStream =>
      _familyStreamController.stream;

  void _notify() {
    _streamController.add(List.unmodifiable(alerts));
    _patientsStreamController.add(List.unmodifiable(patients));
    _familyStreamController.add(List.unmodifiable(family));
  }

  void _clearEmergencySubs() {
    for (final sub in _patientEmergencySubs.values) {
      sub.cancel();
    }
    _patientEmergencySubs.clear();
  }

  void _init() {
    final auth = _authInstance;
    if (auth == null) {
      initMock();
      return;
    }
    auth.authStateChanges().listen((user) async {
      _alertsSub?.cancel();
      _profileSub?.cancel();
      _linksSub?.cancel();
      _familySub?.cancel();
      _clearEmergencySubs();
      alerts.clear();
      patients.clear();
      family.clear();
      relationshipLinks.clear();

      if (user != null) {
        final resolvedName =
            user.displayName != null && user.displayName!.trim().isNotEmpty
            ? user.displayName!.trim()
            : user.email != null && user.email!.trim().isNotEmpty
            ? user.email!.split('@').first
            : 'Caregiver';

        caregiver = CaregiverModel(
          id: user.uid,
          name: resolvedName,
          phone: user.phoneNumber ?? '',
          role: 'Primary Caregiver',
        );

        _familySub = _repo
            .streamFamilyMembers(user.uid)
            .listen(
              (list) {
                family
                  ..clear()
                  ..addAll(list);
                _notify();
              },
              onError: (error, stackTrace) {
                debugPrint(
                  '[CaregiverService] Family members stream error: $error\n$stackTrace',
                );
                _notify();
              },
            );

        _alertsSub = _repo
            .streamAlertsForUser(user.uid)
            .listen(
              (list) {
                final pendingLocalAlerts = alerts
                    .where(
                      (a) =>
                          a.id.startsWith('sos_') &&
                          !list.any((item) => item.id == a.id),
                    )
                    .toList();
                alerts
                  ..clear()
                  ..addAll(list);
                for (final pending in pendingLocalAlerts) {
                  if (!alerts.any((a) => a.id == pending.id)) {
                    alerts.insert(0, pending);
                  }
                }
                _notify();
              },
              onError: (error, stackTrace) {
                debugPrint(
                  '[CaregiverService] Caregiver alerts stream error: $error\n$stackTrace',
                );
                _notify();
              },
            );

        _profileSub = _repo
            .streamCaregiverProfile(user.uid)
            .listen(
              (profile) {
                if (profile != null) {
                  caregiver = profile;
                }
                _notify();
              },
              onError: (error, stackTrace) {
                debugPrint(
                  '[CaregiverService] Caregiver profile stream error: $error\n$stackTrace',
                );
                _notify();
              },
            );

        _linksSub = _repo
            .streamPatientLinks(user.uid)
            .listen(
              (links) async {
                relationshipLinks
                  ..clear()
                  ..addAll(links);

                _clearEmergencySubs();

                final List<PatientStatusModel> updatedPatients = [];
                for (final link in links) {
                  if (link.patientId.isEmpty) continue;

                  dynamic pModel;
                  try {
                    pModel = await _userRepo.getById(link.patientId);
                  } catch (e, stackTrace) {
                    debugPrint(
                      '[CaregiverService] Error fetching profile for ${link.patientId}: $e\n$stackTrace',
                    );
                  }

                  final String pName =
                      (pModel != null && pModel.fullName.isNotEmpty)
                      ? pModel.fullName
                      : 'Patient ${link.patientId}';

                  updatedPatients.add(
                    PatientStatusModel(
                      patientId: link.patientId,
                      name: pName,
                      avatarUrl: pModel?.photoUrl ?? '',
                      lastActive: DateTime.now(),
                      location: 'Home',
                      online: true,
                    ),
                  );

                  // Subscribe to real emergency events for linked patient
                  _patientEmergencySubs[link.patientId] = _emergencyRepo
                      .streamForUser(link.patientId)
                      .listen(
                        (events) async {
                          for (final ev in events) {
                            final alertId = 'sos_${ev.id}';
                            final existingLocal = alerts.any(
                              (a) => a.id == alertId,
                            );
                            if (existingLocal) {
                              continue;
                            }
                            final user = _currentUser;
                            if (user != null) {
                              final remoteAlerts = await _repo.getAlerts(
                                user.uid,
                              );
                              final existingRemote = remoteAlerts.firstWhere(
                                (a) => a.id == alertId,
                                orElse: () => AlertModel(id: '', title: ''),
                              );
                              if (existingRemote.id.isNotEmpty) {
                                if (!alerts.any(
                                  (a) => a.id == existingRemote.id,
                                )) {
                                  alerts.insert(0, existingRemote);
                                  _notify();
                                }
                                continue;
                              }
                            }
                            final eventTime = ev.time ?? DateTime.now();
                            final timeIso = eventTime.toIso8601String();
                            final timeDisplay = timeIso.length >= 16
                                ? timeIso.substring(11, 16)
                                : timeIso;
                            final newAlert = AlertModel(
                              id: alertId,
                              title: '🚨 SOS EMERGENCY ALERT - $pName',
                              type: AlertType.fall,
                              details: '${ev.details} (Time: $timeDisplay)',
                              time: eventTime,
                              severity: 5,
                              isRead: false,
                              isDismissed: false,
                              patientId: link.patientId,
                            );
                            await addAlert(newAlert);
                          }
                        },
                        onError: (error, stackTrace) {
                          debugPrint(
                            '[CaregiverService] Emergency stream error for ${link.patientId}: $error\n$stackTrace',
                          );
                        },
                      );
                }

                patients
                  ..clear()
                  ..addAll(updatedPatients);
                _notify();
              },
              onError: (error, stackTrace) {
                debugPrint(
                  '[CaregiverService] Patient links stream error for ${user.uid}: $error\n$stackTrace',
                );
                _notify();
              },
            );
      } else {
        caregiver = CaregiverModel(
          id: '',
          name: 'Caregiver',
          phone: '',
          role: 'Primary Caregiver',
        );
        // Fallback mock alerts for unauthenticated / demo mode
        alerts.addAll([
          AlertModel(
            id: 'a1',
            title: 'Missed Medication - Amlodipine',
            type: AlertType.missedMedication,
            details: 'Missed at 08:30',
            time: DateTime.now().subtract(const Duration(hours: 3)),
            severity: 3,
          ),
          AlertModel(
            id: 'a2',
            title: 'Low Activity',
            type: AlertType.lowActivity,
            details: 'No movement detected for 12 hours',
            time: DateTime.now().subtract(const Duration(hours: 6)),
            severity: 2,
          ),
        ]);

        patients.addAll([
          PatientStatusModel(
            patientId: 'p1',
            name: 'Rudra Kumar',
            avatarUrl: '',
            lastActive: DateTime.now().subtract(const Duration(minutes: 5)),
            location: 'Home',
            online: true,
          ),
          PatientStatusModel(
            patientId: 'p2',
            name: 'Asha Devi',
            avatarUrl: '',
            lastActive: DateTime.now().subtract(const Duration(hours: 2)),
            location: 'Clinic',
            online: false,
          ),
        ]);
        _notify();
      }
    });

    if (family.isEmpty) {
      health['p1'] = HealthSummaryModel(
        heartRate: 72,
        bpSystolic: 130,
        bpDiastolic: 82,
        spo2: 97,
        sleepHours: 7.0,
      );
      health['p2'] = HealthSummaryModel(
        heartRate: 78,
        bpSystolic: 125,
        bpDiastolic: 80,
        spo2: 98,
        sleepHours: 6.5,
      );

      family.addAll([
        FamilyMemberModel(
          id: 'f1',
          name: 'Sunita Sharma',
          relationship: 'Daughter',
          phone: '+91 91111 11111',
          role: 'Primary',
        ),
        FamilyMemberModel(
          id: 'f2',
          name: 'Amit Kumar',
          relationship: 'Son',
          phone: '+91 92222 22222',
          role: 'Secondary',
        ),
      ]);
    }
  }

  void initMock() {
    // Preserved for backward compatibility
  }

  List<PatientStatusModel> getPatients() {
    return List.unmodifiable(patients);
  }

  HealthSummaryModel? getHealth(String patientId) => health[patientId];
  List<AlertModel> getAlerts() =>
      List.unmodifiable(alerts.where((a) => !a.isDismissed).toList());
  List<FamilyMemberModel> getFamily() => List.unmodifiable(family);
  List<CaregiverRelationshipModel> getRelationshipLinks() =>
      List.unmodifiable(relationshipLinks);

  Future<void> linkPatient(
    String patientId, {
    String relationship = 'Primary Caregiver',
  }) async {
    final user = _currentUser;
    if (user != null) {
      await _repo.linkPatient(user.uid, patientId, relationship: relationship);
    }
  }

  Future<void> unlinkPatient(String patientId) async {
    final user = _currentUser;
    if (user != null) {
      await _repo.unlinkPatient(user.uid, patientId);
    }
  }

  Future<void> dismissAlert(String id) async {
    final idx = alerts.indexWhere((a) => a.id == id);
    if (idx >= 0) {
      alerts[idx].isDismissed = true;
      _notify();
      final user = _currentUser;
      if (user != null) {
        await _repo.updateAlert(user.uid, alerts[idx]);
      }
    }
  }

  Future<void> markAlertRead(String id) async {
    final idx = alerts.indexWhere((a) => a.id == id);
    if (idx >= 0) {
      alerts[idx].isRead = true;
      _notify();
      final user = _currentUser;
      if (user != null) {
        await _repo.updateAlert(user.uid, alerts[idx]);
      }
    }
  }

  Future<void> addAlert(AlertModel alert) async {
    final idx = alerts.indexWhere((a) => a.id == alert.id);
    if (idx >= 0) {
      alerts[idx] = alert;
    } else {
      alerts.insert(0, alert);
    }
    _notify();
    final user = _currentUser;
    if (user != null) {
      try {
        await _repo.addAlert(user.uid, alert);
      } catch (e, stackTrace) {
        debugPrint(
          '[CaregiverService] Error adding alert ${alert.id}: $e\n$stackTrace',
        );
      }
    }
  }

  Future<void> updateCaregiverProfile(CaregiverModel profile) async {
    caregiver = profile;
    _notify();
    final user = _currentUser;
    if (user != null) {
      await _repo.saveCaregiverProfile(user.uid, profile);
    }
  }

  Future<void> addFamilyMember(FamilyMemberModel member) async {
    final idx = family.indexWhere((m) => m.id == member.id);
    if (idx >= 0) {
      family[idx] = member;
    } else {
      family.add(member);
    }
    _notify();
    final user = _currentUser;
    if (user != null) {
      await _repo.addFamilyMember(user.uid, member);
    }
  }

  Future<void> updateFamilyMember(FamilyMemberModel member) async {
    final idx = family.indexWhere((m) => m.id == member.id);
    if (idx >= 0) {
      family[idx] = member;
    } else {
      family.add(member);
    }
    _notify();
    final user = _currentUser;
    if (user != null) {
      await _repo.updateFamilyMember(user.uid, member);
    }
  }

  Future<void> deleteFamilyMember(String memberId) async {
    family.removeWhere((m) => m.id == memberId);
    _notify();
    final user = _currentUser;
    if (user != null) {
      await _repo.deleteFamilyMember(user.uid, memberId);
    }
  }
}
