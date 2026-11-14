/// Realistic messy air quality datasets and baseline previous briefing
/// designed to demonstrate live Gemini 2.5 Flash data cleansing,
/// anomaly detection, citation tracking, and diffing.
class SampleData {
  /// Realistic messy sensor data containing:
  /// - Inconsistent headers and mixed delimiters (commas, semicolons, whitespace)
  /// - Mixed units (e.g., PM2.5 in µg/m³, NO2 in ppm and ppb, CO in mg/m³, Temp in °C & °F)
  /// - Missing values (NaN, null, "---", blank fields, -999 dropout)
  /// - Mixed timestamp formats (ISO-8601, 12h AM/PM, epoch timestamp)
  /// - Realistic civic sensor stations across Ward 14
  static const String messySensorCsv = '''
# WARD 14 URBAN AIR MONITORING NETWORK - RAW LOGS [UNVERIFIED TELEMETRY]
# Note: Sensor Calibrations pending; mixed unit telemetry enabled
Timestamp, Sensor_ID, Station_Location, Pollutant_Type, Raw_Value, Reported_Unit, Humidity_%, Flag
2026-11-14T06:00:00Z, SEN-01-NTH, North Gate Metro Junction, PM2.5, 142.5, ug/m3, 78, OK
2026-11-14T06:15:00Z; SEN-01-NTH; North Gate Metro Junction; PM10; 288.0; µg/m³; 79; OK
2026-11-14 06:30 AM, SEN-02-IND, Sector 4 Industrial Stacks, PM2.5, 235.8, ug/m3, 65, HIGH_SPIKE
2026-11-14 06:45 AM, SEN-02-IND, Sector 4 Industrial Stacks, SO2, 0.12, ppm, 64, OK
2026-11-14T07:00:00Z, SEN-03-PRK, Central Civic Park & Senior Center, PM2.5, 48.2, µg/m³, 82, OK
2026-11-14T07:15:00Z, SEN-03-PRK, Central Civic Park & Senior Center, O3, 34.0, ppb, 80, OK
2026-11-14 07:30 AM, SEN-04-SCH, St. Jude Elementary School, PM2.5, NaN, ug/m3, 75, SENSOR_FAULT
2026-11-14 07:45 AM, SEN-04-SCH, St. Jude Elementary School, PM2.5, 118.4, µg/m³, 74, REBOOTED
2026-11-14 08:00 AM, SEN-04-SCH, St. Jude Elementary School, NO2, 54.1, ppb, 73, SCHOOL_ZONE_PEAK
2026-11-14T08:15:00Z; SEN-01-NTH; North Gate Metro Junction; PM2.5; 189.6; ug/m3; 71; RUSH_HOUR
2026-11-14T08:30:00Z; SEN-01-NTH; North Gate Metro Junction; CO; 3.8; mg/m3; 70; IDLING_TRUCKS
2026-11-14 08:45 AM, SEN-05-RES, Greenfield Housing Society Tower C, PM2.5, 78.0, µg/m³, 69, DIESEL_GEN_ON
2026-11-14 09:00 AM, SEN-05-RES, Greenfield Housing Society Tower C, PM10, ---, ug/m3, 68, SENSOR_DROPOUT
2026-11-14 09:15 AM, SEN-02-IND, Sector 4 Industrial Stacks, PM2.5, 312.0, ug/m3, 58, CRITICAL_SPIKE
2026-11-14 09:30 AM, SEN-02-IND, Sector 4 Industrial Stacks, VOC, 420.0, ppb, 57, UNCALIBRATED
2026-11-14 09:45 AM, SEN-03-PRK, Central Civic Park & Senior Center, PM2.5, -999.0, µg/m³, null, SENSOR_OFFLINE
2026-11-14 10:00 AM, SEN-04-SCH, St. Jude Elementary School, PM2.5, 162.7, ug/m3, 66, RECESS_WINDOW
''';

  /// Realistic previous briefing generated 48 hours earlier for Ward 14.
  /// Used by Gemini 2.5 Flash to compute diffing (improved vs worsened vs stable).
  static const String previousBriefSample = '''
PREVIOUS CIVIC BRIEFING (48 Hours Ago - Nov 12, 2026)
Target Jurisdiction: Ward 14 & Environs
Dominant AQI: 215 (Unhealthy)
Status Summary:
1. Sector 4 Industrial Stacks recorded PM2.5 values of 185 µg/m³ with heavy fugitive dust.
2. North Gate Metro Junction recorded peak PM2.5 of 220 µg/m³ during early freight hours (06:00 - 08:00 AM).
3. St. Jude Elementary School was operating with PM2.5 around 85 µg/m³ (Moderate).
4. Central Civic Park was safe at PM2.5 38 µg/m³.
5. Greenfield Housing Society was on grid power, recording PM2.5 at 52 µg/m³.
Key Mandates Assigned 48h Ago:
- Ward Officer deployed 2 water tankers for mist spraying on North Gate corridor.
- Industrial inspections initiated for Sector 4 boiler scrubbers.
- Schools were kept open with normal outdoor sports permitted.
''';
}
