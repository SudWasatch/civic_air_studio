import 'package:flutter/material.dart';

/// Represents the civic authority or institution receiving the briefing.
/// Interventions are strictly prioritized and scoped to what each role can legally,
/// operationally, and practically execute within their jurisdiction.
enum CivicRole {
  /// Ward Municipal Officer / Urban Local Body
  /// Authority: Road cleaning, mechanical sweepers, smog guns, anti-dust water tankers,
  /// construction stop-work notices, traffic rerouting, waste burning penalties.
  wardOfficer(
    displayName: 'Ward Officer (Urban Local Body)',
    shortName: 'Ward Officer',
    icon: Icons.location_city_rounded,
    description: 'Municipal authority: street sweeping, dust suppression, traffic diversion, and enforcement.',
    scope: 'Municipal Ward / Zonal Jurisdiction',
  ),

  /// Housing Society / Resident Welfare Association (RWA)
  /// Authority: Common area air purifiers, diesel generator restrictions, parking idling bans,
  /// misting systems, resident advisories, balcony vegetation.
  housingSociety(
    displayName: 'Housing Society / RWA',
    shortName: 'Housing Society',
    icon: Icons.apartment_rounded,
    description: 'Residential management: generator controls, resident alerts, common space filtration.',
    scope: 'Gated Communities, Condominiums, Residential Societies',
  ),

  /// School Administration / Educational Campus
  /// Authority: Outdoor recess suspension, sports event rescheduling, indoor air purifiers in classrooms,
  /// bus exhaust mitigation, student health alerts, mask advisories.
  school(
    displayName: 'School Administration',
    shortName: 'School',
    icon: Icons.school_rounded,
    description: 'Educational authority: indoor recess, sports postponement, student transit and mask alerts.',
    scope: 'K-12 Schools, Colleges, and Daycare Campuses',
  );

  final String displayName;
  final String shortName;
  final IconData icon;
  final String description;
  final String scope;

  const CivicRole({
    required this.displayName,
    required this.shortName,
    required this.icon,
    required this.description,
    required this.scope,
  });

  /// Serializes role into a string token for Gemini prompt and schema
  String get apiValue {
    switch (this) {
      case CivicRole.wardOfficer:
        return 'Ward Officer';
      case CivicRole.housingSociety:
        return 'Housing Society';
      case CivicRole.school:
        return 'School';
    }
  }

  /// Deserializes a string from Gemini response or UI parameters
  static CivicRole fromString(String? value) {
    if (value == null) return CivicRole.wardOfficer;
    final lower = value.toLowerCase();
    if (lower.contains('housing') || lower.contains('rwa') || lower.contains('society')) {
      return CivicRole.housingSociety;
    }
    if (lower.contains('school') || lower.contains('education') || lower.contains('campus')) {
      return CivicRole.school;
    }
    return CivicRole.wardOfficer;
  }
}
