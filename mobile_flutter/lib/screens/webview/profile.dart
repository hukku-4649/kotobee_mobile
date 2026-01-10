import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';

import '../../widgets/common_app_bar.dart';


class ProfilePage extends StatefulWidget {

    const ProfilePage({
        super.key,
        required this.initialUrl,
    });

    final String initialUrl;

    @override
    State<ProfilePage> createState() => _ProfilePageState();
}

class  _ProfilePageState extends State<ProfilePage> {

    // webviewコントローラー
    late final WebViewController _controller;

    // ローディングフラグ
    bool _isLoading = true;

    // ローディング開始関数
    void _startLoading() {
        if (mounted) setState(() => _isLoading = true);
    }

    // ローディング終了関数
    void _endLoading() {
        if (mounted) setState(() => _isLoading = false);
    }

    // initState //
    @override
    void initState() {
        super.initState();
        _controller = WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted) // JavaScriptを有効化
            ..setNavigationDelegate( // ローディング監視
                NavigationDelegate(

                    onNavigationRequest: (request) {
                        if (request.url == 'flutter://back') {
                            Navigator.of(context).pop(); // Flutterに戻る
                            return NavigationDecision.prevent;
                        }
                        return NavigationDecision.navigate;
                    },

                    onPageStarted: (_) => setState(() => _isLoading = true),                    
                    onPageFinished: (_) => setState(() => _isLoading = false),
                ),
            )
            ..loadRequest(Uri.parse(widget.initialUrl)); // uriに変換して読み込み

    }

    // build //
    @override
    Widget build(BuildContext context) {
        return Scaffold(
             
            appBar: CommonAppBar(
                title: 'Group 1',
                loading: _isLoading,
                onStartLoading: _startLoading,
                onEndLoading: _endLoading,
            ),

            body: Stack(
                children: [
                    WebViewWidget(controller: _controller),
                    if (_isLoading) const Center(child: CircularProgressIndicator()),
                ],
            ),

        );
    }
}