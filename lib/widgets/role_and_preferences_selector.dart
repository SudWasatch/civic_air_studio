import 'package:flutter/material.dart';
import '../models/civic_role.dart';
import '../models/language_reading_level.dart';

/// Interactive configuration panel allowing users to specify:
/// 1. Target Civic Role (Ward Officer, Housing Society, or School)
/// 2. Citizen Advisory Translation Language (English, Hindi, Spanish, Regional Simple)
/// 3. Citizen Advisory Reading Level (Simple/General vs Detailed)
class RoleAndPreferencesSelector extends StatelessWidget {
  final CivicRole selectedRole;
  final ValueChanged<CivicRole> onRoleChanged;

  final AdvisoryLanguage selectedLanguage;
  final ValueChanged<AdvisoryLanguage> onLanguageChanged;

  final ReadingLevel selectedReadingLevel;
  final ValueChanged<ReadingLevel> onReadingLevelChanged;

  const RoleAndPreferencesSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
    required this.selectedLanguage,
    required this.onLanguageChanged,
    required this.selectedReadingLevel,
    required this.onReadingLevelChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.7)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: Color(0xFF1565C0),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '2. Target Role & Advisory Preferences',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        'AI tailors interventions strictly to what the chosen role can execute.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF607D8B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Civic Role Selector
            Text(
              'Select Target Civic Authority:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: CivicRole.values.map((role) {
                final isSelected = role == selectedRole;
                return ChoiceChip(
                  avatar: Icon(
                    role.icon,
                    size: 16,
                    color: isSelected ? Colors.white : const Color(0xFF004D40),
                  ),
                  label: Text(role.shortName),
                  selected: isSelected,
                  selectedColor: const Color(0xFF00796B),
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                  ),
                  onSelected: (selected) {
                    if (selected) onRoleChanged(role);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 10),

            // Contextual banner displaying the selected role's authority and powers
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFB2DFDB)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.verified_user_outlined, size: 16, color: Color(0xFF00695C)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF004D40), height: 1.3),
                        children: [
                          TextSpan(
                            text: '${selectedRole.displayName}: ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: selectedRole.description),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 28),

            // Citizen Advisory Controls
            Text(
              'Citizen Advisory Settings (Public-Facing):',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                DropdownButtonFormField<AdvisoryLanguage>(
                  initialValue: selectedLanguage,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Advisory Language',
                    prefixIcon: const Icon(Icons.translate_rounded, size: 18),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    isDense: true,
                  ),
                  items: AdvisoryLanguage.values.map((lang) {
                    return DropdownMenuItem<AdvisoryLanguage>(
                      value: lang,
                      child: Text(
                        '${lang.displayName} (${lang.nativeLabel})',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    );
                  }).toList(),
                  onChanged: (lang) {
                    if (lang != null) onLanguageChanged(lang);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ReadingLevel>(
                  initialValue: selectedReadingLevel,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Reading Level',
                    prefixIcon: const Icon(Icons.auto_stories_rounded, size: 18),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    isDense: true,
                  ),
                  items: ReadingLevel.values.map((lvl) {
                    return DropdownMenuItem<ReadingLevel>(
                      value: lvl,
                      child: Text(
                        lvl.displayName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    );
                  }).toList(),
                  onChanged: (lvl) {
                    if (lvl != null) onReadingLevelChanged(lvl);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
