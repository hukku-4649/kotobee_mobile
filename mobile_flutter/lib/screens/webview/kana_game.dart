import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import '../../widgets/result_modal.dart';

class KanaGamePage extends StatefulWidget {

    const KanaGamePage({
        super.key,
        required this.initialUrl,
        required this.title,        
    });

    final String initialUrl;
    final String title;

    @override
    State<KanaGamePage> createState() => _KanaGamePageState();

}

class _KanaGamePageState extends State<KanaGamePage> {

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

                    Map<String, dynamic> data;

                    try {
                        final decoded = jsonDecode(message.message);
                        if (decoded is! Map) {
                            debugPrint('message is not a Map: ${decoded.runtimeType}');
                            return;                
                        };
                        data = Map<String, dynamic>.from(decoded);                       
                    } catch(e) {
                        debugPrint('jsonDecode error: $e');
                        return;
                    }

                    if (data['type'] == 'kana_result') {
                        final payloadRaw = data['payload'];
                        final payload = (payloadRaw is Map)
                            ? Map<String, dynamic>.from(payloadRaw)
                            : <String, dynamic>{};
                        String mode = (payload['mode'] ?? '').toString();

                        // 型処理
                        double? toDoubleOrNull(dynamic v) {
                            if (v == null) return null;
                            if (v is num) return v.toDouble();
                            if (v is String) return double.tryParse(v);
                            return null;
                        }

                        // 型処理                        
                        int? toIntOrNull(dynamic v) {
                            if (v == null) return null;
                            if (v is int) return v;
                            if (v is num) return v.toInt();
                            if (v is String) {
                                return int.tryParse(v) ?? double.tryParse(v)?.toInt();
                            }
                            return null;
                        }

                        // payloadからデータを取る
                        final score = toDoubleOrNull(payload['score']) ?? 0.0;
                        final bestTime = toDoubleOrNull(payload['best_time']); // timeattackのみ入る
                        final rank = toIntOrNull(payload['rank']);
                        final top3raw = payload['top3'];
                        final top3 = (top3raw is List)
                            ? top3raw
                                .where((e) => e is Map)
                                .map((e) => Map<String, dynamic>.from(e as Map))
                                .toList()
                            : <Map<String, dynamic>>[];
                        final unit = (mode == '60s-count') ? 'こ' : 'sec';

                        if (!mounted) return;

                        _showResultModal(
                            score: score,
                            bestTime: bestTime,
                            rank: rank,
                            top3: top3,
                            unit: unit,
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
        required String unit,
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
                unit: unit,
                onRetry: () {
                    Navigator.of(context).pop(); // modal閉じる
                    _controller.reload();        // WebViewリロードして再プレイ
                },
                onBack: () {
                    Navigator.of(context).pop(); // modal閉じる
                    Navigator.of(context).pop(); // WebViewを閉じる                
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