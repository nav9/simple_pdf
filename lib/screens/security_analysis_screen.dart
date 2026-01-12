import 'package:flutter/material.dart';
import '../models/security_threat.dart';
import '../utils/theme.dart';

class SecurityAnalysisScreen extends StatelessWidget {
  final SecurityAnalysisResult result;
  final VoidCallback onCancel;
  final VoidCallback onProceed;

  const SecurityAnalysisScreen({
    super.key,
    required this.result,
    required this.onCancel,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: result.hasCriticalThreats || result.hasHighThreats
                    ? AppTheme.criticalColor.withOpacity(0.1)
                    : Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    result.hasThreats ? Icons.warning : Icons.check_circle,
                    color: result.hasCriticalThreats || result.hasHighThreats
                        ? AppTheme.criticalColor
                        : AppTheme.lowColor,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Security Analysis',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          result.hasThreats
                              ? '${result.threats.length} threat(s) detected'
                              : 'No threats detected',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Threat list
            Expanded(
              child: result.hasThreats
                  ? ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        if (result.criticalThreats.isNotEmpty) ...[
                          _buildSeveritySection(
                            context,
                            'Critical',
                            result.criticalThreats,
                            AppTheme.criticalColor,
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (result.highThreats.isNotEmpty) ...[
                          _buildSeveritySection(
                            context,
                            'High',
                            result.highThreats,
                            AppTheme.highColor,
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (result.mediumThreats.isNotEmpty) ...[
                          _buildSeveritySection(
                            context,
                            'Medium',
                            result.mediumThreats,
                            AppTheme.mediumColor,
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (result.lowThreats.isNotEmpty) ...[
                          _buildSeveritySection(
                            context,
                            'Low',
                            result.lowThreats,
                            AppTheme.lowColor,
                          ),
                        ],
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 64,
                            color: AppTheme.lowColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'This PDF appears to be safe',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No security threats were detected',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
            ),
            
            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: onCancel,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: onProceed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: result.hasCriticalThreats
                          ? AppTheme.criticalColor
                          : null,
                    ),
                    child: Text(
                      result.hasCriticalThreats
                          ? 'Accept Risk & Open'
                          : 'Open PDF',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeveritySection(
    BuildContext context,
    String severity,
    List<SecurityThreat> threats,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$severity Risk (${threats.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...threats.map((threat) => _buildThreatCard(context, threat, color)),
      ],
    );
  }

  Widget _buildThreatCard(
    BuildContext context,
    SecurityThreat threat,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    threat.type,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              threat.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      threat.recommendation,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            if (threat.location.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Location: ${threat.location}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
