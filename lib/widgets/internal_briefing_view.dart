import 'package:flutter/material.dart';
import '../models/air_quality_brief.dart';
import 'metric_badge.dart';

/// Tab 1: Internal Operational Briefing Note for municipal authorities and site administrators.
/// Includes technical telemetry analysis, rigorous citations, data quality audit,
/// role-tailored action matrices, and diffing against past briefs.
class InternalBriefingView extends StatelessWidget {
  final CivicAirBriefing briefing;

  const InternalBriefingView({
    super.key,
    required this.briefing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Executive Summary & AQI Header Card
          _buildAqiOverviewCard(theme),
          const SizedBox(height: 16),

          // 2. Hotspots & Data Traceability Table
          _buildHotspotsCard(theme),
          const SizedBox(height: 16),

          // 3. Data Quality & Sensor Telemetry Audit
          _buildDataQualityAuditCard(theme),
          const SizedBox(height: 16),

          // 4. Role-Specific Action Plan
          _buildRoleActionPlanCard(theme),
          const SizedBox(height: 16),

          // 5. Progress Comparison (Diffing)
          _buildProgressComparisonCard(theme),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Builds the top AQI overview card with risk band, confidence gauge, and plain-language summary
  Widget _buildAqiOverviewCard(ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
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
                // Prominent AQI Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: briefing.riskColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'ESTIMATED AQI',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        '${briefing.overallAqiEstimate}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          MetricBadge(
                            label: briefing.overallRiskLevel,
                            color: briefing.riskColor,
                            isFilled: false,
                          ),
                          const SizedBox(width: 8),
                          MetricBadge(
                            label: 'Confidence ${(briefing.confidenceScore * 100).toStringAsFixed(0)}%',
                            color: const Color(0xFF00796B),
                            icon: Icons.speed_rounded,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Operational Overview',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                briefing.summary,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.45,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the Hotspots & Traceability Table with exact row/sensor/time citations
  Widget _buildHotspotsCard(ThemeData theme) {
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
                const Icon(Icons.pin_drop_rounded, color: Color(0xFFC62828), size: 22),
                const SizedBox(width: 8),
                Text(
                  'Identified Pollution Hotspots & Traceability',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                MetricBadge(
                  label: '${briefing.hotspots.length} Detected',
                  color: const Color(0xFFC62828),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Every hotspot cites the exact row, sensor identifier, and timestamp from raw data.',
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            if (briefing.hotspots.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('No localized hotspots exceeded threshold limits.'),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: briefing.hotspots.length,
                separatorBuilder: (_, _) => const Divider(height: 16),
                itemBuilder: (context, index) {
                  final item = briefing.hotspots[index];
                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: item.severityColor.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: item.severityColor.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            MetricBadge(
                              label: item.severity.toUpperCase(),
                              color: item.severityColor,
                              isFilled: true,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.locationOrSensor,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${item.peakPollutant}: ${item.peakValue}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Color(0xFF263238),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.link_rounded, size: 14, color: Color(0xFF1565C0)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Citation: ${item.citationRef} (${item.timestampOrPeriod})',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1565C0),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Contributing Factor: ${item.contributingFactors}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Builds the Data Quality Audit card flagging dropouts, NaNs, and unit conversions
  Widget _buildDataQualityAuditCard(ThemeData theme) {
    final audit = briefing.dataQualityAudit;

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
                const Icon(Icons.sanitizer_rounded, color: Color(0xFF00796B), size: 22),
                const SizedBox(width: 8),
                Text(
                  'Data Quality & Sensor Health Audit',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                MetricBadge(
                  label: '${audit.totalRecordsAnalyzed} Points Parsed',
                  color: const Color(0xFF00796B),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Explicit verification of missing values, sensor dropouts, and unit harmonizations.',
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),

            // Statistics Bar
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2F1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Valid Points', style: TextStyle(fontSize: 11, color: Color(0xFF004D40))),
                        Text(
                          '${audit.totalRecordsAnalyzed - audit.unreliableOrMissingPoints}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF004D40)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Corrupt / Missing Values', style: TextStyle(fontSize: 11, color: Color(0xFFC62828))),
                        Text(
                          '${audit.unreliableOrMissingPoints}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFC62828)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Unit Conversions Applied
            if (audit.unitConversionsApplied.isNotEmpty) ...[
              Text(
                'Unit Normalizations Applied:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: audit.unitConversionsApplied.map((conv) {
                  return Chip(
                    label: Text(conv, style: const TextStyle(fontSize: 11.5)),
                    backgroundColor: const Color(0xFFE8EAF6),
                    visualDensity: VisualDensity.compact,
                    side: BorderSide.none,
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],

            // Flagged Anomalies Table
            if (audit.flaggedAnomalies.isNotEmpty) ...[
              Text(
                'Flagged Sensor Anomalies & Gaps:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: audit.flaggedAnomalies.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final anomaly = audit.flaggedAnomalies[index];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.warning_amber_rounded, color: Color(0xFFE65100), size: 20),
                      title: Text(
                        '${anomaly.sensorOrRow}: ${anomaly.issueType}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      subtitle: Text(anomaly.details, style: const TextStyle(fontSize: 11.5)),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds the Role-Specific Action Plan Matrix
  Widget _buildRoleActionPlanCard(ThemeData theme) {
    final plan = briefing.roleSpecificActionPlan;

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
                const Icon(Icons.assignment_turned_in_rounded, color: Color(0xFF1565C0), size: 22),
                const SizedBox(width: 8),
                Text(
                  'Role-Specific Action Plan: ${plan.targetRole}',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Prioritized operational mandates restricted to actions within this role\'s executive power.',
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 14),

            // Immediate Actions (0-4 hrs)
            Text(
              'Immediate Interventions (Next 0 - 4 Hours)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade900,
              ),
            ),
            const SizedBox(height: 8),
            ...plan.immediateActions.map((action) => _buildActionItem(action, theme)),

            const SizedBox(height: 14),
            // Medium-Term Interventions (24-72 hrs)
            Text(
              'Medium-Term Interventions (24 - 72 Hours)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            const SizedBox(height: 8),
            ...plan.mediumTermInterventions.map((action) => _buildActionItem(action, theme)),

            // Resource Checklist
            if (plan.resourceChecklist.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                'Required Assets & Resource Checklist',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8E9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFDCEDC8)),
                ),
                child: Column(
                  children: plan.resourceChecklist.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_box_outlined, size: 16, color: Color(0xFF33691E)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF1B5E20)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(RoleActionItem action, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MetricBadge(
                label: action.priority.toUpperCase(),
                color: action.priorityColor,
                isFilled: true,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  action.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            action.description,
            style: const TextStyle(fontSize: 12.5, height: 1.35),
          ),
          if (action.expectedImpact.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.energy_savings_leaf_outlined, size: 14, color: Color(0xFF2E7D32)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Expected Impact: ${action.expectedImpact}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Builds the Progress Comparison (Diffing) Card against previous brief
  Widget _buildProgressComparisonCard(ThemeData theme) {
    final comp = briefing.progressComparison;

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
                const Icon(Icons.compare_arrows_rounded, color: Color(0xFF6A1B9A), size: 22),
                const SizedBox(width: 8),
                Text(
                  'Progress Comparison & Historical Diff',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                MetricBadge(
                  label: comp.overallTrend,
                  color: comp.trendColor,
                  isFilled: true,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              comp.comparisonSummary,
              style: TextStyle(
                fontSize: 12.5,
                color: theme.colorScheme.onSurface,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            if (comp.changes.isEmpty)
              const Text('No itemized diff points generated.', style: TextStyle(fontSize: 12))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: comp.changes.length,
                separatorBuilder: (_, _) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final change = comp.changes[index];
                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: change.statusColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: change.statusColor.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(change.statusIcon, size: 18, color: change.statusColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${change.metricOrArea} • ${change.status}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: change.statusColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                change.details,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
