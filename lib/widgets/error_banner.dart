import 'package:flutter/material.dart';

/// User-friendly error banner component.
/// Replaces raw technical stack traces with actionable guidance and optional quick-fix actions.
/// Wrapped in liveRegion Semantics for screen readers.
class ErrorBanner extends StatelessWidget {
  final String message;
  final String? technicalDetail;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;
  final String? actionLabel;

  const ErrorBanner({
    super.key,
    required this.message,
    this.technicalDetail,
    this.onDismiss,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      liveRegion: true,
      container: true,
      label: 'Error alert: $message',
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE), // Light red
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFEF9A9A),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFC62828),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Action Required',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: const Color(0xFFB71C1C),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF37474F),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onDismiss != null)
                  Semantics(
                    button: true,
                    label: 'Dismiss error message',
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: const Color(0xFF78909C),
                      tooltip: 'Dismiss message',
                      onPressed: onDismiss,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
              ],
            ),
            if (technicalDetail != null && technicalDetail!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFFFCDD2)),
                ),
                child: SelectableText(
                  'Detail: $technicalDetail',
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: Color(0xFF5D4037),
                  ),
                ),
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Semantics(
                  button: true,
                  label: actionLabel,
                  child: FilledButton.tonal(
                    onPressed: onAction,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828),
                      foregroundColor: Colors.white,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    child: Text(actionLabel!),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
