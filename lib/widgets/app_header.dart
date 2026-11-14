import 'package:flutter/material.dart';
import '../services/api_key_storage.dart';

/// Top Application Header with branding, model indicator, and in-app API key override modal.
/// Adheres to high-contrast WCAG guidelines and includes complete accessibility semantics.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(68);

  void _showApiKeyDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => const _ApiKeyConfigDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      elevation: 1,
      backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFF004D40),
      foregroundColor: Colors.white,
      toolbarHeight: 68,
      title: Semantics(
        header: true,
        label: 'Civic Air Quality Briefing Studio - AI Intelligence Engine Powered by Gemini 2.5 Flash',
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.air_rounded,
                color: Color(0xFF80CBC4),
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Civic Air Quality Briefing Studio',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF69F0AE),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'AI Intelligence Engine • Gemini 2.5 Flash',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.85),
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
      actions: [
        ValueListenableBuilder<String>(
          valueListenable: ApiKeyStorage.instance.activeKeyNotifier,
          builder: (context, activeKey, _) {
            final hasKey = activeKey.isNotEmpty;
            final isOverride = ApiKeyStorage.instance.isOverrideActive;
            final chipLabel = hasKey ? (isOverride ? 'Custom Key' : 'Key Set') : 'Key Required';

            return Container(
              margin: const EdgeInsets.only(right: 12),
              child: Semantics(
                button: true,
                label: 'Gemini API Key Status: $chipLabel. Tap to configure key.',
                child: Tooltip(
                  message: hasKey ? 'API Key Active (tap to change)' : 'Click to configure Gemini API Key',
                  child: ActionChip(
                    avatar: Icon(
                      hasKey ? Icons.vpn_key_rounded : Icons.key_off_rounded,
                      size: 16,
                      color: hasKey ? const Color(0xFF004D40) : const Color(0xFFB71C1C),
                    ),
                    label: Text(
                      chipLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: hasKey ? const Color(0xFF004D40) : const Color(0xFFB71C1C),
                      ),
                    ),
                    backgroundColor: hasKey ? const Color(0xFFA7FFEB) : const Color(0xFFFFCDD2),
                    side: BorderSide.none,
                    onPressed: () => _showApiKeyDialog(context),
                  ),
                ),
              ),
            );
          },
        ),
        Semantics(
          button: true,
          label: 'API Key Configuration Settings',
          child: Tooltip(
            message: 'Configure Gemini API Key',
            child: IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => _showApiKeyDialog(context),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

/// Dedicated dialog managing API Key inspection, override, and safe disposal.
class _ApiKeyConfigDialog extends StatefulWidget {
  const _ApiKeyConfigDialog();

  @override
  State<_ApiKeyConfigDialog> createState() => _ApiKeyConfigDialogState();
}

class _ApiKeyConfigDialogState extends State<_ApiKeyConfigDialog> {
  late final TextEditingController _controller;
  final ApiKeyStorage _storage = ApiKeyStorage.instance;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: _storage.isOverrideActive ? _storage.activeKey : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasKey = _storage.hasKey;
    final isOverride = _storage.isOverrideActive;
    final hasEnv = _storage.hasEnvKey;

    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00796B).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.key_rounded,
              color: Color(0xFF00796B),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Flexible(
            child: Text(
              'Gemini API Key Configuration',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This application calls live Gemini 2.5 Flash for data synthesis and civic intelligence. '
                'Hackathon evaluators can provide a key below or pass it via --dart-define=GEMINI_API_KEY=...',
                style: TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF455A64)),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFECEFF1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFCFD8DC)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          hasKey ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                          size: 16,
                          color: hasKey ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          hasKey ? 'Active Key Available' : 'No API Key Configured',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: hasKey ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                          ),
                        ),
                        const Spacer(),
                        if (isOverride)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00796B),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'In-App Override',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          )
                        else if (hasEnv)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF37474F),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Build Env Variable',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Current Key: ${_storage.maskedKey}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: Color(0xFF263238),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Semantics(
                textField: true,
                label: 'Enter or paste your Gemini API Key',
                child: TextField(
                  controller: _controller,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Enter / Paste Gemini API Key',
                    hintText: 'AIzaSy...',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.vpn_key_outlined),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: 'Clear field',
                      onPressed: () => _controller.clear(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Security Note: Keys entered here remain purely in client-side memory for your session and are sent strictly to Google Cloud Gemini endpoints.',
                style: TextStyle(fontSize: 11, color: Color(0xFF78909C), fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (isOverride)
          Semantics(
            button: true,
            label: 'Reset to environment API Key',
            child: TextButton.icon(
              icon: const Icon(Icons.restore_rounded),
              label: const Text('Reset to Env'),
              onPressed: () {
                _storage.clearOverride();
                setState(() {
                  _controller.text = '';
                });
              },
            ),
          ),
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        FilledButton.icon(
          icon: const Icon(Icons.save_rounded, size: 18),
          label: const Text('Apply Key'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF00796B),
          ),
          onPressed: () {
            final newKey = _controller.text.trim();
            if (newKey.isNotEmpty) {
              _storage.setOverrideKey(newKey);
            }
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
