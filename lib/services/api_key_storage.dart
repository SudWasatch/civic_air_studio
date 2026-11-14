import 'package:flutter/foundation.dart';

/// Centralized API Key Management for Gemini 2.5 Flash.
///
/// Precedence Order:
/// 1. In-app user override (entered via Top App Bar dialog for judges / testers)
/// 2. Build-time environment variable (--dart-define=GEMINI_API_KEY=...)
///
/// Guarantees that no API keys are ever committed to source control or hardcoded.
class ApiKeyStorage {
  // Read compile-time environment flag
  static const String _envKey = String.fromEnvironment('GEMINI_API_KEY');

  // Singleton instance
  static final ApiKeyStorage instance = ApiKeyStorage._internal();
  ApiKeyStorage._internal();

  String _overrideKey = '';

  /// Reactive notifier alerting UI components whenever the active key changes
  final ValueNotifier<String> activeKeyNotifier = ValueNotifier<String>(_envKey);

  /// Returns the actively configured API key
  String get activeKey {
    if (_overrideKey.trim().isNotEmpty) {
      return _overrideKey.trim();
    }
    return _envKey.trim();
  }

  /// Whether any valid non-empty API key is available
  bool get hasKey => activeKey.isNotEmpty;

  /// Whether the user has provided an in-app override key
  bool get isOverrideActive => _overrideKey.trim().isNotEmpty;

  /// Whether a key was injected via --dart-define=GEMINI_API_KEY=...
  bool get hasEnvKey => _envKey.trim().isNotEmpty;

  /// Returns masked key for display in UI (e.g. "AIzaSy...Ab9Z")
  String get maskedKey {
    final key = activeKey;
    if (key.isEmpty) return 'No Key Configured';
    if (key.length <= 8) return '********';
    return '${key.substring(0, 6)}...${key.substring(key.length - 4)}';
  }

  /// Updates the in-app override key (e.g., entered by hackathon evaluators)
  void setOverrideKey(String key) {
    _overrideKey = key.trim();
    activeKeyNotifier.value = activeKey;
  }

  /// Clears in-app override and falls back to build environment variable
  void clearOverride() {
    _overrideKey = '';
    activeKeyNotifier.value = activeKey;
  }
}
