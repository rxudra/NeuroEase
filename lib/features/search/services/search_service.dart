import 'dart:async';

import '../../medication/services/medication_service.dart';
import '../../reminders/services/reminder_service.dart';
import '../../schedule/services/schedule_service.dart';
import '../../profile/services/profile_service.dart';

class SearchResultItem {
  SearchResultItem({
    required this.type,
    required this.title,
    this.subtitle,
    this.payload,
  });

  final String
  type; // e.g., 'Medication', 'Reminder', 'Task', 'Memory', 'Contact'
  final String title;
  final String? subtitle;
  final dynamic payload;
}

class SearchService {
  SearchService._private();
  static final SearchService instance = SearchService._private();

  Future<List<SearchResultItem>> search(String query) async {
    // simulate loading
    await Future.delayed(const Duration(milliseconds: 350));
    final q = query.toLowerCase();

    // ensure mocks initialized
    MedicationService.instance.getAll();
    ReminderService.instance.initMock();
    ScheduleService.instance.initMock();
    ProfileService.instance.initMock();

    final meds = MedicationService.instance.getAll();
    final reminders = ReminderService.instance.getAll();
    final tasks = ScheduleService.instance.getAll();
    final profile = ProfileService.instance.getPatient();

    final results = <SearchResultItem>[];

    for (final m in meds) {
      if (m.name.toLowerCase().contains(q) ||
          m.notes.toLowerCase().contains(q)) {
        results.add(
          SearchResultItem(
            type: 'Medication',
            title: m.name,
            subtitle: m.dosage,
            payload: m,
          ),
        );
      }
    }

    for (final r in reminders) {
      if (r.title.toLowerCase().contains(q) ||
          r.description.toLowerCase().contains(q)) {
        results.add(
          SearchResultItem(
            type: 'Reminder',
            title: r.title,
            subtitle: r.description,
            payload: r,
          ),
        );
      }
    }

    for (final t in tasks) {
      if (t.title.toLowerCase().contains(q) ||
          t.description.toLowerCase().contains(q)) {
        results.add(
          SearchResultItem(
            type: 'Task',
            title: t.title,
            subtitle: t.description,
            payload: t,
          ),
        );
      }
    }

    // memories from profile notes and medications
    if (profile.medications.any((med) => med.toLowerCase().contains(q)) ||
        profile.notes.toLowerCase().contains(q)) {
      results.add(
        SearchResultItem(
          type: 'Profile',
          title: profile.fullName,
          subtitle: profile.notes,
          payload: profile,
        ),
      );
    }

    // emergency contacts
    for (final c in profile.emergencyContacts) {
      if (c.name.toLowerCase().contains(q) ||
          c.relationship.toLowerCase().contains(q)) {
        results.add(
          SearchResultItem(
            type: 'Contact',
            title: c.name,
            subtitle: c.relationship,
            payload: c,
          ),
        );
      }
    }

    return results;
  }
}
