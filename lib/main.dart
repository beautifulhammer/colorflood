import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'data/user_data.dart';
import 'data/user_data_repository.dart';
import 'home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
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
      title: 'Color Flood',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AuthInitializer(),
    );
  }
}

/// 앱 실행 시:
/// 1) 익명 로그인
/// 2) Firestore 에 users/{uid} 문서를 loadOrCreate 로 생성/로드
/// 3) HomeScreen 으로 UserData 전달
class AuthInitializer extends StatefulWidget {
  const AuthInitializer({super.key});

  @override
  State<AuthInitializer> createState() => _AuthInitializerState();
}

class _AuthInitializerState extends State<AuthInitializer> {
  bool _isLoading = true;
  String? _errorMessage;
  UserData? _userData;

  @override
  void initState() {
    super.initState();
    _initAuthAndUser();
  }

  Future<void> _initAuthAndUser() async {
    try {
      final auth = FirebaseAuth.instance;

      // 1) 익명 로그인 (이미 로그인돼 있으면 패스)
      if (auth.currentUser == null) {
        await auth.signInAnonymously();
      }
      final uid = auth.currentUser!.uid;

      // 2) Firestore users/{uid} loadOrCreate
      final repo = UserDataRepository.instance;
      // TODO: 실제로는 디바이스/설정의 언어코드를 defaultLanguageCode 로 넣어도 됨
      final userData = await repo.loadOrCreateUser(
        uid: uid,
        defaultLanguageCode: 'en',
      );

      setState(() {
        _userData = userData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null || _userData == null) {
      return Scaffold(
        body: Center(
          child: Text('초기화 중 오류 발생:\n$_errorMessage'),
        ),
      );
    }

    // 3) 초기 UserData 를 들고 홈 화면으로 진입
    return HomeScreen(
      userData: _userData!,
    );
  }
}
