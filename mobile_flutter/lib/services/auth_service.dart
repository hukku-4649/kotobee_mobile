// import 'package:dio/dio.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// import '../network/api_client.dart';

// import '../exceptions/auth_exception.dart';

// // 認証クラス
// class AuthService {

//   // コンストラクタ
//   AuthService({required ApiClient apiClient}) : _api = apiClient;  


//   final ApiClient _api;

//   // 認証トークンを安全に保存・取得・削除するためのストレージ(アプリを再起動してもデータは保持される)
//   final _storage = const FlutterSecureStorage();
//   // トークン保存キー
//   static const _tokenKey = 'auth_token';
//   // トークン取得(非同期処理、なければnull)
//   Future<String?> getToken() => _storage.read(key: _tokenKey);
//   // トークン保存
//   Future<void> _setToken(String token) => _storage.write(key: _tokenKey, value: token);
//   // トークン削除(基本的にログアウトで実行する)
//   Future<void> clearToken() => _storage.delete(key: _tokenKey);


//   // loginメソッド定義(ログインに必要なemail,passwordを引数にする)
//   Future<void> login({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       // /api/loginにpostリクエスト
//       final res = await _api.dio.post(
//         '/api/login',        
//         // 以下のdataをlaravelのAuthControllerに渡す
//         data: {          
//           'email': email.trim(),
//           'password': password, // パスワードはtrimしない（意図しない改変防止）
//         },        
//       );
      

//       // 生の本文を表示
//       print('RAW RESPONSE => ${res.data}');

//       // res.dataをdataに代入
//       final data = res.data;

//       // レスポンスがmap({}の形式)であるか確認
//       if (data is! Map) {
//         throw AuthException('サーバーの応答形式が不正です。');
//       }

//       // tokenを代入
//       final tokenAny = data['token'];

//       // トークンキーがString型かつnullでないか確認
//       final token = tokenAny is String ? tokenAny : null;

//       // トークンが無い or 空文字の場合はエラー扱い
//       if (token == null || token.isEmpty) {

//         // Laravel側が message を返している場合も拾う
//         final msg = data['message'];

//         if (msg is String && msg.isNotEmpty) {
//           // throw(実行を中断し呼び出し下に投げる)
//           throw AuthException(msg);
//         }

//         throw AuthException('トークン取得に失敗しました。');

//       }
      
//       // トークンを保存
//       await _setToken(token);

//     } on DioException catch (e) { // DioExceptionをハンドリング(HTTPエラー・ネットワークエラーをまとめて捕捉)
      

//       final status = e.response?.statusCode;

//       final body = e.response?.data;

//       // print('REQ => ${e.requestOptions.method} ${e.requestOptions.uri} type=${e.type} msg=${e.message} err=${e.error}');

//       // HTTPレスポンスがない時
//       if (status == null) {
//         throw AuthException('通信に失敗しました。ネット接続を確認してください。');
//       }

//       // Laravelの典型的な返し方: {message: "..."} or {errors: {...}}
//       String? pickMessage(dynamic b) { // dyanamic(型が不明)

//         // mapかどうか判定
//         if (b is Map) {

//           // messageを優先で拾う          
//           final msg = b['message'];

//           // msgを返す        
//           if (msg is String && msg.isNotEmpty) return msg;

//           // errorを拾う
//           final errors = b['errors'];

//           if (errors is Map && errors.isNotEmpty) {

//             // エラーの最初の値を拾う
//             final firstVal = errors.values.first;

//             // エラーがリストの場合
//             if (firstVal is List && firstVal.isNotEmpty) {
//               //Stringにして返す
//               return firstVal.first.toString();
//             }

//             // Stringにして返す(リストでない場合)
//             return errors.values.first.toString();

//           }

//         }

//         return null;
//       }

//       // HTTPステータス別エラー
//       if (status == 401) {
//         throw AuthException(pickMessage(body) ?? 'メールアドレスかパスワードが違います。');
//       }

//       if (status == 422) {
//         throw AuthException(pickMessage(body) ?? '入力内容を確認してください。');
//       }

//       if (status == 429) {
//         throw AuthException('リクエストが多すぎます。少し待ってから再度お試しください。');
//       }

//       // その他のエラー
//       throw AuthException(pickMessage(body) ?? 'ログインに失敗しました（$status）。');

//     }

//   }

//   // ユーザー登録
//   Future<void> register({
//     required String name,
//     required String email,
//     required String password,
//   }) async {
//     try {

//       // サーバからデータを送受信
//       final res = await _api.dio.post(
//         '/api/register',
//         data: {
//           'name': name.trim(),
//           'email': email.trim(),
//           'password': password, 
//         },
//       );
//       final data = res.data;

//       if (data is! Map) {
//         throw AuthException('サーバーの応答形式が不正です。');
//       }
//       final tokenAny = data['token'];
//       final token = tokenAny is String ? tokenAny : null;
//       if (token == null || token.isEmpty) {
//         final msg = data['message'];
//         if (msg is String && msg.isNotEmpty) throw AuthException(msg);
//         throw AuthException('トークン取得に失敗しました。');
//       }

//       // トークンをセット 
//       await _setToken(token);      

//     } on DioException catch (e) { // DioExceptionをハンドリング(HTTPエラー・ネットワークエラーをまとめて捕捉)
//       final status = e.response?.statusCode;
//       final body = e.response?.data;

//       String? pickMessage(dynamic b) {
//         if (b is Map) {
//           final msg = b['message'];
//           if (msg is String && msg.isNotEmpty) return msg;

//           final errors = b['errors'];
//           if (errors is Map && errors.isNotEmpty) {
//             final firstVal = errors.values.first;
//             if (firstVal is List && firstVal.isNotEmpty) return firstVal.first.toString();
//             return errors.values.first.toString();
//           }
//         }
//         return null;
//       }

//       if (status == null) {
//         throw AuthException('通信に失敗しました。ネット接続を確認してください。');
//       }
//       if (status == 422) {
//         throw AuthException(pickMessage(body) ?? '入力内容を確認してください。');
//       }
//       if (status == 409) {
//         throw AuthException(pickMessage(body) ?? 'すでに登録されています。');
//       }

//       throw AuthException(pickMessage(body) ?? '登録に失敗しました（$status）。');

//     }
//   }

//   /// ログイン中のユーザ情報取得
//   Future<Map<String, dynamic>> me() async {

//     // トークン取得    
//     final token = await getToken();

//     // トークンがない場合
//     if (token == null || token.isEmpty) {
//       throw AuthException('未ログインです。');
//     }


//     try {

//       // Apiリクエスト(get)      
//       final res = await _api.dio.get(
//         '/api/me',
//         options: Options(headers: {'Authorization': 'Bearer $token'}),
//       );

//       // マップかどうか
//       if (res.data is Map) {
//         return Map<String, dynamic>.from(res.data as Map);
//       }

//       // エラーを投げる
//       throw Exception('Unexpected response');

//     } on DioException catch (e) {

//       if (e.response?.statusCode == 401) { // セッション切れ

//         // トークン削除
//         await clearToken();

//         throw AuthException('セッションが切れました。もう一度ログインしてください。');
//       }

//       throw AuthException('ユーザー取得に失敗しました。');

//     }

//   }

//   /// ログアウト処理
//   Future<void> logoutApi() async {

//     // トークン確認
//     final token = await getToken();

//     // トークンがない場合
//     if (token == null || token.isEmpty) {
//       await clearToken();
//       return;
//     }

//     try {

//       // ログアウトapiにリクエスト(post)
//       await _api.dio.post(
//         '/api/logout',
//         options: Options(headers: {'Authorization': 'Bearer $token'}),
//       );

//     } finally {
//       await clearToken();
//     }
//   }

// }




import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../network/api_client.dart';
import '../exceptions/auth_exception.dart';
import '../models/user.dart';

class AuthService {
  AuthService({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  Future<String?> getToken() => _storage.read(key: _tokenKey);
  Future<void> _setToken(String token) => _storage.write(key: _tokenKey, value: token);
  Future<void> clearToken() => _storage.delete(key: _tokenKey);

  // 追加：ログイン中ユーザー（メモリ保持）
  User? _currentUser;

  // 追加：参照用（未ログインなら例外）
  User get currentUser {
    final u = _currentUser;
    if (u == null) throw AuthException('未ログインです。');
    return u;
  }

  bool get isLoggedIn => _currentUser != null;

  // 追加：/api/me を叩いて currentUser を更新
  Future<User> refreshMe() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      _currentUser = null;
      throw AuthException('未ログインです。');
    }

    try {
      final res = await _api.dio.get(
        '/api/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (res.data is! Map) {
        throw AuthException('ユーザー情報の形式が不正です。');
      }

      final user = User.fromJson(Map<String, dynamic>.from(res.data as Map));
      _currentUser = user;
      return user;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await clearToken();
        _currentUser = null;
        throw AuthException('セッションが切れました。もう一度ログインしてください。');
      }
      throw AuthException('ユーザー取得に失敗しました。');
    }
  }

  // login
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _api.dio.post(
        '/api/login',
        data: {
          'email': email.trim(),
          'password': password,
        },
      );

      final data = res.data;
      if (data is! Map) {
        throw AuthException('サーバーの応答形式が不正です。');
      }

      final tokenAny = data['token'];
      final token = tokenAny is String ? tokenAny : null;

      if (token == null || token.isEmpty) {
        final msg = data['message'];
        if (msg is String && msg.isNotEmpty) {
          throw AuthException(msg);
        }
        throw AuthException('トークン取得に失敗しました。');
      }

      await _setToken(token);

      // 追加：ログイン後にユーザー情報を取得して保持
      await refreshMe();
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data;

      String? pickMessage(dynamic b) {
        if (b is Map) {
          final msg = b['message'];
          if (msg is String && msg.isNotEmpty) return msg;

          final errors = b['errors'];
          if (errors is Map && errors.isNotEmpty) {
            final firstVal = errors.values.first;
            if (firstVal is List && firstVal.isNotEmpty) return firstVal.first.toString();
            return errors.values.first.toString();
          }
        }
        return null;
      }

      if (status == null) {
        throw AuthException('通信に失敗しました。ネット接続を確認してください。');
      }
      if (status == 401) {
        throw AuthException(pickMessage(body) ?? 'メールアドレスかパスワードが違います。');
      }
      if (status == 422) {
        throw AuthException(pickMessage(body) ?? '入力内容を確認してください。');
      }
      if (status == 429) {
        throw AuthException('リクエストが多すぎます。少し待ってから再度お試しください。');
      }

      throw AuthException(pickMessage(body) ?? 'ログインに失敗しました（$status）。');
    }
  }

  // register
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final res = await _api.dio.post(
        '/api/register',
        data: {
          'name': name.trim(),
          'email': email.trim(),
          'password': password,
        },
      );

      final data = res.data;
      if (data is! Map) {
        throw AuthException('サーバーの応答形式が不正です。');
      }

      final tokenAny = data['token'];
      final token = tokenAny is String ? tokenAny : null;

      if (token == null || token.isEmpty) {
        final msg = data['message'];
        if (msg is String && msg.isNotEmpty) throw AuthException(msg);
        throw AuthException('トークン取得に失敗しました。');
      }

      await _setToken(token);

      // 追加：登録後もユーザー情報を取得して保持
      await refreshMe();
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data;

      String? pickMessage(dynamic b) {
        if (b is Map) {
          final msg = b['message'];
          if (msg is String && msg.isNotEmpty) return msg;

          final errors = b['errors'];
          if (errors is Map && errors.isNotEmpty) {
            final firstVal = errors.values.first;
            if (firstVal is List && firstVal.isNotEmpty) return firstVal.first.toString();
            return errors.values.first.toString();
          }
        }
        return null;
      }

      if (status == null) {
        throw AuthException('通信に失敗しました。ネット接続を確認してください。');
      }
      if (status == 422) {
        throw AuthException(pickMessage(body) ?? '入力内容を確認してください。');
      }
      if (status == 409) {
        throw AuthException(pickMessage(body) ?? 'すでに登録されています。');
      }

      throw AuthException(pickMessage(body) ?? '登録に失敗しました（$status）。');
    }
  }

  /// 既存の me() は Map を返していたけど、今後は refreshMe() を使うのが自然
  /// どうしても Map が必要なら残してOK（下は互換用）
  Future<Map<String, dynamic>> me() async {
    final user = await refreshMe();
    return {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'avatar_url': user.avatarUrl,
    };
  }

  // logout
  Future<void> logoutApi() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      await clearToken();
      _currentUser = null;
      return;
    }

    try {
      await _api.dio.post(
        '/api/logout',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } finally {
      await clearToken();
      _currentUser = null;
    }
  }
}
