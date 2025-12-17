import 'package:flutter/material.dart';
import 'screens/howto_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/training_screen.dart';
import 'screens/result_screen.dart';
import 'screens/mypage_screen.dart';
import 'screens/practice_screen.dart';
import 'screens/song_search_screen.dart';
import 'dart:ui';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VoiceTrain',

      // 👇 2. 이 부분을 추가하면 PC에서도 마우스로 드래그 스크롤이 됩니다! 👇
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown,
        },
      ),

      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF05030A),
        primaryColor: Colors.purpleAccent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white70),
        ),
        textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: 'NotoSansKR',
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purpleAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ),

      // 시작 화면
      initialRoute: '/splash',

      // 라우트 맵
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const HomeScreen(),
        '/training': (_) => const TrainingScreen(),
        '/result': (_) => const ResultScreen(),
        '/mypage': (_) => const MyPageScreen(),
        '/practice': (_) => const PracticeScreen(),
        '/search': (_) => const SongSearchScreen(),
        '/howto': (_) => const HowToScreen(),

      },
    );
  }
}

