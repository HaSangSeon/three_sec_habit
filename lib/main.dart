import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'core/constants/app_constants.dart';
import 'core/services/ad_service.dart';
import 'core/services/home_widget_service.dart';
import 'core/services/notification_service.dart';
import 'presentation/splash/splash_screen.dart';
import 'providers/habit_provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await initializeDateFormatting('ko', null);
  await HomeWidgetService.initialize();
  await NotificationService.initialize();
  await AdService.initialize();
  runApp(const ThreeSecHabitApp());
}

class ThreeSecHabitApp extends StatelessWidget {
  const ThreeSecHabitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => HabitProvider()..loadHabits()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: ThemeProvider.lightTheme,
            darkTheme: ThemeProvider.darkTheme,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
