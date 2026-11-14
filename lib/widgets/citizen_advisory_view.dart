import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/air_quality_brief.dart';
import 'metric_badge.dart';

/// Tab 2: Public-Facing Citizen Advisory
/// Translated into user's chosen language (English, Hindi, Spanish, Regional Simple)
/// and calibrated to reading level (Simple/General vs Detailed),
/// with dedicated precautions for children, older adults, and sensitive groups.
class CitizenAdvisoryView extends StatelessWidget {
  final CivicAirBriefing briefing;

  const CitizenAdvisoryView({
    super.key,
    required this.briefing,
  });

  void _copyToClipboard(BuildContext context) {
    final advisory = briefing.citizenAdvisory;
    final buffer = StringBuffer();
    buffer.writeln(advisory.headline);
    buffer.writeln('-----------------------------');
    buffer.writeln(advisory.plainLanguageAdvisory);
    buffer.writeln('\nHEALTH PRECAUTIONS:');
    buffer.writeln('• Children: ${advisory.vulnerableGroupPrecautions.children}');
    buffer.writeln('• Older Adults: ${advisory.vulnerableGroupPrecautions.olderAdults}');
    buffer.writeln('• Sensitive Groups: ${advisory.vulnerableGroupPrecautions.sensitiveGroups}');
    buffer.writeln('\nDOs:');
    for (var doItem in advisory.generalPublicDosAndDonts.dos) {
      buffer.writeln('✓ $doItem');
    }
    buffer.writeln('\nDONTs:');
    for (var dontItem in advisory.generalPublicDosAndDonts.donts) {
      buffer.writeln('✗ $dontItem');
    }
    buffer.writeln('\nMedical Alert: ${advisory.emergencyHelplinesOrGuidance}');

    Clipboard.setData(ClipboardData(text: buffer.toString()));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Citizen advisory copied to clipboard!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final advisory = briefing.citizenAdvisory;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Headline Banner with Language and Reading Level Badges
          Card(
            elevation: 0,
            color: const Color(0xFF004D40),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      MetricBadge(
                        label: advisory.language.toUpperCase(),
                        color: const Color(0xFF80CBC4),
                        icon: Icons.language_rounded,
                        isFilled: false,
                      ),
                      const SizedBox(width: 8),
                      MetricBadge(
                        label: advisory.readingLevel,
                        color: const Color(0xFFB2DFDB),
                        icon: Icons.auto_stories_rounded,
                        isFilled: false,
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        label: const Text('Copy Advisory'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF004D40),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () => _copyToClipboard(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    advisory.headline,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    advisory.plainLanguageAdvisory,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.95),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 2. Vulnerable Group Precautions Card (Children, Older Adults, Sensitive Groups)
          _buildVulnerableGroupsCard(theme, advisory.vulnerableGroupPrecautions),
          const SizedBox(height: 16),

          // 3. Do's and Don'ts Card
          _buildDosAndDontsCard(theme, advisory.generalPublicDosAndDonts),
          const SizedBox(height: 16),

          // 4. Medical Red Flags & Emergency Guidance
          _buildEmergencyGuidanceCard(theme, advisory.emergencyHelplinesOrGuidance),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Builds dedicated precautions for children, older adults, and sensitive groups
  Widget _buildVulnerableGroupsCard(ThemeData theme, VulnerablePrecautions precautions) {
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
                const Icon(Icons.health_and_safety_rounded, color: Color(0xFFD84315), size: 22),
                const SizedBox(width: 8),
                Text(
                  'Dedicated Precautions for Sensitive Groups',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Specific behavioral and medical safeguards tailored to physiological vulnerability.',
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 14),

            // Children Precautions
            _buildVulnerableItem(
              icon: Icons.child_care_rounded,
              title: 'Children & Students',
              color: const Color(0xFFE65100),
              content: precautions.children,
              theme: theme,
            ),
            const SizedBox(height: 10),

            // Older Adults Precautions
            _buildVulnerableItem(
              icon: Icons.elderly_rounded,
              title: 'Older Adults & Senior Citizens',
              color: const Color(0xFF4527A0),
              content: precautions.olderAdults,
              theme: theme,
            ),
            const SizedBox(height: 10),

            // Respiratory & Cardiac Patients
            _buildVulnerableItem(
              icon: Icons.medical_services_rounded,
              title: 'Sensitive Groups (Asthma, COPD, Cardiac)',
              color: const Color(0xFFC2185B),
              content: precautions.sensitiveGroups,
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVulnerableItem({
    required IconData icon,
    required String title,
    required Color color,
    required String content,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(fontSize: 12.5, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the Dos and Don'ts comparison matrix
  Widget _buildDosAndDontsCard(ThemeData theme, DosAndDonts dosAndDonts) {
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
                const Icon(Icons.checklist_rounded, color: Color(0xFF2E7D32), size: 22),
                const SizedBox(width: 8),
                Text(
                  'Community Actions: Do\'s and Don\'ts',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // DOs column
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFC8E6C9)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.check_circle_outline, color: Color(0xFF2E7D32), size: 18),
                            SizedBox(width: 6),
                            Text(
                              'RECOMMENDED (DO)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B5E20),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...dosAndDonts.dos.map(
                          (item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF1B5E20), height: 1.3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // DONTs column
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFCDD2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.cancel_outlined, color: Color(0xFFC62828), size: 18),
                            SizedBox(width: 6),
                            Text(
                              'AVOID STRICTLY (DON\'T)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFB71C1C),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...dosAndDonts.donts.map(
                          (item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC62828))),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: const TextStyle(fontSize: 12, color: Color(0xFFB71C1C), height: 1.3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds emergency medical guidance and red flag alert box
  Widget _buildEmergencyGuidanceCard(ThemeData theme, String guidance) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1), // Warm amber tint
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFE082), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.medical_information_rounded, color: Color(0xFFF57F17), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Medical Alert & Symptom Warning',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE65100),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  guidance,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF5D4037),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
