import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';

void main() async {
  // Flutter와 Firebase를 연결하기 전에 필요한 준비 코드
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화 (firebase_options.dart에서 설정값 가져옴)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Anonymous Login Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AuthInitializer(),
    );
  }
}

/// 앱 실행 시 가장 먼저 익명 로그인을 수행하는 위젯
class AuthInitializer extends StatefulWidget {
  const AuthInitializer({super.key});

  @override
  State<AuthInitializer> createState() => _AuthInitializerState();
}

class _AuthInitializerState extends State<AuthInitializer> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _signInAnonymously();
  }

  Future<void> _signInAnonymously() async {
    try {
      // 이미 로그인되어 있으면 새로 로그인할 필요 없음
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // 익명 로그인 진행 중 UI
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      // 에러가 난 경우 간단히 메시지 표시
      return Scaffold(
        body: Center(
          child: Text('로그인 중 오류 발생:\n$_errorMessage'),
        ),
      );
    }

    // 익명 로그인 성공 후 진입할 실제 홈 화면
    return const MyHomePage();
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('익명 로그인 완료'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Firebase 익명 로그인에 성공했습니다.'),
            const SizedBox(height: 16),
            Text('현재 유저 UID: ${user?.uid ?? "없음"}'),
            const SizedBox(height: 16),
            const Text('이 상태에서 Color Flood 개발을 시작하면 돼요 ✨'),
          ],
        ),
      ),
    );
  }
}
