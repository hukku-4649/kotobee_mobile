import 'package:flutter/material.dart'; // ui機能関連
import 'package:flutter/services.dart'; // os機能関連

import 'network/api_client.dart';

import 'services/auth_service.dart';

import 'locator/service_locator.dart';

import 'screens/login_page.dart';

import 'config/app_config.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // 縦画面のみに固定
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // url設定
  ServiceLocator.init(baseUrl: AppConfig.apiBaseUrl);

  // Android Emulator: http://10.0.2.2:8000
  // iOS Simulator:   http://localhost:8000

  // memo用
  // ServiceLocator.init(baseUrl: 'https://willyard-lashaunda-conformable.ngrok-free.dev');
  // ServiceLocator.init(baseUrl: 'http://127.0.0.1:8000');
  // ServiceLocator.init(baseUrl: 'https://192.0.0.2:8000');

  // エントリーポイント(widgetツリーのroot)
  runApp(const MyApp());
}

// Myappクラス(アプリ全体、状態なし)
class MyApp extends StatelessWidget {
  
  // コンストラクタ
  const MyApp({super.key});

  // buildメソッド
  @override
  Widget build(BuildContext context) {
    
    // アプリ設定
    return MaterialApp(
      // タイトル
      title: 'KotoBee',
      // テーマ
      theme: ThemeData(useMaterial3: true),
      // 初期画面
      home: LoginPage(),
    );

  }

}