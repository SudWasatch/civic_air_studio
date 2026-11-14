import 'package:flutter_test/flutter_test.dart';
import 'package:civic_air_studio/models/air_quality_brief.dart';
import 'package:civic_air_studio/models/civic_role.dart';
import 'package:civic_air_studio/models/language_reading_level.dart';
import 'package:civic_air_studio/services/gemini_service.dart';
import 'package:civic_air_studio/services/api_key_storage.dart';

void main() {
  late GeminiService service;

  setUp(() {
    service = GeminiService();
    service.clearCache();
    ApiKeyStorage.instance.clearOverride();
  });

  group('GeminiService - Input Guardrails & Edge Cases', () {
    test('Throws AirQualityServiceException on empty input', () async {
      expect(
        () => service.generateBriefing(
          rawData: '',
          role: CivicRole.wardOfficer,
          language: AdvisoryLanguage.english,
          readingLevel: ReadingLevel.simpleGeneral,
        ),
        throwsA(isA<AirQualityServiceException>().having(
          (e) => e.userMessage,
          'userMessage',
          contains('Please provide raw sensor data'),
        )),
      );
    });

    test('Throws AirQualityServiceException on whitespace-only input', () async {
      expect(
        () => service.generateBriefing(
          rawData: '   \n\t  ',
          role: CivicRole.wardOfficer,
          language: AdvisoryLanguage.english,
          readingLevel: ReadingLevel.simpleGeneral,
        ),
        throwsA(isA<AirQualityServiceException>().having(
          (e) => e.userMessage,
          'userMessage',
          contains('Please provide raw sensor data'),
        )),
      );
    });

    test('Throws AirQualityServiceException on oversized input (>20,000 chars)', () async {
      final oversizedData = 'Timestamp, Sensor, Value\n${'A' * 20050}';

      expect(
        () => service.generateBriefing(
          rawData: oversizedData,
          role: CivicRole.wardOfficer,
          language: AdvisoryLanguage.english,
          readingLevel: ReadingLevel.simpleGeneral,
        ),
        throwsA(isA<AirQualityServiceException>().having(
          (e) => e.userMessage,
          'userMessage',
          contains('exceeds the safe limit of 20,000 characters'),
        )),
      );
    });

    test('Throws AirQualityServiceException when API key is missing and cache misses', () async {
      expect(
        () => service.generateBriefing(
          rawData: '2026-11-14T08:00Z, SEN-01, PM2.5, 120, ug/m3',
          role: CivicRole.wardOfficer,
          language: AdvisoryLanguage.english,
          readingLevel: ReadingLevel.simpleGeneral,
        ),
        throwsA(isA<AirQualityServiceException>().having(
          (e) => e.isApiKeyIssue,
          'isApiKeyIssue',
          isTrue,
        )),
      );
    });
  });

  group('GeminiService - In-Memory LRU Cache', () {
    const mockBriefing = CivicAirBriefing(
      summary: 'Cached operational summary',
      overallAqiEstimate: 145,
      overallRiskLevel: 'Moderate',
      confidenceScore: 0.92,
      hotspots: [],
      dataQualityAudit: DataQualityAudit(
        totalRecordsAnalyzed: 10,
        unreliableOrMissingPoints: 0,
        unitConversionsApplied: [],
        flaggedAnomalies: [],
      ),
      roleSpecificActionPlan: RoleActionPlan(
        targetRole: 'Ward Officer',
        immediateActions: [],
        mediumTermInterventions: [],
        resourceChecklist: [],
      ),
      progressComparison: ProgressComparison(
        hasPreviousBrief: false,
        overallTrend: 'No Baseline Available',
        changes: [],
        comparisonSummary: 'Baseline created.',
      ),
      citizenAdvisory: CitizenAdvisory(
        headline: 'Air Quality Notice',
        language: 'English',
        readingLevel: 'Simple/General',
        plainLanguageAdvisory: 'Air is moderate today.',
        vulnerableGroupPrecautions: VulnerablePrecautions(
          children: 'Safe for normal play.',
          olderAdults: 'Safe for walks.',
          sensitiveGroups: 'Monitor symptoms.',
        ),
        generalPublicDosAndDonts: DosAndDonts(dos: [], donts: []),
        emergencyHelplinesOrGuidance: 'Call local clinic if unwell.',
      ),
    );

    test('Computes deterministic cache key', () {
      final key1 = service.computeCacheKey(
        rawData: 'Raw Telemetry String',
        role: CivicRole.wardOfficer,
        language: AdvisoryLanguage.english,
        readingLevel: ReadingLevel.simpleGeneral,
        previousBrief: 'Prior brief baseline',
      );

      final key2 = service.computeCacheKey(
        rawData: '  Raw Telemetry String  ',
        role: CivicRole.wardOfficer,
        language: AdvisoryLanguage.english,
        readingLevel: ReadingLevel.simpleGeneral,
        previousBrief: '  Prior brief baseline  ',
      );

      expect(key1, equals(key2));
    });

    test('Cached response returns instantaneously without network call or API key requirement',
        () async {
      const rawData = '2026-11-14T08:00Z, SEN-01, PM2.5, 120, ug/m3';

      expect(
        service.hasCachedResponse(
          rawData: rawData,
          role: CivicRole.wardOfficer,
          language: AdvisoryLanguage.english,
          readingLevel: ReadingLevel.simpleGeneral,
        ),
        isFalse,
      );

      // Seed cache directly
      service.putInCache(
        rawData: rawData,
        role: CivicRole.wardOfficer,
        language: AdvisoryLanguage.english,
        readingLevel: ReadingLevel.simpleGeneral,
        briefing: mockBriefing,
      );

      expect(
        service.hasCachedResponse(
          rawData: rawData,
          role: CivicRole.wardOfficer,
          language: AdvisoryLanguage.english,
          readingLevel: ReadingLevel.simpleGeneral,
        ),
        isTrue,
      );
      expect(service.cachedItemCount, 1);

      // Even without an API key, generateBriefing should return the cached item immediately!
      final result = await service.generateBriefing(
        rawData: rawData,
        role: CivicRole.wardOfficer,
        language: AdvisoryLanguage.english,
        readingLevel: ReadingLevel.simpleGeneral,
      );

      expect(result.summary, equals('Cached operational summary'));
      expect(result.overallAqiEstimate, 145);
    });

    test('Clearing cache removes stored items', () {
      service.putInCache(
        rawData: 'Telemetry 1',
        role: CivicRole.school,
        language: AdvisoryLanguage.hindi,
        readingLevel: ReadingLevel.detailed,
        briefing: mockBriefing,
      );

      expect(service.cachedItemCount, 1);
      service.clearCache();
      expect(service.cachedItemCount, 0);
    });

    test('LRU cache evicts oldest entry when max limit is exceeded', () {
      for (int i = 0; i < 30; i++) {
        service.putInCache(
          rawData: 'Telemetry Station $i',
          role: CivicRole.wardOfficer,
          language: AdvisoryLanguage.english,
          readingLevel: ReadingLevel.simpleGeneral,
          briefing: mockBriefing,
        );
      }

      // Max cache entries is capped at 25
      expect(service.cachedItemCount, equals(25));
    });
  });
}
