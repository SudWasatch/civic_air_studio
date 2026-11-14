import 'package:flutter/material.dart';
import '../models/sample_data.dart';

/// Optional input card allowing users to supply a previous briefing note.
/// Enables Gemini 2.5 Flash to compute progress diffing (improved, worsened, or unchanged).
/// Fully accessible with semantics labels and responsive action buttons.
class DiffInputCard extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onDataChanged;

  const DiffInputCard({
    super.key,
    required this.controller,
    required this.onDataChanged,
  });

  @override
  State<DiffInputCard> createState() => _DiffInputCardState();
}

class _DiffInputCardState extends State<DiffInputCard> {
  bool _isExpanded = false;

  void _loadSamplePreviousBrief() {
    setState(() {
      _isExpanded = true;
      widget.controller.text = SampleData.previousBriefSample;
    });
    widget.onDataChanged();
  }

  void _clearPreviousBrief() {
    setState(() {
      widget.controller.clear();
    });
    widget.onDataChanged();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasContent = widget.controller.text.trim().isNotEmpty;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: hasContent
              ? const Color(0xFF1565C0).withValues(alpha: 0.5)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: Key('diff_tile_$hasContent'),
          initiallyExpanded: _isExpanded || hasContent,
          onExpansionChanged: (val) => setState(() => _isExpanded = val),
          leading: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF6A1B9A).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.compare_arrows_rounded,
              color: Color(0xFF6A1B9A),
              size: 20,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  label: 'Section 3: Progress Comparison Diff against previous briefing',
                  child: const Text(
                    '3. Progress Comparison (Diff)',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
              if (hasContent) ...[
                const SizedBox(width: 6),
                Semantics(
                  label: 'Diff baseline is active',
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Diff Active',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ],
          ),
          subtitle: Text(
            'Compare against past brief to evaluate intervention impact.',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    textField: true,
                    label: 'Previous briefing note text field for diffing',
                    child: TextField(
                      controller: widget.controller,
                      maxLines: 5,
                      minLines: 3,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        height: 1.35,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Paste summary of previous briefing note here...\nExample: "Sector 4 PM2.5 was 185 ug/m3, 2 water tankers deployed..."',
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      onChanged: (_) => widget.onDataChanged(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Semantics(
                        button: true,
                        label: 'Load sample previous briefing note',
                        child: Tooltip(
                          message: 'Populate with realistic previous brief from 48 hours ago',
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.history_edu_rounded, size: 16),
                            label: const Text('Load Sample Previous Brief'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF6A1B9A),
                              side: const BorderSide(color: Color(0xFF6A1B9A)),
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: _loadSamplePreviousBrief,
                          ),
                        ),
                      ),
                      if (hasContent)
                        Semantics(
                          button: true,
                          label: 'Clear previous briefing baseline',
                          child: Tooltip(
                            message: 'Remove previous brief baseline',
                            child: TextButton.icon(
                              icon: const Icon(Icons.clear, size: 16),
                              label: const Text('Clear Diff'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.grey.shade700,
                                visualDensity: VisualDensity.compact,
                              ),
                              onPressed: _clearPreviousBrief,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
