import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/air_quality_brief.dart';
import '../models/civic_role.dart';
import '../models/language_reading_level.dart';
import 'api_key_storage.dart';

/// Custom exception representing user-friendly service failures.
/// Prevents exposing raw stack traces or internal socket errors to evaluators.
class AirQualityServiceException implements Exception {
  final String userMessage;
  final String? technicalDetail;
  final bool isApiKeyIssue;

  const AirQualityServiceException({
    required this.userMessage,
    this.technicalDetail,
    this.isApiKeyIssue = false,
  });

  @override
  String toString() => userMessage;
}

/// Service handling live calls to Gemini 2.5 Flash with strict structured JSON schemas
/// and an efficient in-memory LRU response cache to prevent redundant API calls.
class GeminiService {
  /// Model identifier explicitly required for the hackathon
  static const String modelName = 'gemini-2.5-flash';

  /// Maximum permissible input characters to prevent payload exhaustion or abuse
  static const int maxInputChars = 20000;

  /// Maximum entries preserved in the in-memory LRU cache
  static const int maxCacheEntries = 25;

  /// In-memory LRU cache storing prior responses keyed by deterministic input hash
  final Map<String, CivicAirBriefing> _responseCache = <String, CivicAirBriefing>{};

  /// Exact strict response schema ensuring Gemini adheres 100% to the UI data model.
  static final Schema responseSchema = Schema.object(
    properties: {
      'summary': Schema.string(
        description: 'Plain-language executive summary of the air quality status and dominant concern.',
      ),
      'overallAqiEstimate': Schema.integer(
        description: 'Estimated dominant Air Quality Index (0-500 scale).',
      ),
      'overallRiskLevel': Schema.enumString(
        enumValues: [
          'Good',
          'Moderate',
          'Unhealthy for Sensitive Groups',
          'Unhealthy',
          'Very Unhealthy',
          'Hazardous',
        ],
        description: 'Standard EPA/CPCB risk classification band.',
      ),
      'confidenceScore': Schema.number(
        description: 'Score from 0.0 to 1.0 reflecting confidence based on sensor health and coverage.',
      ),
      'hotspots': Schema.array(
        description: 'Identified pollution hotspots with rigorous data citations.',
        items: Schema.object(
          properties: {
            'locationOrSensor': Schema.string(
              description: 'Sensor ID or physical location name.',
            ),
            'peakPollutant': Schema.string(
              description: 'Dominant pollutant detected (e.g. PM2.5, PM10, NO2, SO2).',
            ),
            'peakValue': Schema.string(
              description: 'Observed value normalized with units (e.g., 312 µg/m³).',
            ),
            'timestampOrPeriod': Schema.string(
              description: 'Timestamp or time window cited from input data.',
            ),
            'citationRef': Schema.string(
              description: 'Exact citation to row/sensor/time (e.g., Row 14, SEN-02-IND @ 09:15 AM).',
            ),
            'severity': Schema.enumString(
              enumValues: ['Low', 'Moderate', 'Elevated', 'Critical'],
              description: 'Localized severity level.',
            ),
            'contributingFactors': Schema.string(
              description: 'Suspected localized emission sources or contextual cause.',
            ),
          },
          requiredProperties: [
            'locationOrSensor',
            'peakPollutant',
            'peakValue',
            'timestampOrPeriod',
            'citationRef',
            'severity',
            'contributingFactors',
          ],
        ),
      ),
      'dataQualityAudit': Schema.object(
        description: 'Audit of messy data, unit discrepancies, and flagged anomalies.',
        properties: {
          'totalRecordsAnalyzed': Schema.integer(
            description: 'Count of data points or rows evaluated.',
          ),
          'unreliableOrMissingPoints': Schema.integer(
            description: 'Count of missing values, NaNs, dropouts, or uncalibrated readings.',
          ),
          'unitConversionsApplied': Schema.array(
            description: 'List of unit normalizations performed (e.g. ppm to µg/m³).',
            items: Schema.string(),
          ),
          'flaggedAnomalies': Schema.array(
            description: 'Explicit list of corrupted, missing, or outlier data records.',
            items: Schema.object(
              properties: {
                'sensorOrRow': Schema.string(
                  description: 'Row number or Sensor ID experiencing the anomaly.',
                ),
                'issueType': Schema.string(
                  description: 'Type of defect: NaN, Sensor Dropout, Negative Value, Unit Mismatch, Outlier.',
                ),
                'details': Schema.string(
                  description: 'Explanation of how the anomaly was handled during analysis.',
                ),
              },
              requiredProperties: ['sensorOrRow', 'issueType', 'details'],
            ),
          ),
        },
        requiredProperties: [
          'totalRecordsAnalyzed',
          'unreliableOrMissingPoints',
          'unitConversionsApplied',
          'flaggedAnomalies',
        ],
      ),
      'roleSpecificActionPlan': Schema.object(
        description: 'Prioritized operational action plan strictly tailored to the recipient role.',
        properties: {
          'targetRole': Schema.string(
            description: 'The selected civic role (Ward Officer, Housing Society, or School).',
          ),
          'immediateActions': Schema.array(
            description: 'Actions to be executed in the next 0 to 4 hours.',
            items: Schema.object(
              properties: {
                'title': Schema.string(description: 'Concise action title.'),
                'priority': Schema.enumString(
                  enumValues: ['High', 'Medium', 'Low'],
                  description: 'Execution priority.',
                ),
                'description': Schema.string(
                  description: 'Specific step-by-step guidance tailored to what this role can execute.',
                ),
                'expectedImpact': Schema.string(
                  description: 'Projected reduction in exposure or emission impact.',
                ),
              },
              requiredProperties: ['title', 'priority', 'description', 'expectedImpact'],
            ),
          ),
          'mediumTermInterventions': Schema.array(
            description: 'Interventions for 24-72 hours or remainder of week.',
            items: Schema.object(
              properties: {
                'title': Schema.string(description: 'Intervention title.'),
                'priority': Schema.enumString(
                  enumValues: ['High', 'Medium', 'Low'],
                  description: 'Execution priority.',
                ),
                'description': Schema.string(
                  description: 'Operational steps within the role authority.',
                ),
                'expectedImpact': Schema.string(
                  description: 'Anticipated outcome.',
                ),
              },
              requiredProperties: ['title', 'priority', 'description', 'expectedImpact'],
            ),
          ),
          'resourceChecklist': Schema.array(
            description: 'List of equipment, materials, or personnel required.',
            items: Schema.string(),
          ),
        },
        requiredProperties: [
          'targetRole',
          'immediateActions',
          'mediumTermInterventions',
          'resourceChecklist',
        ],
      ),
      'progressComparison': Schema.object(
        description: 'Diff comparison against previous brief (if supplied).',
        properties: {
          'hasPreviousBrief': Schema.boolean(
            description: 'True if previous brief was provided and diffed.',
          ),
          'overallTrend': Schema.enumString(
            enumValues: [
              'Significantly Improved',
              'Slightly Improved',
              'Unchanged / Stable',
              'Slightly Worsened',
              'Significantly Worsened',
              'No Baseline Available',
            ],
            description: 'Direction of environmental progress.',
          ),
          'changes': Schema.array(
            description: 'Itemized differences between previous brief and current telemetry.',
            items: Schema.object(
              properties: {
                'metricOrArea': Schema.string(
                  description: 'Station, zone, or metric compared.',
                ),
                'status': Schema.enumString(
                  enumValues: ['Improved', 'Worsened', 'Unchanged', 'New Detection'],
                  description: 'Status change flag.',
                ),
                'details': Schema.string(
                  description: 'Detailed comparison explaining what changed.',
                ),
              },
              requiredProperties: ['metricOrArea', 'status', 'details'],
            ),
          ),
          'comparisonSummary': Schema.string(
            description: 'Narrative summary explaining whether recent interventions yielded results.',
          ),
        },
        requiredProperties: [
          'hasPreviousBrief',
          'overallTrend',
          'changes',
          'comparisonSummary',
        ],
      ),
      'citizenAdvisory': Schema.object(
        description: 'Public-facing health and safety advisory in target language and reading level.',
        properties: {
          'headline': Schema.string(
            description: 'Clear, compelling public alert headline.',
          ),
          'language': Schema.string(
            description: 'Language of the advisory.',
          ),
          'readingLevel': Schema.string(
            description: 'Reading level format used.',
          ),
          'plainLanguageAdvisory': Schema.string(
            description: 'Clear, empathetic community summary explaining current air quality.',
          ),
          'vulnerableGroupPrecautions': Schema.object(
            description: 'Targeted precautions for vulnerable populations.',
            properties: {
              'children': Schema.string(
                description: 'Precautions for children, outdoor play, sports, and school transit.',
              ),
              'olderAdults': Schema.string(
                description: 'Precautions for senior citizens, morning walks, ventilation.',
              ),
              'sensitiveGroups': Schema.string(
                description: 'Precautions for individuals with asthma, respiratory illness, or cardiac issues.',
              ),
            },
            requiredProperties: ['children', 'olderAdults', 'sensitiveGroups'],
          ),
          'generalPublicDosAndDonts': Schema.object(
            description: 'Actionable guidance for the general populace.',
            properties: {
              'dos': Schema.array(
                description: 'Recommended actions.',
                items: Schema.string(),
              ),
              'donts': Schema.array(
                description: 'Actions to strictly avoid.',
                items: Schema.string(),
              ),
            },
            requiredProperties: ['dos', 'donts'],
          ),
          'emergencyHelplinesOrGuidance': Schema.string(
            description: 'Guidance on respiratory red flags requiring medical attention.',
          ),
        },
        requiredProperties: [
          'headline',
          'language',
          'readingLevel',
          'plainLanguageAdvisory',
          'vulnerableGroupPrecautions',
          'generalPublicDosAndDonts',
          'emergencyHelplinesOrGuidance',
        ],
      ),
    },
    requiredProperties: [
      'summary',
      'overallAqiEstimate',
      'overallRiskLevel',
      'confidenceScore',
      'hotspots',
      'dataQualityAudit',
      'roleSpecificActionPlan',
      'progressComparison',
      'citizenAdvisory',
    ],
  );

  /// Computes a deterministic cache key for in-memory deduplication.
  String computeCacheKey({
    required String rawData,
    required CivicRole role,
    required AdvisoryLanguage language,
    required ReadingLevel readingLevel,
    String? previousBrief,
  }) {
    final cleanRaw = rawData.trim();
    final cleanPrev = (previousBrief ?? '').trim();
    return '$cleanRaw||${role.name}||${language.name}||${readingLevel.name}||$cleanPrev';
  }

  /// Clears the in-memory response cache.
  void clearCache() {
    _responseCache.clear();
  }

  /// Number of entries currently stored in the in-memory response cache.
  int get cachedItemCount => _responseCache.length;

  /// Checks if a request result is already cached without issuing network requests.
  bool hasCachedResponse({
    required String rawData,
    required CivicRole role,
    required AdvisoryLanguage language,
    required ReadingLevel readingLevel,
    String? previousBrief,
  }) {
    final key = computeCacheKey(
      rawData: rawData,
      role: role,
      language: language,
      readingLevel: readingLevel,
      previousBrief: previousBrief,
    );
    return _responseCache.containsKey(key);
  }

  /// Stores a briefing in the cache directly (useful for testing or manual seeding).
  void putInCache({
    required String rawData,
    required CivicRole role,
    required AdvisoryLanguage language,
    required ReadingLevel readingLevel,
    String? previousBrief,
    required CivicAirBriefing briefing,
  }) {
    final key = computeCacheKey(
      rawData: rawData,
      role: role,
      language: language,
      readingLevel: readingLevel,
      previousBrief: previousBrief,
    );
    if (_responseCache.length >= maxCacheEntries) {
      _responseCache.remove(_responseCache.keys.first);
    }
    _responseCache[key] = briefing;
  }

  /// Generates the complete briefing by calling Gemini 2.5 Flash with strict JSON schema.
  /// Deduplicates calls via LRU cache when identical parameters are requested.
  Future<CivicAirBriefing> generateBriefing({
    required String rawData,
    required CivicRole role,
    required AdvisoryLanguage language,
    required ReadingLevel readingLevel,
    String? previousBrief,
    bool bypassCache = false,
  }) async {
    // Edge Case 1: Check for empty input
    if (rawData.trim().isEmpty) {
      throw const AirQualityServiceException(
        userMessage: 'Please provide raw sensor data or click "Load Sample Messy Data" before generating.',
      );
    }

    // Edge Case 2: Security input guardrail check (prevent oversized payload)
    if (rawData.length > maxInputChars) {
      throw const AirQualityServiceException(
        userMessage:
            'The input telemetry exceeds the safe limit of 20,000 characters. Please truncate or filter records.',
      );
    }

    // Efficiency: Check in-memory LRU cache
    final cacheKey = computeCacheKey(
      rawData: rawData,
      role: role,
      language: language,
      readingLevel: readingLevel,
      previousBrief: previousBrief,
    );

    if (!bypassCache && _responseCache.containsKey(cacheKey)) {
      // Re-insert to refresh LRU recency
      final cachedItem = _responseCache.remove(cacheKey)!;
      _responseCache[cacheKey] = cachedItem;
      return cachedItem;
    }

    // Edge Case 3: Validate API Key availability
    final apiKey = ApiKeyStorage.instance.activeKey;
    if (apiKey.isEmpty) {
      throw const AirQualityServiceException(
        userMessage:
            'No Gemini API key found. Please click "Set API Key" in the top bar or launch with --dart-define=GEMINI_API_KEY=YOUR_KEY.',
        isApiKeyIssue: true,
      );
    }

    try {
      final model = GenerativeModel(
        model: modelName,
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          responseSchema: responseSchema,
          temperature: 0.15, // Low temperature for high factual accuracy and exact citations
        ),
        systemInstruction: Content.system(_systemInstruction),
      );

      final prompt = _buildUserPrompt(
        rawData: rawData,
        role: role,
        language: language,
        readingLevel: readingLevel,
        previousBrief: previousBrief,
      );

      final response = await model.generateContent([
        Content.text(prompt),
      ]);

      final responseText = response.text;
      if (responseText == null || responseText.trim().isEmpty) {
        throw const AirQualityServiceException(
          userMessage: 'The AI model returned an empty response. Please verify the input data format.',
        );
      }

      // Parse JSON from strict structured output
      final Map<String, dynamic> jsonMap;
      try {
        jsonMap = json.decode(responseText) as Map<String, dynamic>;
      } catch (parseError) {
        throw AirQualityServiceException(
          userMessage: 'Failed to parse AI output. The response format was unexpected.',
          technicalDetail: parseError.toString(),
        );
      }

      final briefing = CivicAirBriefing.fromJson(jsonMap);

      // Cache newly computed response
      if (_responseCache.length >= maxCacheEntries) {
        _responseCache.remove(_responseCache.keys.first);
      }
      _responseCache[cacheKey] = briefing;

      return briefing;
    } on AirQualityServiceException {
      rethrow;
    } on SocketException catch (e) {
      throw AirQualityServiceException(
        userMessage: 'Network connection error. Please check your internet connection.',
        technicalDetail: e.message,
      );
    } on GenerativeAIException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('api_key') || msg.contains('unauthorized') || msg.contains('forbidden')) {
        throw const AirQualityServiceException(
          userMessage: 'Invalid or unauthorized Gemini API key. Please verify your key in the top app bar.',
          isApiKeyIssue: true,
        );
      } else if (msg.contains('quota') || msg.contains('rate') || msg.contains('429')) {
        throw const AirQualityServiceException(
          userMessage: 'Gemini API quota or rate limit exceeded. Please wait a moment or try another API key.',
        );
      } else {
        throw AirQualityServiceException(
          userMessage: 'Gemini API error: ${e.message}',
          technicalDetail: e.toString(),
        );
      }
    } catch (e) {
      throw AirQualityServiceException(
        userMessage: 'An unexpected error occurred while analyzing the air quality data.',
        technicalDetail: e.toString(),
      );
    }
  }

  /// System instruction enforcing the persona of a Principal Civic Intelligence Officer.
  static const String _systemInstruction = '''
You are the Chief Civic Intelligence Officer and Environmental Data Scientist for urban municipalities.
Your role is to ingest messy, uncalibrated, mixed-unit air quality telemetry and convert it into:
1. An Internal Operational Briefing Note with rigorous traceability and role-specific interventions.
2. A public-facing Citizen Advisory translated into the user's requested language and reading level.

STRICT OPERATIONAL RULES:
- Traceability: For every hotspot, trend, or anomaly, you MUST cite the exact row, sensor ID, and timestamp from the raw data.
- Data Cleaning: Normalize mixed units (e.g. convert NO2/SO2/O3 ppm or ppb to µg/m³, normalize humidity, handle PM2.5/PM10).
- Anomaly Flagging: Explicitly flag NaN, negative readings (e.g. -999), sensor dropouts ("---"), uncalibrated spikes, or frozen values in the dataQualityAudit section.
- Role-Specific Action Plans:
  * If Target Role is "Ward Officer": focus on street sweepers, smog guns, anti-dust water tankers, construction bans, traffic diversions, and waste burning fines.
  * If Target Role is "Housing Society": focus on diesel generator limits, resident alerts, closing ventilation intakes near roads, balcony misting, children play timings.
  * If Target Role is "School": focus on suspending outdoor sports, classroom air purifiers, indoor recess, bus exhaust checks, student mask advisories.
- Diffing / Progress Comparison:
  * If a Previous Brief is provided, compare each station/metric against the previous brief and classify changes as "Improved", "Worsened", "Unchanged", or "New Detection".
  * If no Previous Brief is provided, set hasPreviousBrief to false and state that no baseline was provided.
- Citizen Advisory:
  * Translate the advisory faithfully into the requested language (English, Hindi, Spanish, or Regional Simple).
  * Follow the specified reading level ("Simple/General" with clear analogies and no jargon, or "Detailed" with numerical thresholds).
  * Always provide tailored precautions for: (1) Children, (2) Older Adults, and (3) Sensitive Groups (asthma/cardiac).
''';

  /// Constructs the dynamic user prompt with raw data, previous brief, and preferences.
  String _buildUserPrompt({
    required String rawData,
    required CivicRole role,
    required AdvisoryLanguage language,
    required ReadingLevel readingLevel,
    String? previousBrief,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('=== INPUT RAW AIR QUALITY TELEMETRY ===');
    buffer.writeln(rawData);
    buffer.writeln('\n=== TARGET CIVIC ROLE ===');
    buffer.writeln('Role: ${role.displayName}');
    buffer.writeln('Authority Scope: ${role.scope}');
    buffer.writeln('Instruction: Tailor all immediate and medium-term actions strictly to what this role controls.');

    buffer.writeln('\n=== CITIZEN ADVISORY REQUIREMENTS ===');
    buffer.writeln('Language: ${language.displayName} (${language.nativeLabel})');
    buffer.writeln('Reading Level: ${readingLevel.displayName} - ${readingLevel.description}');

    if (previousBrief != null && previousBrief.trim().isNotEmpty) {
      buffer.writeln('\n=== PREVIOUS BRIEF FOR DIFFING / COMPARISON ===');
      buffer.writeln(previousBrief.trim());
      buffer.writeln('Instruction: Compare current telemetry against this previous brief. Highlight what improved, worsened, or stayed identical.');
    } else {
      buffer.writeln('\n=== PREVIOUS BRIEF ===');
      buffer.writeln('No previous brief provided. Report baseline findings.');
    }

    buffer.writeln('\nProduce the complete briefing strictly following the defined JSON schema.');
    return buffer.toString();
  }
}
