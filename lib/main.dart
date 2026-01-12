import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';
import 'screens/home_screen.dart';
import 'screens/pdf_viewer_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/help_screen.dart';
import 'screens/about_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Open Hive boxes
  await Hive.openBox(Constants.settingsBox);
  await Hive.openBox(Constants.recentFoldersBox);
  await Hive.openBox(Constants.pdfMetadataBox);
  await Hive.openBox(Constants.cachedPdfsBox);
  
  runApp(const SimplePdfApp());
}

class SimplePdfApp extends StatelessWidget {
  const SimplePdfApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get theme preference from Hive
    final settingsBox = Hive.box(Constants.settingsBox);
    final isDarkMode = settingsBox.get('darkMode', defaultValue: true);

    return MaterialApp(
      title: Constants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/help': (context) => const HelpScreen(),
        '/about': (context) => const AboutScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/pdf_viewer') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => PdfViewerScreen(
              filePath: args?['filePath'],
              fileUrl: args?['fileUrl'],
            ),
          );
        }
        return null;
      },
    );
  }
}
