import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import '../../widgets/result_modal.dart';

class GrammarGamePage extends StatefulWidget {

    const GrammarGamePage({
        super.key,
        required this.initialUrl,
        required this.title,
    });

    final String initialUrl;
    final String title;

    @override
    State<GrammarGamePage> createState() => _GrammarGamePageState();

}

class _GrammarGamePageState extends State<GrammarGamePage> {

    late final WebViewController _controller; // webviewコントローラー

    bool _isLoading = true; 

    @override
    void initState() {

        super.initState();

        _controller = WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted) // JavaScriptを有効化            
            ..addJavaScriptChannel( // javascriptからデータを受信

                'FlutterPostMessage',

                onMessageReceived: (message) {

                    // debugPrint('JS -> Flutter: ${message.message}');

                    Map<String, dynamic> m;

                    try {

                        // jsからのjsonファイルをデコード
                        final decoded = jsonDecode(message.message); 

                        if (decoded is! Map) { // mapではない時エラー
                            debugPrint('message is not a Map: ${decoded.runtimeType}');
                            return;
                        }

                        // mapの形式を変換
                        m = Map<String, dynamic>.from(decoded);

                    } catch (e) {

                        debugPrint('jsonDecode error: $e');

                        return;

                    }

                    
                    if (m['type'] == 'grammar_result') {


                        final payloadRaw = m['payload'];

                        // pyloadRawがmapでない時は空
                        final payload = (payloadRaw is Map)
                            ? Map<String, dynamic>.from(payloadRaw)
                            : <String, dynamic>{};

                        // scoreとbesttimeのための型変換(関数)
                        double? toDoubleOrNull(dynamic v) {
                            if (v == null) return null;
                            if (v is num) return v.toDouble();
                            if (v is String) return double.tryParse(v);
                            return null;
                        }

                        // rankのための型変換(関数)
                        int? toIntOrNull(dynamic v) {
                            if (v == null) return null;
                            if (v is int) return v;
                            if (v is num) return v.toInt();
                            if (v is String) {
                                // "1" も "1.0" も通す
                                return int.tryParse(v) ?? double.tryParse(v)?.toInt();
                            }
                            return null;
                        }

                        final score = toDoubleOrNull(m['score']) ?? 0.0;
                        final bestTime = toDoubleOrNull(payload['best_time']);
                        final rank = toIntOrNull(payload['rank']);
                        final top3raw = payload['top3'];
                        final top3 = (top3raw is List)
                            ? top3raw
                                .where((e) => e is Map)
                                .map((e) => Map<String, dynamic>.from(e as Map))
                                .toList()
                            : <Map<String, dynamic>>[];

                        if (!mounted) return;

                        // resultmodalを出力する
                        _showResultModal( 
                            score: score,
                            bestTime: bestTime,
                            rank: rank,
                            top3: top3,
                        );

                    }                    

                },

            )
            ..setNavigationDelegate(
                 NavigationDelegate(
                    onPageStarted: (_) => setState(() => _isLoading = true), // 読み込み開始
                    onPageFinished: (_) => setState(() => _isLoading = false), // 読み込み終了
                    onWebResourceError: (e) { // エラー処理
                        // 必要ならエラー表示
                    },
                ),
            )
            ..loadRequest(Uri.parse(widget.initialUrl)); // 指定したURLを読み込む            
    
    }

    //// 結果modal出力 ////
    void _showResultModal({
        required double score,
        required double? bestTime,
        required int? rank,
        required List<Map<String, dynamic>> top3,
    }) {

        if (!mounted) return;

        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => GrammarResultModal(
                score: score,
                bestTime: bestTime,
                rank: rank,
                top3: top3,
                onRetry: () {
                    Navigator.of(context).pop(); // モーダル閉じる
                    _controller.reload();        // WebView リロード（再プレイ）
                },
                onBack: () {
                    Navigator.of(context).pop(); // モーダル閉じる
                    Navigator.of(context).pop(); // WebView 画面を閉じてステージマップへ
                },
            ),
        );

    }

    //// build ////
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: Text(widget.title)),
            body: Stack(
                children: [
                    WebViewWidget(controller: _controller), //WebViewを表示
                    if (_isLoading) const Center(child: CircularProgressIndicator()),
                ],
            ),
        );
    }    

}