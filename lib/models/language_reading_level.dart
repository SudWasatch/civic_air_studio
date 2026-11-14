/// Supported output languages for the public-facing Citizen Advisory.
enum AdvisoryLanguage {
  english(
    displayName: 'English',
    nativeLabel: 'English',
    apiValue: 'English',
    sampleGreeting: 'Air Quality Alert for Community Residents',
  ),
  hindi(
    displayName: 'Hindi',
    nativeLabel: 'हिन्दी',
    apiValue: 'Hindi',
    sampleGreeting: 'वायु गुणवत्ता चेतावनी - नागरिक सूचना',
  ),
  spanish(
    displayName: 'Spanish',
    nativeLabel: 'Español',
    apiValue: 'Spanish',
    sampleGreeting: 'Alerta de Calidad del Aire para la Comunidad',
  ),
  regionalSimple(
    displayName: 'Regional Simple',
    nativeLabel: 'Simple Plain English / Hinglish',
    apiValue: 'Regional Simple',
    sampleGreeting: 'Easy Everyday Air Advisory',
  );

  final String displayName;
  final String nativeLabel;
  final String apiValue;
  final String sampleGreeting;

  const AdvisoryLanguage({
    required this.displayName,
    required this.nativeLabel,
    required this.apiValue,
    required this.sampleGreeting,
  });

  static AdvisoryLanguage fromString(String? value) {
    if (value == null) return AdvisoryLanguage.english;
    final lower = value.toLowerCase();
    if (lower.contains('hindi')) return AdvisoryLanguage.hindi;
    if (lower.contains('spanish') || lower.contains('espanol')) return AdvisoryLanguage.spanish;
    if (lower.contains('regional') || lower.contains('simple')) return AdvisoryLanguage.regionalSimple;
    return AdvisoryLanguage.english;
  }
}

/// Tone and complexity level for the public-facing Citizen Advisory.
enum ReadingLevel {
  simpleGeneral(
    displayName: 'Simple / General Public',
    apiValue: 'Simple/General',
    description: 'Everyday vocabulary, intuitive analogies, 5th-grade reading level. Clear and non-technical.',
  ),
  detailed(
    displayName: 'Detailed / Health & Civic',
    apiValue: 'Detailed',
    description: 'Includes microgram thresholds (µg/m³), physiological impact, and specific exposure durations.',
  );

  final String displayName;
  final String apiValue;
  final String description;

  const ReadingLevel({
    required this.displayName,
    required this.apiValue,
    required this.description,
  });

  static ReadingLevel fromString(String? value) {
    if (value == null) return ReadingLevel.simpleGeneral;
    if (value.toLowerCase().contains('detail')) return ReadingLevel.detailed;
    return ReadingLevel.simpleGeneral;
  }
}
