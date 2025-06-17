import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const BbongApp());
}

class BbongApp extends StatelessWidget {
  const BbongApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '월남뽕',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: const Color(0xFF1C1C1C),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1C1C1C),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC0392B),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const SafeTestScreen(),
    );
  }
}

// 웹 환경에서 안전한 테스트 화면
class SafeTestScreen extends StatefulWidget {
  const SafeTestScreen({super.key});

  @override
  State<SafeTestScreen> createState() => _SafeTestScreenState();
}

class _SafeTestScreenState extends State<SafeTestScreen> {
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    // 안전한 초기화를 위해 프레임 렌더링 후 활성화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isReady = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '월남뽕',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC0392B),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _isReady ? '테스트 준비 완료' : '초기화 중...',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              if (_isReady)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('홈 화면으로'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC0392B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 