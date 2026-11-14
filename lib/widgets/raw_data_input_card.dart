import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/sample_data.dart';

/// Ingestion card for pasting raw text/CSV tables or uploading .csv / .txt files.
/// Accommodates inconsistent formats, mixed units (µg/m³ vs ppm), and missing/NaN values.
class RawDataInputCard extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onDataLoaded;

  const RawDataInputCard({
    super.key,
    required this.controller,
    required this.onDataLoaded,
  });

  @override
  State<RawDataInputCard> createState() => _RawDataInputCardState();
}

class _RawDataInputCardState extends State<RawDataInputCard> {
  bool _isUploading = false;
  String? _uploadStatus;

  Future<void> _pickFile() async {
    setState(() {
      _isUploading = true;
      _uploadStatus = null;
    });

    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['csv', 'txt', 'tsv', 'json'],
      );

      if (file != null) {
        final bytes = await file.readAsBytes();
        final content = utf8.decode(bytes, allowMalformed: true);

        if (content.isNotEmpty) {
          widget.controller.text = content;
          widget.onDataLoaded();
          setState(() {
            _uploadStatus = 'Loaded "${file.name}" (${(bytes.lengthInBytes / 1024).toStringAsFixed(1)} KB)';
          });
        }
      }
    } catch (e) {
      setState(() {
        _uploadStatus = 'Error reading file: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _loadSampleData() {
    widget.controller.text = SampleData.messySensorCsv;
    widget.onDataLoaded();
    setState(() {
      _uploadStatus = 'Loaded Ward 14 Sample Dataset (mixed units & dropouts)';
    });
  }

  void _clearData() {
    widget.controller.clear();
    widget.onDataLoaded();
    setState(() {
      _uploadStatus = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = widget.controller.text;
    final lineCount = text.isEmpty ? 0 : text.split('\n').length;
    final charCount = text.length;

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
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00796B).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.dataset_outlined,
                    color: Color(0xFF00796B),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '1. Ingest Messy Sensor Telemetry',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        'Paste raw logs or upload CSV/TXT with inconsistent units and missing data.',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.flash_on_rounded, size: 16),
                  label: const Text('Load Sample'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF00796B),
                    side: const BorderSide(color: Color(0xFF00796B)),
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: _loadSampleData,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Stack(
              children: [
                TextField(
                  controller: widget.controller,
                  maxLines: 9,
                  minLines: 7,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'Paste unformatted telemetry here...\nExample:\nTimestamp, Sensor_ID, Pollutant, Value, Unit\n2026-11-14T08:00Z, S1, PM2.5, 185, ug/m3\n2026-11-14 08:15 AM; S2; NO2; 0.14; ppm\n2026-11-14 08:30 AM; S3; PM10; NaN; ---',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF00796B), width: 1.5),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                if (_isUploading)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Colors.white70,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _isUploading ? null : _pickFile,
                  icon: const Icon(Icons.file_upload_outlined, size: 16),
                  label: const Text('Upload File (.csv / .txt)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    foregroundColor: theme.colorScheme.onSecondaryContainer,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                if (text.isNotEmpty)
                  TextButton.icon(
                    onPressed: _clearData,
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                Text(
                  '$lineCount lines • $charCount chars',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (_uploadStatus != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 14, color: Color(0xFF00796B)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _uploadStatus!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF00796B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
