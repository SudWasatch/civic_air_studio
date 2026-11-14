import 'package:flutter/material.dart';
import '../models/air_quality_brief.dart';
import '../models/civic_role.dart';
import '../models/language_reading_level.dart';
import '../models/sample_data.dart';
import '../services/gemini_service.dart';
import '../widgets/app_header.dart';
import '../widgets/citizen_advisory_view.dart';
import '../widgets/diff_input_card.dart';
import '../widgets/error_banner.dart';
import '../widgets/internal_briefing_view.dart';
import '../widgets/raw_data_input_card.dart';
import '../widgets/role_and_preferences_selector.dart';

/// Main workspace screen for the Civic Air Quality Briefing Studio.
/// Multi-platform responsive layout supporting mobile, tablet, desktop, and web viewports.
class HomeStudioScreen extends StatefulWidget {
  const HomeStudioScreen({super.key});

  @override
  State<HomeStudioScreen> createState() => _HomeStudioScreenState();
}

class _HomeStudioScreenState extends State<HomeStudioScreen> with SingleTickerProviderStateMixin {
  // Input Controllers
  final TextEditingController _rawTelemetryController = TextEditingController();
  final TextEditingController _previousBriefController = TextEditingController();

  // Selection states
  CivicRole _selectedRole = CivicRole.wardOfficer;
  AdvisoryLanguage _selectedLanguage = AdvisoryLanguage.english;
  ReadingLevel _selectedReadingLevel = ReadingLevel.simpleGeneral;

  // Execution states
  bool _isLoading = false;
  String? _errorMessage;
  String? _technicalDetail;
  bool _isApiKeyIssue = false;
  CivicAirBriefing? _currentBriefing;

  // Tab controller for the output views (Tab 1: Internal Briefing, Tab 2: Citizen Advisory)
  late TabController _outputTabController;

  final GeminiService _geminiService = GeminiService();

  @override
  void initState() {
    super.initState();
    _outputTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _rawTelemetryController.dispose();
    _previousBriefController.dispose();
    _outputTabController.dispose();
    super.dispose();
  }

  /// Populates sample data into both raw telemetry and diff inputs for fast hackathon evaluation
  void _loadAllSamples() {
    setState(() {
      _rawTelemetryController.text = SampleData.messySensorCsv;
      _previousBriefController.text = SampleData.previousBriefSample;
      _errorMessage = null;
      _technicalDetail = null;
    });
  }

  /// Calls Gemini 3.8 Flash to generate live briefing with strict JSON schema
  Future<void> _generateBriefing() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _technicalDetail = null;
      _isApiKeyIssue = false;
    });

    try {
      final briefing = await _geminiService.generateBriefing(
        rawData: _rawTelemetryController.text,
        role: _selectedRole,
        language: _selectedLanguage,
        readingLevel: _selectedReadingLevel,
        previousBrief: _previousBriefController.text.trim().isNotEmpty
            ? _previousBriefController.text.trim()
            : null,
      );

      setState(() {
        _currentBriefing = briefing;
      });
    } on AirQualityServiceException catch (e) {
      setState(() {
        _errorMessage = e.userMessage;
        _technicalDetail = e.technicalDetail;
        _isApiKeyIssue = e.isApiKeyIssue;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred while communicating with Gemini API.';
        _technicalDetail = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const AppHeader(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 980;

          if (isWide) {
            // Wide Screen: Dual Column Master-Detail Studio Layout
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Ingestion & Controls Panel
                SizedBox(
                  width: 480,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      border: Border(
                        right: BorderSide(
                          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    child: _buildInputPanel(isWide: true),
                  ),
                ),

                // Right Live Intelligence Output Panel
                Expanded(
                  child: _buildOutputPanel(),
                ),
              ],
            );
          } else {
            // Mobile / Narrow Viewport: Vertical Scrolling / Tabbed View
            return DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: TabBar(
                  indicatorColor: const Color(0xFF00796B),
                  labelColor: const Color(0xFF004D40),
                  tabs: [
                    const Tab(
                      icon: Icon(Icons.input_rounded),
                      text: 'Studio Inputs',
                    ),
                    Tab(
                      icon: const Icon(Icons.analytics_rounded),
                      text: _currentBriefing != null ? 'Live Briefing (Ready)' : 'Live Briefing',
                    ),
                  ],
                ),
                body: TabBarView(
                  children: [
                    _buildInputPanel(isWide: false),
                    _buildOutputPanel(),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  /// Builds the left input and configuration panel
  Widget _buildInputPanel({required bool isWide}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Quick Hackathon Demo Action Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F7FA),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFB2EBF2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, color: Color(0xFF00838F), size: 22),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hackathon Quick Demo',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF006064),
                        ),
                      ),
                      Text(
                        'Load sample telemetry with mixed units, missing values, and prior brief in 1-click.',
                        style: TextStyle(fontSize: 11, color: Color(0xFF00838F)),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: _loadAllSamples,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF006064),
                    visualDensity: VisualDensity.compact,
                    side: const BorderSide(color: Color(0xFF00838F)),
                  ),
                  child: const Text('Load Demo'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Error banner if any exception occurred
          if (_errorMessage != null) ...[
            ErrorBanner(
              message: _errorMessage!,
              technicalDetail: _technicalDetail,
              onDismiss: () => setState(() => _errorMessage = null),
              actionLabel: _isApiKeyIssue ? 'Configure Key' : null,
              onAction: _isApiKeyIssue
                  ? () {
                      // Trigger Header settings
                    }
                  : null,
            ),
            const SizedBox(height: 8),
          ],

          // Card 1: Messy Raw Telemetry Ingestion
          RawDataInputCard(
            controller: _rawTelemetryController,
            onDataLoaded: () => setState(() {}),
          ),
          const SizedBox(height: 14),

          // Card 2: Role Selector and Advisory Options
          RoleAndPreferencesSelector(
            selectedRole: _selectedRole,
            onRoleChanged: (role) => setState(() => _selectedRole = role),
            selectedLanguage: _selectedLanguage,
            onLanguageChanged: (lang) => setState(() => _selectedLanguage = lang),
            selectedReadingLevel: _selectedReadingLevel,
            onReadingLevelChanged: (lvl) => setState(() => _selectedReadingLevel = lvl),
          ),
          const SizedBox(height: 14),

          // Card 3: Optional Progress Diffing
          DiffInputCard(
            controller: _previousBriefController,
            onDataChanged: () => setState(() {}),
          ),
          const SizedBox(height: 16),

          // Action Button: Generate Live Briefing with Gemini 3.8 Flash
          FilledButton.icon(
            onPressed: _isLoading ? null : _generateBriefing,
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.auto_awesome_rounded, size: 20),
            label: Text(
              _isLoading ? 'Analyzing Telemetry with Gemini 3.8 Flash...' : 'Generate Live Briefing',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF00796B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 2,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Builds the right panel showing live dual outputs (Internal Briefing & Citizen Advisory)
  Widget _buildOutputPanel() {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 54,
              height: 54,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00796B)),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Gemini 3.8 Flash Synthesizing Telemetry...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Harmonizing mixed units • Flagging sensor dropouts • Tailoring role plan',
                style: TextStyle(fontSize: 12, color: Color(0xFF00695C)),
              ),
            ),
          ],
        ),
      );
    }

    if (_currentBriefing == null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF00796B).withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.scatter_plot_rounded,
                  size: 56,
                  color: Color(0xFF00796B),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Ready to Synthesize Civic Intelligence',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Text(
                  'Paste sensor telemetry or click "Load Demo" on the left panel. '
                  'Gemini 3.8 Flash will extract hotspots, audit uncalibrated dropouts, and create actionable plans.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.5, color: theme.colorScheme.onSurfaceVariant, height: 1.4),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Load Ward 14 Sample & Diff Baseline'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00796B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: _loadAllSamples,
              ),
            ],
          ),
        ),
      );
    }

    // Render Dual Output Tabs: Internal Briefing Note vs Citizen Advisory
    return Column(
      children: [
        Container(
          color: theme.colorScheme.surface,
          child: TabBar(
            controller: _outputTabController,
            indicatorColor: const Color(0xFF00796B),
            labelColor: const Color(0xFF004D40),
            unselectedLabelColor: Colors.grey.shade600,
            indicatorWeight: 3,
            tabs: const [
              Tab(
                icon: Icon(Icons.admin_panel_settings_outlined, size: 20),
                text: 'Internal Briefing Note (Officials)',
              ),
              Tab(
                icon: Icon(Icons.campaign_outlined, size: 20),
                text: 'Citizen Advisory (Public Alert)',
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _outputTabController,
            children: [
              InternalBriefingView(briefing: _currentBriefing!),
              CitizenAdvisoryView(briefing: _currentBriefing!),
            ],
          ),
        ),
      ],
    );
  }
}
