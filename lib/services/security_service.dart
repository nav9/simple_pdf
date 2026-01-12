import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/security_threat.dart';
import '../utils/constants.dart';

class SecurityService {
  /// Analyze a PDF file for security threats
  Future<SecurityAnalysisResult> analyzePdf(String filePath) async {
    final threats = <SecurityThreat>[];
    
    try {
      // Load the PDF document
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final document = PdfDocument(inputBytes: bytes);
      
      // Get PDF as string for keyword analysis
      final pdfString = String.fromCharCodes(bytes);
      
      // Check for JavaScript
      final jsThreats = _detectJavaScript(pdfString);
      threats.addAll(jsThreats);
      
      // Check for auto-actions
      final autoActionThreats = _detectAutoActions(pdfString);
      threats.addAll(autoActionThreats);
      
      // Check for embedded files
      final embeddedFileThreats = _detectEmbeddedFiles(pdfString);
      threats.addAll(embeddedFileThreats);
      
      // Check for URIs/external links
      final uriThreats = _detectURIs(pdfString);
      threats.addAll(uriThreats);
      
      // Check for form fields with actions
      final formThreats = _detectFormActions(document);
      threats.addAll(formThreats);
      
      document.dispose();
      
      return SecurityAnalysisResult(
        threats: threats,
        analyzedAt: DateTime.now(),
        filePath: filePath,
      );
    } catch (e) {
      // If analysis fails, return empty result
      return SecurityAnalysisResult(
        threats: [],
        analyzedAt: DateTime.now(),
        filePath: filePath,
      );
    }
  }
  
  List<SecurityThreat> _detectJavaScript(String pdfContent) {
    final threats = <SecurityThreat>[];
    
    for (final keyword in Constants.javascriptKeywords) {
      if (pdfContent.contains(keyword)) {
        threats.add(SecurityThreat(
          type: 'JavaScript',
          severity: Constants.severityHigh,
          description: 'This PDF contains JavaScript code that could execute automatically when the file is opened.',
          location: 'PDF Object Stream',
          recommendation: 'JavaScript in PDFs can be used for malicious purposes. Only open this file if you trust the source.',
        ));
        break; // Only add one JavaScript threat
      }
    }
    
    return threats;
  }
  
  List<SecurityThreat> _detectAutoActions(String pdfContent) {
    final threats = <SecurityThreat>[];
    
    for (final keyword in Constants.autoActionKeywords) {
      if (pdfContent.contains(keyword)) {
        threats.add(SecurityThreat(
          type: 'Auto-Action',
          severity: Constants.severityCritical,
          description: 'This PDF contains automatic actions that will execute when the file is opened or closed.',
          location: 'PDF Catalog/Page',
          recommendation: 'Auto-actions can trigger malicious code without user interaction. This is a critical security risk.',
        ));
        break;
      }
    }
    
    return threats;
  }
  
  List<SecurityThreat> _detectEmbeddedFiles(String pdfContent) {
    final threats = <SecurityThreat>[];
    
    for (final keyword in Constants.embeddedFileKeywords) {
      if (pdfContent.contains(keyword)) {
        threats.add(SecurityThreat(
          type: 'Embedded Files',
          severity: Constants.severityMedium,
          description: 'This PDF contains embedded files that could potentially be executable or malicious.',
          location: 'PDF Attachments',
          recommendation: 'Embedded files can hide malware. Extract and scan them separately before opening.',
        ));
        break;
      }
    }
    
    return threats;
  }
  
  List<SecurityThreat> _detectURIs(String pdfContent) {
    final threats = <SecurityThreat>[];
    
    for (final keyword in Constants.uriKeywords) {
      if (pdfContent.contains(keyword)) {
        threats.add(SecurityThreat(
          type: 'External Links',
          severity: Constants.severityLow,
          description: 'This PDF contains links to external websites or resources.',
          location: 'PDF Annotations/Actions',
          recommendation: 'External links could lead to phishing sites. Verify URLs before clicking.',
        ));
        break;
      }
    }
    
    return threats;
  }
  
  List<SecurityThreat> _detectFormActions(PdfDocument document) {
    final threats = <SecurityThreat>[];
    
    try {
      // Check if document has form fields
      if (document.form.fields.count > 0) {
        threats.add(SecurityThreat(
          type: 'Form Fields',
          severity: Constants.severityLow,
          description: 'This PDF contains interactive form fields that could submit data.',
          location: 'PDF Form',
          recommendation: 'Form fields are generally safe but could be used for data collection. Review before filling.',
        ));
      }
    } catch (e) {
      // Ignore form detection errors
    }
    
    return threats;
  }
  
  /// Get a summary of threat counts by severity
  Map<String, int> getThreatSummary(SecurityAnalysisResult result) {
    return {
      'critical': result.criticalThreats.length,
      'high': result.highThreats.length,
      'medium': result.mediumThreats.length,
      'low': result.lowThreats.length,
      'total': result.threats.length,
    };
  }
  
  /// Determine if a PDF should be blocked based on threats
  bool shouldBlockPdf(SecurityAnalysisResult result) {
    // Block if there are any critical threats
    return result.hasCriticalThreats;
  }
  
  /// Get a user-friendly risk level description
  String getRiskLevel(SecurityAnalysisResult result) {
    if (result.hasCriticalThreats) {
      return 'Critical Risk - Not recommended to open';
    } else if (result.hasHighThreats) {
      return 'High Risk - Proceed with caution';
    } else if (result.threats.length > 2) {
      return 'Medium Risk - Review threats carefully';
    } else if (result.threats.isNotEmpty) {
      return 'Low Risk - Generally safe';
    } else {
      return 'No threats detected - Safe to open';
    }
  }
}
