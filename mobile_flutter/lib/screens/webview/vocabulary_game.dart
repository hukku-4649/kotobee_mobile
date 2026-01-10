import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import '../../widgets/result_modal.dart';

class VocabularyGamePage extends StatefulWidget {

    const VocabularyGamePage({
        super.key,
        required this.initialUrl,
        required this.title,
    });

    final String initialUrl;
    final String title;

    @override
    State<VocabularyGamePage> createState() => _VocabularyGamePageState();

}

class _VocabularyGamePageState extends State<VocabularyGamePage> {

    late final WebViewController _controller;

    bool _isLoading = true;

    @override
    void initState() {
        super.initState();

        _controller = WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..addJavaScriptChannel(
                'FlutterPostMessage',
                onMessageReceived: (message) {

                    debugPrint('[Flutter] JS message received');

                    Map<String, dynamic> data;
                    try {
                        final decoded = jsonDecode(message.message);
                        if (decoded is! Map) {
                            debugPrint('message is not a Map: ${decoded.runtimeType}');
                            return;
                        }
                        data = Map<String, dynamic>.from(decoded);
                    } catch (e) {
                        debugPrint('jsonDecode error: $e');
                        return;                        
                    }

                    if (data['type'] == 'vocabulary_result') {

                        debugPrint('[Flutter] vocabulary_result received');

                        final payloadRaw = data['payload'];
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

                        final score = toDoubleOrNull(data['score']) ?? 0.0;
                        final bestTime = toDoubleOrNull(payload['my_best']);
                        final rank = toIntOrNull(payload['my_rank']);
                        final top3raw = payload['top3'];
                        debugPrint('top3 element runtime: ${top3raw.runtimeType}');
                        debugPrint('top3 raw: $top3raw');
                        final top3 = (top3raw is List)
                            ? top3raw
                                .where((e) => e is Map)
                                .map((e) => Map<String, dynamic>.from(e as Map))
                                .toList()
                            : <Map<String, dynamic>>[];                        


                        if (!mounted) return;

                        debugPrint('[Flutter] showing result modal');
                        
                        // resultmodalを出力する
                        _showResultModal( 
                            score: score,
                            bestTime: bestTime,
                            rank: rank,
                            top3: top3,
                        );

                    }
                }
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