import 'package:dio/dio.dart';

class ApiClient {

    ApiClient({required String baseUrl})
        : dio = Dio( // Dio インスタンスを初期化   
            BaseOptions(
                // API共通url
                baseUrl: baseUrl,
                // 接続が10秒以内に確立しなければエラー
                connectTimeout: const Duration(seconds: 10),
                // レスポンスが10以内に隔離なければエラー
                receiveTimeout: const Duration(seconds: 10),
                headers: {
                    'Accept': 'application/json', // jsonを受け取る
                    'Content-Type': 'application/json', // jsonを送信する
                },
            ),
        );
    
    final Dio dio;
}