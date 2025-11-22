import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/providers/health_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/themes/app_theme.dart';
import 'data/repositories/health_repository.dart';
import 'data/services/health_data_service.dart';
import 'presentation/screens/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize services and repositories
    final healthDataService = HealthDataService();
    final healthRepository = HealthRepository(healthDataService);

    return MultiProvider(
      providers: [
        // Theme Provider
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        // Health Provider
        ChangeNotifierProvider(
          create: (_) => HealthProvider(healthRepository),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Health Insights',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const DashboardScreen(),
          );
        },
      ),
    );
  }
}
