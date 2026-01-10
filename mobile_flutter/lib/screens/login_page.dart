import 'package:flutter/material.dart';

import '../screens/home_page.dart';
import '../screens/register_page.dart';

import '../locator/service_locator.dart';

import '../exceptions/auth_exception.dart';

// 画像url
final String logoUrl =
  '${ServiceLocator.baseUrl}/flutter/images/icons/kotobee_logo.png';

class LoginPage extends StatefulWidget {

  // コンストラクタ宣言
  const LoginPage({super.key});

  // Stateを作成
  @override
  State<LoginPage> createState() => _LoginPageState();  
}

class _LoginPageState extends State<LoginPage> {
  // FromのWidgeのキー
  final _formKey = GlobalKey<FormState>();
  // メールアドレス入力用のコントローラー
  final _emailCtrl = TextEditingController();
  // パスワード入力用のコントローラー
  final _passCtrl = TextEditingController();  

  bool _loading = false;

  // エラーテキスト変数 (初期値がnullでStringが持てる)
  String? _errorText;

  // 実行後メモリ解放
  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // 非同期処理のメソッド宣言(API通信が非同期なため)
  Future<void> _submit() async {

    // キーボードを閉じる
    FocusScope.of(context).unfocus();

    // エラー表示をリセット(setStateなのでbuildが呼び出される)
    setState(() => _errorText = null);

    // フォームのバリデーション(nullの場合はfalse)
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    // ローディングをtrueににしてsetState
    setState(() => _loading = true);

    // tryブロック
    try {

      await ServiceLocator.authService.login(
        // trimで前後空白を除去
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );

      // 現在のStateが破棄されていたらreturn
      if (!mounted) return;

      // 一時的な成功メッセージを表示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ログイン成功')),
      );

      // 画面遷移
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          // 認証状態を共有してホーム画面に遷移
          builder: (_) => HomePage(),
        ),
      );

    } on AuthException catch (e) { // 想定内エラー(AuthException)
      // ユーザー向けエラーメッセージ表示
      setState(() => _errorText = e.message);
    } catch (_) { // 想定外エラー(catch all)
      setState(() => _errorText = '予期しないエラーが発生しました。');
    } finally { // finally(必ず実行)
      // 成功でも失敗でもローディング終了
      if (mounted) setState(() => _loading = false);
    }

  }

  // 色
  static const bg      = Color(0xFFFFF4C6);
  static const hill    = Color(0xFFFFE693); 
  static const brown   = Color(0xFF744805);
  static const border  = Color(0xFFAC7F5E);
  static const fieldBg = Color(0xFFF8F6E6);
  static const btn     = Color(0xFFFFC653);  


  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final size = mq.size;
    final formWidth = (size.width * 0.78).clamp(280.0, 420.0);    

    final bottomInset = mq.viewInsets.bottom;

    // “本来の画面高さ”を基準にしたいので足し戻す
    final fullHeight = size.height + bottomInset;


    // Scaffoldが縮んだ後の size.height + キーボード高さ = “本来の画面高さ”扱いにする
    // final fullHeight = size.height + mq.viewInsets.bottom;


    return Scaffold(
      backgroundColor: bg,
      resizeToAvoidBottomInset: true,                  

        body: Stack(

          children: [     

            // ① 背面のロゴ画像（背景に隠れる）
            Positioned(
              left: 0,
              right: 0,
              top: fullHeight * 0.15,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // タイトル
                  Text(
                    'Koto Bee',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      color: brown,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ロゴ
                  Image.network(
                    logoUrl,
                    width: 220,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),                

            // ★背景：キーボード分だけ下へ逃がして、画面下端に固定
            Positioned(
              left: 0,
              right: 0,
              bottom: -bottomInset, // ←これが効く
              child: ClipPath(
                clipper: TopArchClipper(archHeight: 120),
                child: Container(
                  height: fullHeight * 0.6,
                  color: hill,                  
                ),
              ),
            ),

            // メインUI
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      24,
                      16,
                      24,
                      16 + MediaQuery.viewInsetsOf(context).bottom,
                    ),

                    child: ConstrainedBox (
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(

                        child: Center(
                                      
                          child: Column(
                            
                            mainAxisSize: MainAxisSize.min,
                            
                            children: [

                              const SizedBox(height: 300),

                              // エラーメッセージ
                              if (_errorText != null) ...[
                                Container(
                                  width: formWidth,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.errorContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _errorText!,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onErrorContainer,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],

                              // 入力フォーム（Email/Passwordが一体のカード）
                              SizedBox(

                                width: formWidth,

                                child: Form(

                                  key: _formKey,

                                  child: Container(

                                    decoration: BoxDecoration(
                                      color: fieldBg,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: border, width: 2),
                                    ),

                                    child: Column(

                                      children: [

                                        _LabeledField(
                                          label: 'Email',
                                          hint: 'example@email.com',
                                          isPassword: false,
                                          showDivider: true,
                                          controller: _emailCtrl,
                                          validator: (v) {
                                            final s = (v ?? '').trim();
                                            if (s.isEmpty) return 'Emailを入力してください';
                                            if (!s.contains('@')) return 'Emailの形式が正しくありません';
                                            return null;
                                          },
                                        ),

                                        _LabeledField(
                                          label: 'Password',
                                          hint: 'Enter your password',
                                          isPassword: true,
                                          showDivider: false,
                                          controller: _passCtrl,
                                          validator: (v) {
                                            final s = v ?? '';
                                            if (s.isEmpty) return 'Passwordを入力してください';
                                            return null;
                                          }
                                        ),

                                      ],

                                    ),

                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              // Log In ボタン
                              SizedBox(
                                width: formWidth,
                                height: 54,
                                child: ElevatedButton(

                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: btn,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(color: border, width: 2),
                                    ),
                                  ),

                                  onPressed: _loading ? null : _submit,

                                  child: _loading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),                              
                                      )
                                    : const Text(
                                        'Log In',
                                        style: TextStyle(fontSize: 18),
                                      )                  
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Forgot password?
                              TextButton(

                                onPressed: _loading
                                  ? null
                                  : () {
                                      // TODO: ForgotPasswordPageへ
                                    },
                                
                                style: TextButton.styleFrom(
                                  foregroundColor: border,
                                  textStyle: const TextStyle(decoration: TextDecoration.underline),
                                ),

                                child: const Text('Forgot password?'),
                              ),

                              // Don’t have an account? Sign up
                              Row(
                                
                                mainAxisAlignment: MainAxisAlignment.center,
                                
                                children: [
                                  
                                  const Text(
                                    "Don’t have an account? ",
                                    style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                                  ),
                                  
                                  TextButton(

                                    // ローディング中は押せない
                                    onPressed: _loading
                                      ? null
                                      : () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => RegisterPage(),
                                            ),
                                          );
                                        },

                                    style: TextButton.styleFrom(
                                      foregroundColor: border,
                                      textStyle: const TextStyle(
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),

                                    child: const Text('Sign up'),

                                  ),                          
                                  
                                ],
                              ),
                            ],
                          ),


                        ),


                      ),
                    ),
                  );
                },
              ),            
            ),

            

          ],
        ),
      );
    }  
  }




// 入力フォームのクラス
class _LabeledField extends StatelessWidget {
  
  // コンストラクタ
  const _LabeledField({
    required this.label,
    required this.hint,
    required this.isPassword,
    required this.showDivider,
    required this.controller,
    this.validator,
  });
  
  // プロパティ宣言
  final String label;
  final String hint;
  final bool isPassword;
  final bool showDivider;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  
  // 色
  static const border = Color(0xFFAC7F5E);

  @override
  Widget build(BuildContext context) {
    
    final baseStyle = Theme.of(context).textTheme.bodyMedium;

    return Container(
      
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      
      decoration: BoxDecoration(
        border: showDivider ? const Border(bottom: BorderSide(color: border, width: 2)) : null,
      ),
      
      child: Column(
        
        crossAxisAlignment: CrossAxisAlignment.start,
        
        children: [
          
          Text(
            label,
            style: baseStyle?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 6),                

          TextFormField(
            controller: controller,
            obscureText: isPassword,
            validator: validator,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: hint,
              hintStyle: baseStyle?.copyWith(
                color: Colors.brown.withOpacity(0.45),
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          
        ],
      ),
      
    );
  }
}


/// 背景の上のアーチ部分の関数
class TopArchClipper extends CustomClipper<Path> {
  
  // コンストラクタ
  TopArchClipper({required this.archHeight});
  
  // プロパティ宣言
  final double archHeight;

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    final y = archHeight.clamp(0.0, h);

    final path = Path()
      // 左下
      ..moveTo(0, h)
      // 左上(yまで)
      ..lineTo(0, y)
      // アーチ描写
      ..quadraticBezierTo(w * 0.25, 0, w * 0.5, 0)
      ..quadraticBezierTo(w * 0.75, 0, w, y)      
      // 右下
      ..lineTo(w, h)
      // 描写終了
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant TopArchClipper oldClipper) {
    return oldClipper.archHeight != archHeight;
  }
  
}




// build(setStateが実行されるたびに呼び出し、methodなのでoverrideで上書き)
  // @override
  // Widget build(BuildContext context) {
  //   // Scaffold(materialアプリの基本骨格)
  //   return Scaffold(
  //     // Stack(背面と前面を重ねる)
  //     body: Stack(
  //       children: [
  //         // Positioned(Stack内で位置を固定するwidget)
  //         Positioned(
  //           left: 0,
  //           right: 0,
  //           bottom: 0,
  //           child: const SizedBox.shrink(),
  //           // Image.asset(pubspec.yamlに登録が必要)
  //           // child: Image.asset(
  //           //   'assets/images/commons/mountain.png',
  //           //   // 領域に合うように拡大縮小
  //           //   fit: BoxFit.cover,
  //           // ),
  //         ),

  //         // SafeArea(前面:ノッチやステータスバーに被らないようにする)
  //         SafeArea(
  //           // 中央寄せ
  //           child: Center(
  //             // キーボードが出て画面が狭くなってもスクロール可能
  //             child: SingleChildScrollView(
  //               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
  //               // 最大幅制限(420)
  //               child: ConstrainedBox(
  //                 constraints: const BoxConstraints(maxWidth: 420),

  //                 // 縦に並べるwidget
  //                 child: Column(

  //                   // 中身に必要な分だけのサイズにする
  //                   mainAxisSize: MainAxisSize.min,

  //                   children: [

  //                     // タイトルテキスト
  //                     const Text(
  //                       'KotoBee',
  //                       style: TextStyle(
  //                         fontSize: 40,
  //                         fontWeight: FontWeight.w800,
  //                         letterSpacing: 0.5,
  //                       ),
  //                     ),

  //                     // 余白
  //                     const SizedBox(height: 16),

  //                     const SizedBox(
  //                       height: 120,
  //                     ),
  //                     // イラスト
  //                     // Image.asset(
  //                     //   'assets/images/commons/bee_flower.png',
  //                     //   height: 120,
  //                     // ),                      

  //                     // 余白
  //                     const SizedBox(height: 24),

  //                     // Card(影付きのパネル)
  //                     Card(
  //                       // 影を強めにする
  //                       elevation: 10,
  //                       // 角丸16
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(16),
  //                       ),

  //                       // padding(20)
  //                       child: Padding(
  //                         padding: const EdgeInsets.all(20),

  //                         // Form(バリデーションをまとめて管理するためのForm)
  //                         child: Form(

  //                           // Formキー
  //                           key: _formKey,


  //                           child: Column(                            
  //                             mainAxisSize: MainAxisSize.min,

  //                             children: [

  //                               // テキスト
  //                               const Text(
  //                                 'Login',
  //                                 style: TextStyle(
  //                                   fontSize: 22,
  //                                   fontWeight: FontWeight.bold,
  //                                 ),
  //                               ),

  //                               // 余白
  //                               const SizedBox(height: 16),

  //                               // エラーがある時表示(...は複数widgetをその場で展開するスプレッド構文)
  //                               if (_errorText != null) ...[

  //                                 Container(
  //                                   width: double.infinity,
  //                                   padding: const EdgeInsets.all(12),
  //                                   decoration: BoxDecoration(
  //                                     color: Theme.of(context).colorScheme.errorContainer,
  //                                     borderRadius: BorderRadius.circular(8),
  //                                   ),
  //                                   child: Text(
  //                                     _errorText!,
  //                                     style: TextStyle(
  //                                       color: Theme.of(context).colorScheme.onErrorContainer,
  //                                     ),
  //                                   ),
  //                                 ),

  //                                 // 余白
  //                                 const SizedBox(height: 12),
  //                               ],

  //                               // Emailのformfield
  //                               TextFormField(
  //                                 // emailctrl
  //                                 controller: _emailCtrl,
  //                                 // メール用キーボードを出しやすくする
  //                                 keyboardType: TextInputType.emailAddress,
  //                                 // osの自動入力候補を出す                            
  //                                 autofillHints: const [
  //                                   AutofillHints.username,
  //                                   AutofillHints.email
  //                                 ],

  //                                 // decoration                                  
  //                                 decoration: const InputDecoration(
  //                                   labelText: 'Email Address',
  //                                   hintText: 'example@example.com',
  //                                   border: OutlineInputBorder(),
  //                                 ),

  //                                 // 
  //                                 validator: (v) {
  //                                   final s = (v ?? '').trim();
  //                                   // 入力がない時
  //                                   if (s.isEmpty) return 'Emailを入力してください';
  //                                   // @が含まれていない時
  //                                   if (!s.contains('@')) return 'Emailの形式が正しくありません';
  //                                   // 成功時null
  //                                   return null;
  //                                 },

  //                               ),

  //                               // 余白
  //                               const SizedBox(height: 12),

  //                               // Passwordのformfield
  //                               TextFormField(
  //                                 // passCtrl
  //                                 controller: _passCtrl,
  //                                 // 伏字表示
  //                                 obscureText: true,

  //                                 autofillHints: const [AutofillHints.password],

  //                                 decoration: const InputDecoration(
  //                                   labelText: 'Password',
  //                                   border: OutlineInputBorder(),
  //                                 ),

  //                                 validator: (v) {
  //                                   final s = v ?? '';
  //                                   if (s.isEmpty) return 'Passwordを入力してください';
  //                                   return null;
  //                                 },

  //                                 // キーボードのEnterで_submit()実行
  //                                 onFieldSubmitted: (_) => _submit(),
  //                               ),

  //                               // 余白
  //                               const SizedBox(height: 16),

  //                               // Submit
  //                               SizedBox(

  //                                 width: double.infinity,

  //                                 child: ElevatedButton(

  //                                   // ローディングしている場合null
  //                                   onPressed: _loading ? null : _submit,

  //                                   // ローディング中は押せない
  //                                   child: _loading
  //                                       ? const SizedBox(
  //                                           height: 20,
  //                                           width: 20,
  //                                           child: CircularProgressIndicator(strokeWidth: 2),
  //                                         )
  //                                       : const Text('Login'),
  //                                 ),
  //                               ),

  //                               // Forgot Password?（Bladeと同じ位置）
  //                               TextButton(
  //                                 // ローディング中は押せない
  //                                 onPressed: _loading
  //                                     ? null
  //                                     : () {
  //                                         // TODO: ForgotPasswordPageへ
  //                                       },
  //                                 child: const Text('Forgot Your Password?'),
  //                               ),

  //                               // Register（Bladeと同じ）
  //                               TextButton(
  //                                 // ローディング中は押せない
  //                                 onPressed: _loading
  //                                     ? null
  //                                     : () {
  //                                         // TODO: RegisterPageへ
  //                                       },
  //                                 child: const Text('Create a new account'),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }