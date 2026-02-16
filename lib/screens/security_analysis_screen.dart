import 'package:flutter/material.dart';
import '../services/pdf_security_scanner.dart';

class SecurityAnalysisScreen extends StatelessWidget {
  final SecurityScanResult scanResult;
  final String fileName;

  const SecurityAnalysisScreen({
    super.key,
    required this.scanResult,
    required this.fileName,
  });

  Color _getThreatColor(ThreatLevel level) {
    switch (level) {
      case ThreatLevel.critical:
        return Colors.red;
      case ThreatLevel.high:
        return Colors.orange;
      case ThreatLevel.medium:
        return Colors.yellow;
      case ThreatLevel.low:
        return Colors.blue;
      case ThreatLevel.none:
        return Colors.green;
    }
  }

  IconData _getThreatIcon(ThreatLevel level) {
    switch (level) {
      case ThreatLevel.critical:
      case ThreatLevel.high:
        return Icons.error;
      case ThreatLevel.medium:
        return Icons.warning;
      case ThreatLevel.low:
        return Icons.info;
      case ThreatLevel.none:
        return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Analysis'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: scanResult.isSafe ? Colors.green.shade100 : Colors.red.shade100,
                    child: Column(
                      children: [
                        Icon(
                          scanResult.isSafe ? Icons.check_circle : Icons.warning,
                          size: 64,
                          color: scanResult.isSafe ? Colors.green.shade800 : Colors.red.shade900,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          fileName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.black87, // High contrast on light pastel background
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          scanResult.summary,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.black87, // High contrast
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  if (scanResult.threats.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle, size: 80, color: Colors.green),
                          const SizedBox(height: 16),
                          Text(
                            'No threats detected',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This PDF appears to be safe',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: scanResult.threats.length,
                      itemBuilder: (context, index) {
                        final threat = scanResult.threats[index];
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ExpansionTile(
                            leading: Icon(
                              _getThreatIcon(threat.level),
                              color: _getThreatColor(threat.level),
                            ),
                            title: Text(threat.type),
                            subtitle: Text(
                              threat.level.toString().split('.').last.toUpperCase(),
                              style: TextStyle(
                                color: _getThreatColor(threat.level),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Description:',
                                      style: Theme.of(context).textTheme.titleSmall,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(threat.description),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Recommendation:',
                                      style: Theme.of(context).textTheme.titleSmall,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(threat.recommendation),
                                    if (threat.details.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      Text(
                                        'Details:',
                                        style: Theme.of(context).textTheme.titleSmall,
                                      ),
                                      const SizedBox(height: 4),
                                      ...threat.details.map((detail) => Padding(
                                            padding: const EdgeInsets.only(left: 8, top: 2),
                                            child: Text('• $detail'),
                                          )),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Open Anyway'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} // End of class
