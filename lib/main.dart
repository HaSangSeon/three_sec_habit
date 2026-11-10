import 'dart:async';
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
  await initializeDateFormatting('ko', null);

  // 첫 화면(runApp)을 즉시 렌더링하여 기기/네트워크 상태와 무관하게 0초 반응성 보장
  runApp(const ThreeSecHabitApp());

  // 방향 고정, 위젯, 알림, AdMob 초기화는 첫 프레임 렌더링을 막지 않고 병렬 수행
  unawaited(_initializeServicesInBackground());
}

Future<void> _initializeServicesInBackground() async {
  await Future.wait<void>([
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]).catchError((_) {}),
    HomeWidgetService.initialize(),
    NotificationService.initialize(),
    AdService.initialize(),
  ]);
}

class ThreeSecHabitApp extends StatelessWidget {
  const ThreeSecHabitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => HabitProvider()),
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
