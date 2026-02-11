import 'package:flutter/material.dart';
import 'services/database_service.dart';
import 'services/encryption_service.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'models/settings_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  await DatabaseService().initialize();
  
  runApp(const SimplePdfApp());
}

class SimplePdfApp extends StatelessWidget {
  const SimplePdfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: EncryptionService().isPlausibleDeniabilityEnabled(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        final plausibleDeniabilityEnabled = snapshot.data!;
        final settings = DatabaseService().getSettings();

        return MaterialApp(
          title: 'Simple PDF',
          debugShowCheckedModeBanner: false,
          theme: _getTheme(settings.theme, false),
          darkTheme: _getTheme(settings.theme, true),
          themeMode: _getThemeMode(settings.theme),
          home: plausibleDeniabilityEnabled
              ? const LoginScreen()
              : const MainScreen(),
        );
      },
    );
  }

  ThemeData _getTheme(String themeSetting, bool isDark) {
    if (isDark) {
      return ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Colors.blue,
          secondary: Colors.lightBlueAccent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      );
    } else {
      return ThemeData.light().copyWith(
        colorScheme: const ColorScheme.light(
          primary: Colors.blue,
          secondary: Colors.lightBlueAccent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      );
    }
  }

  ThemeMode _getThemeMode(String themeSetting) {
    switch (themeSetting) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.dark;
    }
  }
}
