# Gemini 2.5 Flash Prompt & Structured Output Schema Specification

**Application:** Civic Air Quality Briefing Studio  
**Model:** `gemini-2.5-flash`  
**SDK:** `google_generative_ai` (Dart)  
**MIME Type:** `application/json`  
**Sampling Configuration:** `temperature: 0.15` (optimized for factual extraction, data cleansing, and strict citation fidelity)

---

## 1. System Instruction

The system instruction establishes the persona of a Chief Civic Intelligence Officer and Environmental Data Scientist. It forces the model to clean unstandardized telemetry, track exact source citations, audit anomalies, enforce role-specific powers, and generate bilingual/multi-level advisories.

```text
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
```

---

## 2. Dynamic User Prompt Template

```text
=== INPUT RAW AIR QUALITY TELEMETRY ===
{{rawData}}

=== TARGET CIVIC ROLE ===
Role: {{role.displayName}}
Authority Scope: {{role.scope}}
Instruction: Tailor all immediate and medium-term actions strictly to what this role controls.

=== CITIZEN ADVISORY REQUIREMENTS ===
Language: {{language.displayName}} ({{language.nativeLabel}})
Reading Level: {{readingLevel.displayName}} - {{readingLevel.description}}

=== PREVIOUS BRIEF FOR DIFFING / COMPARISON ===
{{previousBriefText ?? "No previous brief provided. Report baseline findings."}}
Instruction: Compare current telemetry against this previous brief. Highlight what improved, worsened, or stayed identical.

Produce the complete briefing strictly following the defined JSON schema.
```

---

## 3. Strict Dart Structured JSON Schema (`GenerationConfig.responseSchema`)

The app enforces the following Dart `Schema` to ensure zero JSON decoding failures:

```dart
final Schema civicAirBriefingSchema = Schema.object(
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
```
