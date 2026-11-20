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
            builder: (context, appChild) {
              // 중장년층 큰 글꼴 설정(1.5x~2.0x) 및 초소형 보급폰에서도 화면 깨짐 없이
              // 가독성과 레이아웃 안정성을 동시에 지키기 위한 전역 텍스트 배율 안전 범위(0.85~1.25x)
              final mq = MediaQuery.of(context);
              final safeScaler = mq.textScaler.clamp(
                minScaleFactor: 0.85,
                maxScaleFactor: 1.25,
              );
              return MediaQuery(
                data: mq.copyWith(textScaler: safeScaler),
                child: appChild ?? const SizedBox.shrink(),
              );
            },
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
