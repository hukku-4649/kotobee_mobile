import 'package:flutter/material.dart';


import '../screens/home_page.dart';
import '../screens/login_page.dart';

import '../locator/service_locator.dart';

import '../exceptions/auth_exception.dart';


class RegisterPage extends StatefulWidget {

    // コンストラクタ宣言
    const RegisterPage({super.key});

    // Stateを作成
    @override
    State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
    // formキー
    final _formKey = GlobalKey<FormState>();

    // controllers
    final _nickname = TextEditingController();
    final _email = TextEditingController();
    final _password = TextEditingController();
    final _confirmPassword = TextEditingController();
    final _secretAnswer = TextEditingController();

    // 規約に同意したかのフラグ
    bool _agree = false;

    // シークレットの質問内容
    final List<String> _questions = const [
        'What is the name of your first pet?',
        'What is your favorite food?',
        'What city were you born in?',
        'What is your mother’s maiden name?',
    ];

    // 現在選んでいる質問内容
    late String _selectedQuestion = _questions.first;

    // 色
    static const Color bg         = Color(0xFFFFF4C6); // 背景
    static const Color brown      = Color(0xFF744805); // 文字・枠
    static const Color brownLight = Color(0xFFAC7F5E); // 枠の薄い茶
    static const Color hint       = Color(0xFFC7AD8A); // ヒント文字
    static const Color buttonFill = Color(0xFFFFC653); // ボタン色

    // ローディングフラグ
    bool _loading = false;

    // エラーフラグ
    String? _errorText;

    // メモリ解放
    @override
    void dispose() {
        _nickname.dispose();
        _email.dispose();
        _password.dispose();
        _confirmPassword.dispose();
        _secretAnswer.dispose();
        super.dispose();
    }

    // 入力を送信(非同期処理)
    Future<void> _submit() async {

        FocusScope.of(context).unfocus();        
        setState(() => _errorText = null);

        // Stateがなかったらfalse
        final ok = _formKey.currentState?.validate() ?? false;
        if (!ok) return;

        final name = _nickname.text.trim();
        final email = _email.text.trim();
        final pass = _password.text;
        final confirm = _confirmPassword.text;

        if (name.isEmpty || email.isEmpty || pass.isEmpty || confirm.isEmpty) {
            setState(() => _errorText = '未入力の項目があります。');
            return;
        }

        if (!email.contains('@')) {
            setState(() => _errorText = 'Emailの形式が正しくありません。');
            return;
        }

        if (pass != confirm) {
            setState(() => _errorText = 'Passwordが一致しません。');
            return;
        }

        setState(() => _loading = true);

        try {

          await ServiceLocator.authService.register(
            name: name,
            email: email,
            password: pass,
          );

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('登録成功')),
          );

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (_) => HomePage(),
            ),
            (_) => false,
          );

        } on AuthException catch (e) {
          setState(() => _errorText = e.message);
        } catch (_) {
          setState(() => _errorText = '予期しないエラーが発生しました。');
        } finally {
          if (mounted) setState(() => _loading = false);
        }

    }

    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: bg,
            body: SafeArea(
                child: Center(
                    child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                        child: Form(
                            key: _formKey,
                            child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 420),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                    const SizedBox(height: 10),
                                    Text(
                                        'Sign Up',
                                        style: TextStyle(
                                        fontSize: 42,
                                        fontWeight: FontWeight.w800,
                                        color: brown,
                                        letterSpacing: 0.3,
                                        ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                        'Create an account to continue',
                                        style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: brown.withOpacity(0.9),
                                        ),
                                    ),
                                    const SizedBox(height: 22),

                                    // 上段の連結フォーム（Nickname/Email/Password/Confirm）
                                    _stackedGroup([

                                        _groupTextField(
                                            controller: _nickname,
                                            title: 'Nick name',
                                            hintText: 'Enter your nick name',
                                        ),

                                        _groupTextField(
                                            controller: _email,
                                            title: 'Email',
                                            hintText: 'example@gmail.com',
                                            validator: (v) {
                                                final text = (v ?? '').trim();
                                                if (text.isEmpty) return 'Required';
                                                if (!text.contains('@')) return 'Invalid email';
                                                return null;
                                            },
                                        ),

                                        _groupTextField(
                                            controller: _password,
                                            title: 'Password',
                                            hintText: 'Enter your password',
                                            obscure: true,
                                        ),

                                        _groupTextField(
                                            controller: _confirmPassword,
                                            title: 'Confirm password',
                                            hintText: 'Re-enter your password',
                                            obscure: true,
                                            validator: (v) {
                                                if ((v ?? '') != _password.text) {
                                                    return 'Passwords do not match';
                                                }
                                                return null;
                                            },
                                        ),

                                    ]),

                                    const SizedBox(height: 10),

                                    // Already have an account? Log In
                                    Align(
                                        alignment: Alignment.centerRight,
                                        child: Wrap(
                                            crossAxisAlignment: WrapCrossAlignment.center,
                                            children: [
                                                Text(
                                                    'Already have an account? ',
                                                    style: TextStyle(
                                                        color: Colors.black.withOpacity(0.85),
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w500,
                                                    ),
                                                ),
                                                GestureDetector(
                                                    onTap: () => Navigator.pop(context),
                                                    child: Text(
                                                        'Log In',
                                                        style: TextStyle(
                                                        color: brown,
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w800,
                                                        decoration: TextDecoration.underline,
                                                        decorationColor: brown,
                                                        ),
                                                    ),
                                                )
                                            ],
                                        ),
                                    ),

                                    const SizedBox(height: 12),

                                    // Secret question（1フィールド分の枠）
                                    Container(
                                        decoration: BoxDecoration(
                                        border: Border.all(color: brownLight, width: 2),
                                        borderRadius: BorderRadius.circular(16),
                                        color: Colors.white,
                                        ),
                                        padding:
                                            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                        child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            
                                            const Text(
                                            'Secret question',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                            ),
                                            ),                        
                                            
                                            DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                                isExpanded: true,
                                                value: _selectedQuestion,
                                                icon: const Icon(
                                                Icons.arrow_drop_down,
                                                color: brown,
                                                ),
                                                items: _questions
                                                    .map(
                                                    (q) => DropdownMenuItem(
                                                        value: q,
                                                        child: Text(
                                                        q,
                                                        style: const TextStyle(
                                                            color: Colors.black,
                                                            fontWeight: FontWeight.w600,
                                                        ),
                                                        ),
                                                    ),
                                                    )
                                                    .toList(),
                                                onChanged: (v) {
                                                if (v == null) return;
                                                setState(() => _selectedQuestion = v);
                                                },
                                            ),
                                            ),
                                            
                                        ],
                                        ),
                                    ),

                                    const SizedBox(height: 12),

                                    // Secret answer
                                    Container(
                                        decoration: BoxDecoration(
                                        border: Border.all(color: brownLight, width: 2),
                                        borderRadius: BorderRadius.circular(16),
                                        color: Colors.white,
                                        ),
                                        padding:
                                            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                        child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            const Text(
                                            'Secret answer',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                            ),
                                            ),
                                            const SizedBox(height: 6),
                                            TextField(
                                            controller: _secretAnswer,
                                            decoration: const InputDecoration(
                                                isDense: true,
                                                hintText: 'Enter your answer',
                                                hintStyle: TextStyle(color: hint),
                                                border: InputBorder.none,
                                            ),
                                            ),
                                        ],
                                        ),
                                    ),

                                    const SizedBox(height: 14),

                                    // Privacy Policy agree
                                    Row(
                                        children: [
                                        SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: Checkbox(
                                            value: _agree,
                                            onChanged: (v) => setState(() => _agree = v ?? false),
                                            side: const BorderSide(color: brown, width: 2),
                                            activeColor: brown,
                                            checkColor: Colors.white,
                                            ),
                                        ),
                                        const SizedBox(width: 10),
                                        const Text(
                                            'I agree to the ',
                                            style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            ),
                                        ),
                                        GestureDetector(
                                            onTap: () {
                                            // TODO: open privacy policy
                                            },
                                            child: Text(
                                            'Privacy Policy',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w800,
                                                color: brown,
                                                decoration: TextDecoration.underline,
                                                decorationColor: brown,
                                            ),
                                            ),
                                        ),
                                        ],
                                    ),

                                    const SizedBox(height: 16),

                                    // Sign Up button
                                    SizedBox(
                                        width: double.infinity,
                                        height: 54,
                                        child: ElevatedButton(
                                        onPressed: (_agree && !_loading) ? _submit : null,                                
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: buttonFill,
                                            disabledBackgroundColor: buttonFill.withOpacity(0.55),
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                            side: const BorderSide(color: brownLight, width: 2),
                                            ),
                                        ),
                                        child: const Text(
                                            'Sign Up',
                                            style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            ),
                                        ),
                                        ),
                                    ),
                                    const SizedBox(height: 6),
                                    ],
                                ),
                            ),
                        ),                       
                    ),
                ),
            ),
        );
    }

    InputDecoration _fieldDecoration({
        required String label,
        required String hintText,
    }) {
        return InputDecoration(
        labelText: label,
        hintText: hintText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
        ),
        hintStyle: const TextStyle(color: hint),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: brownLight, width: 1.6),
        ),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: brownLight, width: 1.6),
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: brown, width: 2.0),
        ),
        );
    }

    Widget _stackedGroup(List<Widget> children) {
        // 画像みたいに「1つの枠に複数フィールドが連結」して見えるグループ
        // → 各フィールドの角丸を上下だけに割り当てて、間の境界線を作る
        return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: brownLight, width: 2),
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                ),
                child: Column(
                    children: [
                        for (int i = 0; i < children.length; i++) ...[
                        children[i],
                        if (i != children.length - 1)
                            const Divider(height: 1, thickness: 1, color: brownLight),
                        ]
                    ],
                ),
            ),
        );
    }

    // Widget _groupTextField({
    //     required TextEditingController controller,
    //     required String title,
    //     required String hintText,
    //     bool obscure = false,
    // }) {
    //     return Padding(
    //         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),

    //         child: Column(

    //             crossAxisAlignment: CrossAxisAlignment.start,

    //             children: [

    //                 Text(
    //                     title,
    //                     style: const TextStyle(
    //                         fontSize: 14,
    //                         fontWeight: FontWeight.w700,
    //                         color: Colors.black,
    //                     ),
    //                 ),

    //                 const SizedBox(height: 6),

    //                 TextField(
    //                     controller: controller,
    //                     obscureText: obscure,
    //                     decoration: InputDecoration(
    //                         isDense: true,
    //                         hintText: hintText,
    //                         hintStyle: const TextStyle(color: hint),
    //                         border: InputBorder.none,
    //                     ),
    //                 ),

    //             ],
    //         ),
    //     );
    // }


    Widget _groupTextField({
        required TextEditingController controller,
        required String title,
        required String hintText,
        bool obscure = false,
        String? Function(String?)? validator,        
    }) {
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(
                        title,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                        ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                        controller: controller,
                        obscureText: obscure,
                        validator: validator ??
                            (v) {
                                if ((v ?? '').trim().isEmpty) {
                                    return 'Required';
                                }
                                return null;
                            },
                        decoration: InputDecoration(
                            isDense: true,
                            hintText: hintText,
                            hintStyle: const TextStyle(color: hint),
                            border: InputBorder.none,
                        ),
                    ),
                ],
            ),
        );
    }



}