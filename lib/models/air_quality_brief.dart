import 'package:flutter/material.dart';

/// Top-level model representing the complete AI-generated briefing.
/// Strict JSON schema guarantees every field is populated by Gemini 3.8 Flash.
class CivicAirBriefing {
  final String summary;
  final int overallAqiEstimate;
  final String overallRiskLevel;
  final double confidenceScore;
  final List<HotspotItem> hotspots;
  final DataQualityAudit dataQualityAudit;
  final RoleActionPlan roleSpecificActionPlan;
  final ProgressComparison progressComparison;
  final CitizenAdvisory citizenAdvisory;

  const CivicAirBriefing({
    required this.summary,
    required this.overallAqiEstimate,
    required this.overallRiskLevel,
    required this.confidenceScore,
    required this.hotspots,
    required this.dataQualityAudit,
    required this.roleSpecificActionPlan,
    required this.progressComparison,
    required this.citizenAdvisory,
  });

  factory CivicAirBriefing.fromJson(Map<String, dynamic> json) {
    return CivicAirBriefing(
      summary: json['summary'] as String? ?? 'No executive summary provided.',
      overallAqiEstimate: (json['overallAqiEstimate'] as num?)?.toInt() ?? 100,
      overallRiskLevel: json['overallRiskLevel'] as String? ?? 'Moderate',
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.85,
      hotspots: (json['hotspots'] as List<dynamic>?)
              ?.map((e) => HotspotItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      dataQualityAudit: DataQualityAudit.fromJson(
        json['dataQualityAudit'] as Map<String, dynamic>? ?? {},
      ),
      roleSpecificActionPlan: RoleActionPlan.fromJson(
        json['roleSpecificActionPlan'] as Map<String, dynamic>? ?? {},
      ),
      progressComparison: ProgressComparison.fromJson(
        json['progressComparison'] as Map<String, dynamic>? ?? {},
      ),
      citizenAdvisory: CitizenAdvisory.fromJson(
        json['citizenAdvisory'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'summary': summary,
        'overallAqiEstimate': overallAqiEstimate,
        'overallRiskLevel': overallRiskLevel,
        'confidenceScore': confidenceScore,
        'hotspots': hotspots.map((e) => e.toJson()).toList(),
        'dataQualityAudit': dataQualityAudit.toJson(),
        'roleSpecificActionPlan': roleSpecificActionPlan.toJson(),
        'progressComparison': progressComparison.toJson(),
        'citizenAdvisory': citizenAdvisory.toJson(),
      };

  /// UI Color representation based on standard AQI health category
  Color get riskColor {
    final lower = overallRiskLevel.toLowerCase();
    if (lower.contains('good')) return const Color(0xFF2E7D32); // Deep Green
    if (lower.contains('moderate')) return const Color(0xFFF9A825); // Amber/Yellow
    if (lower.contains('sensitive')) return const Color(0xFFEF6C00); // Deep Orange
    if (lower.contains('very unhealthy')) return const Color(0xFF6A1B9A); // Purple
    if (lower.contains('hazardous')) return const Color(0xFF880E4F); // Maroon
    if (lower.contains('unhealthy')) return const Color(0xFFC62828); // Red
    return const Color(0xFFE65100);
  }
}

/// Hotspot item with strict traceability back to the exact row/sensor/timestamp.
class HotspotItem {
  final String locationOrSensor;
  final String peakPollutant;
  final String peakValue;
  final String timestampOrPeriod;
  final String citationRef;
  final String severity;
  final String contributingFactors;

  const HotspotItem({
    required this.locationOrSensor,
    required this.peakPollutant,
    required this.peakValue,
    required this.timestampOrPeriod,
    required this.citationRef,
    required this.severity,
    required this.contributingFactors,
  });

  factory HotspotItem.fromJson(Map<String, dynamic> json) {
    return HotspotItem(
      locationOrSensor: json['locationOrSensor'] as String? ?? 'Unknown Location',
      peakPollutant: json['peakPollutant'] as String? ?? 'PM2.5',
      peakValue: json['peakValue'] as String? ?? 'N/A',
      timestampOrPeriod: json['timestampOrPeriod'] as String? ?? 'N/A',
      citationRef: json['citationRef'] as String? ?? 'Raw telemetry log',
      severity: json['severity'] as String? ?? 'Moderate',
      contributingFactors: json['contributingFactors'] as String? ?? 'General ambient pollution',
    );
  }

  Map<String, dynamic> toJson() => {
        'locationOrSensor': locationOrSensor,
        'peakPollutant': peakPollutant,
        'peakValue': peakValue,
        'timestampOrPeriod': timestampOrPeriod,
        'citationRef': citationRef,
        'severity': severity,
        'contributingFactors': contributingFactors,
      };

  Color get severityColor {
    switch (severity.toLowerCase()) {
      case 'critical':
        return const Color(0xFFB71C1C);
      case 'elevated':
        return const Color(0xFFE65100);
      case 'moderate':
        return const Color(0xFFF57F17);
      case 'low':
      default:
        return const Color(0xFF2E7D32);
    }
  }
}

/// Audit report on raw telemetry inconsistencies, unit mismatches, and sensor dropouts.
class DataQualityAudit {
  final int totalRecordsAnalyzed;
  final int unreliableOrMissingPoints;
  final List<String> unitConversionsApplied;
  final List<DataAnomaly> flaggedAnomalies;

  const DataQualityAudit({
    required this.totalRecordsAnalyzed,
    required this.unreliableOrMissingPoints,
    required this.unitConversionsApplied,
    required this.flaggedAnomalies,
  });

  factory DataQualityAudit.fromJson(Map<String, dynamic> json) {
    return DataQualityAudit(
      totalRecordsAnalyzed: (json['totalRecordsAnalyzed'] as num?)?.toInt() ?? 0,
      unreliableOrMissingPoints: (json['unreliableOrMissingPoints'] as num?)?.toInt() ?? 0,
      unitConversionsApplied: (json['unitConversionsApplied'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      flaggedAnomalies: (json['flaggedAnomalies'] as List<dynamic>?)
              ?.map((e) => DataAnomaly.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'totalRecordsAnalyzed': totalRecordsAnalyzed,
        'unreliableOrMissingPoints': unreliableOrMissingPoints,
        'unitConversionsApplied': unitConversionsApplied,
        'flaggedAnomalies': flaggedAnomalies.map((e) => e.toJson()).toList(),
      };
}

/// Individual data anomaly or sensor failure flag
class DataAnomaly {
  final String sensorOrRow;
  final String issueType;
  final String details;

  const DataAnomaly({
    required this.sensorOrRow,
    required this.issueType,
    required this.details,
  });

  factory DataAnomaly.fromJson(Map<String, dynamic> json) {
    return DataAnomaly(
      sensorOrRow: json['sensorOrRow'] as String? ?? 'General Log',
      issueType: json['issueType'] as String? ?? 'Data Gap',
      details: json['details'] as String? ?? 'Incomplete observation',
    );
  }

  Map<String, dynamic> toJson() => {
        'sensorOrRow': sensorOrRow,
        'issueType': issueType,
        'details': details,
      };
}

/// Role-specific operational action plan
class RoleActionPlan {
  final String targetRole;
  final List<RoleActionItem> immediateActions;
  final List<RoleActionItem> mediumTermInterventions;
  final List<String> resourceChecklist;

  const RoleActionPlan({
    required this.targetRole,
    required this.immediateActions,
    required this.mediumTermInterventions,
    required this.resourceChecklist,
  });

  factory RoleActionPlan.fromJson(Map<String, dynamic> json) {
    return RoleActionPlan(
      targetRole: json['targetRole'] as String? ?? 'Ward Officer',
      immediateActions: (json['immediateActions'] as List<dynamic>?)
              ?.map((e) => RoleActionItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      mediumTermInterventions: (json['mediumTermInterventions'] as List<dynamic>?)
              ?.map((e) => RoleActionItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      resourceChecklist: (json['resourceChecklist'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'targetRole': targetRole,
        'immediateActions': immediateActions.map((e) => e.toJson()).toList(),
        'mediumTermInterventions': mediumTermInterventions.map((e) => e.toJson()).toList(),
        'resourceChecklist': resourceChecklist,
      };
}

/// Prioritized intervention item
class RoleActionItem {
  final String title;
  final String priority;
  final String description;
  final String expectedImpact;

  const RoleActionItem({
    required this.title,
    required this.priority,
    required this.description,
    required this.expectedImpact,
  });

  factory RoleActionItem.fromJson(Map<String, dynamic> json) {
    return RoleActionItem(
      title: json['title'] as String? ?? 'Civic Action',
      priority: json['priority'] as String? ?? 'Medium',
      description: json['description'] as String? ?? '',
      expectedImpact: json['expectedImpact'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'priority': priority,
        'description': description,
        'expectedImpact': expectedImpact,
      };

  Color get priorityColor {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFC62828);
      case 'medium':
        return const Color(0xFFEF6C00);
      case 'low':
      default:
        return const Color(0xFF2E7D32);
    }
  }
}

/// Comparison against previous brief
class ProgressComparison {
  final bool hasPreviousBrief;
  final String overallTrend;
  final List<DiffChangeItem> changes;
  final String comparisonSummary;

  const ProgressComparison({
    required this.hasPreviousBrief,
    required this.overallTrend,
    required this.changes,
    required this.comparisonSummary,
  });

  factory ProgressComparison.fromJson(Map<String, dynamic> json) {
    return ProgressComparison(
      hasPreviousBrief: json['hasPreviousBrief'] as bool? ?? false,
      overallTrend: json['overallTrend'] as String? ?? 'No Baseline Available',
      changes: (json['changes'] as List<dynamic>?)
              ?.map((e) => DiffChangeItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      comparisonSummary: json['comparisonSummary'] as String? ??
          'No prior baseline brief was supplied for automated diffing.',
    );
  }

  Map<String, dynamic> toJson() => {
        'hasPreviousBrief': hasPreviousBrief,
        'overallTrend': overallTrend,
        'changes': changes.map((e) => e.toJson()).toList(),
        'comparisonSummary': comparisonSummary,
      };

  Color get trendColor {
    final lower = overallTrend.toLowerCase();
    if (lower.contains('improved')) return const Color(0xFF2E7D32);
    if (lower.contains('worsened')) return const Color(0xFFC62828);
    if (lower.contains('unchanged') || lower.contains('stable')) return const Color(0xFF1565C0);
    return const Color(0xFF757575);
  }
}

/// Specific diff item comparing current sensor metrics with previous brief
class DiffChangeItem {
  final String metricOrArea;
  final String status;
  final String details;

  const DiffChangeItem({
    required this.metricOrArea,
    required this.status,
    required this.details,
  });

  factory DiffChangeItem.fromJson(Map<String, dynamic> json) {
    return DiffChangeItem(
      metricOrArea: json['metricOrArea'] as String? ?? 'General Area',
      status: json['status'] as String? ?? 'Unchanged',
      details: json['details'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'metricOrArea': metricOrArea,
        'status': status,
        'details': details,
      };

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'improved':
        return const Color(0xFF2E7D32);
      case 'worsened':
        return const Color(0xFFC62828);
      case 'new detection':
        return const Color(0xFF6A1B9A);
      case 'unchanged':
      default:
        return const Color(0xFF546E7A);
    }
  }

  IconData get statusIcon {
    switch (status.toLowerCase()) {
      case 'improved':
        return Icons.trending_down_rounded; // For pollution, down is improved
      case 'worsened':
        return Icons.trending_up_rounded; // Pollution spiked
      case 'new detection':
        return Icons.fiber_new_rounded;
      case 'unchanged':
      default:
        return Icons.trending_flat_rounded;
    }
  }
}

/// Citizen Advisory model translated into chosen language and reading level
class CitizenAdvisory {
  final String headline;
  final String language;
  final String readingLevel;
  final String plainLanguageAdvisory;
  final VulnerablePrecautions vulnerableGroupPrecautions;
  final DosAndDonts generalPublicDosAndDonts;
  final String emergencyHelplinesOrGuidance;

  const CitizenAdvisory({
    required this.headline,
    required this.language,
    required this.readingLevel,
    required this.plainLanguageAdvisory,
    required this.vulnerableGroupPrecautions,
    required this.generalPublicDosAndDonts,
    required this.emergencyHelplinesOrGuidance,
  });

  factory CitizenAdvisory.fromJson(Map<String, dynamic> json) {
    return CitizenAdvisory(
      headline: json['headline'] as String? ?? 'Local Air Quality Notice',
      language: json['language'] as String? ?? 'English',
      readingLevel: json['readingLevel'] as String? ?? 'Simple/General',
      plainLanguageAdvisory: json['plainLanguageAdvisory'] as String? ?? '',
      vulnerableGroupPrecautions: VulnerablePrecautions.fromJson(
        json['vulnerableGroupPrecautions'] as Map<String, dynamic>? ?? {},
      ),
      generalPublicDosAndDonts: DosAndDonts.fromJson(
        json['generalPublicDosAndDonts'] as Map<String, dynamic>? ?? {},
      ),
      emergencyHelplinesOrGuidance: json['emergencyHelplinesOrGuidance'] as String? ??
          'Seek immediate medical care if experiencing severe shortness of breath or persistent chest pain.',
    );
  }

  Map<String, dynamic> toJson() => {
        'headline': headline,
        'language': language,
        'readingLevel': readingLevel,
        'plainLanguageAdvisory': plainLanguageAdvisory,
        'vulnerableGroupPrecautions': vulnerableGroupPrecautions.toJson(),
        'generalPublicDosAndDonts': generalPublicDosAndDonts.toJson(),
        'emergencyHelplinesOrGuidance': emergencyHelplinesOrGuidance,
      };
}

/// Dedicated precautions for sensitive and vulnerable groups
class VulnerablePrecautions {
  final String children;
  final String olderAdults;
  final String sensitiveGroups;

  const VulnerablePrecautions({
    required this.children,
    required this.olderAdults,
    required this.sensitiveGroups,
  });

  factory VulnerablePrecautions.fromJson(Map<String, dynamic> json) {
    return VulnerablePrecautions(
      children: json['children'] as String? ??
          'Limit strenuous outdoor play; shift sports activities indoors.',
      olderAdults: json['olderAdults'] as String? ??
          'Avoid early morning walks near major traffic corridors; keep indoor air filtered.',
      sensitiveGroups: json['sensitiveGroups'] as String? ??
          'Keep reliever inhalers at hand; avoid direct exposure to industrial or traffic plumes.',
    );
  }

  Map<String, dynamic> toJson() => {
        'children': children,
        'olderAdults': olderAdults,
        'sensitiveGroups': sensitiveGroups,
      };
}

/// Public action guidance
class DosAndDonts {
  final List<String> dos;
  final List<String> donts;

  const DosAndDonts({
    required this.dos,
    required this.donts,
  });

  factory DosAndDonts.fromJson(Map<String, dynamic> json) {
    return DosAndDonts(
      dos: (json['dos'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      donts: (json['donts'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'dos': dos,
        'donts': donts,
      };
}
