import 'package:flutter/material.dart';
import '../../../core/constants/spacing.dart';
import '../models/enrolled_person.dart';
import '../models/face_detection_result.dart';

/// Modal dialog for enrolling a new person into local face recognition.
/// Strictly requires explicit user consent and explicit relationship selection.
class EnrollPersonDialog extends StatefulWidget {
  const EnrollPersonDialog({
    super.key,
    required this.detectedFace,
    required this.onSave,
  });

  final DetectedFace detectedFace;
  final ValueChanged<EnrolledPerson> onSave;

  @override
  State<EnrollPersonDialog> createState() => _EnrollPersonDialogState();
}

class _EnrollPersonDialogState extends State<EnrollPersonDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String _selectedRelationship = PersonRelationship.mom;
  bool _hasConsented = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_hasConsented) return;
    final isValid = _formKey.currentState?.validate() ?? false;
    setState(() {});
    if (!isValid) return;

    final name = _nameController.text.trim();
    final person = EnrolledPerson(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      relationship: _selectedRelationship,
      enrolledAt: DateTime.now(),
    );

    widget.onSave(person);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final scheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Person',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Face detected successfully. Save this person to help NeuroEase identify them for you.',
                style: textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.md),

              // Privacy & Consent Box
              Material(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.privacy_tip_outlined, color: scheme.primary),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'Privacy Notice',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Face recognition helps NeuroEase recognize people you choose. '
                        'Your enrollment data is stored locally on this device.',
                        style: textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      CheckboxListTile(
                        key: const Key('consent-checkbox'),
                        contentPadding: EdgeInsets.zero,
                        value: _hasConsented,
                        onChanged: (val) => setState(() => _hasConsented = val ?? false),
                        title: Text(
                          'I understand and consent to saving this person\'s recognition data.',
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Person Name Input
              Text(
                'Person Name',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextFormField(
                key: const Key('person-name-input'),
                controller: _nameController,
                style: textTheme.titleMedium,
                decoration: const InputDecoration(
                  hintText: 'e.g. Priya or John',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Relationship Dropdown Selector
              Text(
                'Relationship',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.xs),
              DropdownButtonFormField<String>(
                key: const Key('person-relationship-dropdown'),
                initialValue: _selectedRelationship,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: PersonRelationship.all.map((rel) {
                  return DropdownMenuItem<String>(
                    value: rel,
                    child: Text(rel, style: textTheme.titleMedium),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedRelationship = val);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    key: const Key('cancel-enrollment-button'),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton(
                    key: const Key('save-person-button'),
                    onPressed: _hasConsented ? _submit : null,
                    child: const Text('Save Person'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
