import 'package:flutter/material.dart';
import 'pdf_viewer_screen.dart';

void main() {
  runApp(const SimplePdfApp());
}

class SimplePdfApp extends StatelessWidget {
  const SimplePdfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple PDF',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Colors.deepPurple,
        ),
      ),
      home: const PdfViewerScreen(),
    );
  }
}
