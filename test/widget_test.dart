import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:civic_air_studio/main.dart';
import 'package:civic_air_studio/models/air_quality_brief.dart';

void main() {
  testWidgets('Civic Air Quality Briefing Studio launches and renders UI controls',
      (WidgetTester tester) async {
    // Set a wide viewport for desktop/web layout testing
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const CivicAirQualityStudioApp());
    await tester.pumpAndSettle();

    // Verify Title and Engine Badge
    expect(find.text('Civic Air Quality Briefing Studio'), findsOneWidget);
    expect(find.textContaining('Gemini 2.5 Flash'), findsWidgets);

    // Verify Ingestion section
    expect(find.text('1. Ingest Messy Sensor Telemetry'), findsOneWidget);
    expect(find.text('2. Target Role & Advisory Preferences'), findsOneWidget);
    expect(find.text('Generate Live Briefing'), findsOneWidget);

    // Verify Role Chips
    expect(find.text('Ward Officer'), findsOneWidget);
    expect(find.text('Housing Society'), findsOneWidget);
    expect(find.text('School'), findsOneWidget);

    // Tap "Load Demo" button
    final loadDemoBtn = find.text('Load Demo');
    expect(loadDemoBtn, findsOneWidget);
    await tester.tap(loadDemoBtn);
    await tester.pumpAndSettle();

    // Verify input fields were populated
    expect(find.textContaining('WARD 14 URBAN AIR MONITORING NETWORK'), findsOneWidget);
  });

  test('CivicAirBriefing data model parses structured JSON faithfully', () {
    final mockJson = {
      'summary': 'Air quality in Ward 14 is in the Unhealthy category.',
      'overallAqiEstimate': 210,
      'overallRiskLevel': 'Unhealthy',
      'confidenceScore': 0.88,
      'hotspots': [
        {
          'locationOrSensor': 'Sector 4 Industrial Stacks',
          'peakPollutant': 'PM2.5',
          'peakValue': '312 µg/m³',
          'timestampOrPeriod': '09:15 AM',
          'citationRef': 'Row 14, SEN-02-IND @ 09:15 AM',
          'severity': 'Critical',
          'contributingFactors': 'Boiler exhaust spike',
        }
      ],
      'dataQualityAudit': {
        'totalRecordsAnalyzed': 17,
        'unreliableOrMissingPoints': 3,
        'unitConversionsApplied': ['Normalized SO2 from 0.12 ppm to 314 µg/m³'],
        'flaggedAnomalies': [
          {
            'sensorOrRow': 'SEN-04-SCH (Row 7)',
            'issueType': 'NaN Value',
            'details': 'Sensor reported NaN during reboot; interpolated from Row 8.',
          }
        ],
      },
      'roleSpecificActionPlan': {
        'targetRole': 'Ward Officer',
        'immediateActions': [
          {
            'title': 'Deploy Anti-Smog Water Tanker to Sector 4',
            'priority': 'High',
            'description': 'Dispatch 2 mist cannons to Sector 4 corridor to suppress particulates.',
            'expectedImpact': '15-20% local reduction in airborne PM10/PM2.5.',
          }
        ],
        'mediumTermInterventions': [
          {
            'title': 'Industrial Emission Audit',
            'priority': 'Medium',
            'description': 'Inspect scrubber logs for Sector 4 manufacturing plants.',
            'expectedImpact': 'Long-term compliance enforcement.',
          }
        ],
        'resourceChecklist': ['2x High-pressure misting trucks', '4x Traffic marshals'],
      },
      'progressComparison': {
        'hasPreviousBrief': true,
        'overallTrend': 'Slightly Worsened',
        'changes': [
          {
            'metricOrArea': 'Sector 4 Industrial Stacks',
            'status': 'Worsened',
            'details': 'PM2.5 increased from 185 µg/m³ to 312 µg/m³.',
          }
        ],
        'comparisonSummary': 'Industrial emissions spiked compared to 48 hours ago.',
      },
      'citizenAdvisory': {
        'headline': 'High Pollution Alert for Ward 14',
        'language': 'English',
        'readingLevel': 'Simple/General',
        'plainLanguageAdvisory': 'Air quality is poor today due to industrial smoke and dust.',
        'vulnerableGroupPrecautions': {
          'children': 'Keep children indoors during recess; avoid physical exertion.',
          'olderAdults': 'Stay indoors; run air cleaners if available.',
          'sensitiveGroups': 'Keep rescue inhalers ready; avoid outdoor transit.',
        },
        'generalPublicDosAndDonts': {
          'dos': ['Wear N95 masks outdoors', 'Keep windows closed during morning rush'],
          'donts': ['Do not burn garden waste', 'Avoid outdoor jogging'],
        },
        'emergencyHelplinesOrGuidance': 'Call civic health helpline 108 if experiencing chest tightness.',
      },
    };

    final briefing = CivicAirBriefing.fromJson(mockJson);

    expect(briefing.summary, contains('Unhealthy'));
    expect(briefing.overallAqiEstimate, 210);
    expect(briefing.overallRiskLevel, 'Unhealthy');
    expect(briefing.confidenceScore, 0.88);
    expect(briefing.hotspots.length, 1);
    expect(briefing.hotspots.first.citationRef, contains('Row 14'));
    expect(briefing.dataQualityAudit.unreliableOrMissingPoints, 3);
    expect(briefing.roleSpecificActionPlan.targetRole, 'Ward Officer');
    expect(briefing.progressComparison.overallTrend, 'Slightly Worsened');
    expect(briefing.citizenAdvisory.vulnerableGroupPrecautions.children, contains('recess'));
  });
}
