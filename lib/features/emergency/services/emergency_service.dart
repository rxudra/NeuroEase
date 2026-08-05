import '../models/emergency_contact_model.dart';
import '../models/emergency_event_model.dart';
import '../models/emergency_status_model.dart';

class EmergencyService {
  EmergencyService._private();
  static final EmergencyService instance = EmergencyService._private();

  final List<EmergencyContactModel> contacts = [];
  final List<EmergencyEventModel> events = [];
  EmergencyStatusModel status = EmergencyStatusModel();

  void initMock() {
    if (contacts.isNotEmpty) return;
    contacts.addAll([
      EmergencyContactModel(
        id: 'c1',
        name: 'Priya Sharma',
        relationship: 'Daughter',
        phone: '+91 91111 11111',
        priority: 1,
      ),
      EmergencyContactModel(
        id: 'c2',
        name: 'Amit Kumar',
        relationship: 'Son',
        phone: '+91 92222 22222',
        priority: 2,
      ),
    ]);

    events.addAll([
      EmergencyEventModel(
        id: 'e1',
        type: EmergencyEventType.sosTriggered,
        title: 'SOS Triggered',
        details: 'User held SOS',
        time: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      EmergencyEventModel(
        id: 'e2',
        type: EmergencyEventType.locationShared,
        title: 'Location Shared',
        details: 'Shared to emergency contacts',
        time: DateTime.now().subtract(const Duration(hours: 1, minutes: 40)),
      ),
    ]);
  }

  List<EmergencyContactModel> getContacts() => List.unmodifiable(contacts);
  List<EmergencyEventModel> getEvents() => List.unmodifiable(events);

  void addEvent(EmergencyEventModel e) => events.add(e);
  void addContact(EmergencyContactModel c) => contacts.add(c);
  void removeContact(String id) => contacts.removeWhere((c) => c.id == id);

  void setStatus(EmergencyStatusModel s) => status = s;
}
