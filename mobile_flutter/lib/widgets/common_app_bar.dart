import 'package:flutter/material.dart';
import '../screens/home_page.dart';
import '../services/logout_service.dart';

import '../utils/webview_launcher.dart';

import '../locator/service_locator.dart'; // ✅ 追加
// import '../config/config.dart'; // ✅ Config を使うなら追加（無いなら後述）

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
    final String title;
    final bool loading;
    final VoidCallback onStartLoading;
    final VoidCallback onEndLoading;

    const CommonAppBar({
        Key? key,
        required this.title,
        required this.loading,
        required this.onStartLoading,
        required this.onEndLoading,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
        final authService = ServiceLocator.authService;

          // 未ログインや未取得でも落ちないようにする
        String? avatarUrl;
        try {
        avatarUrl = authService.currentUser.avatarUrl;
        } catch (_) {
        avatarUrl = null;
        }

        final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

        return AppBar(
            backgroundColor: const Color(0xFF6E6F63),

            leading: GestureDetector(
                onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => HomePage()),
                        (route) => false, // 全てのrouteを削除
                    );
                },
                child: SizedBox.expand(
                    child: Image.asset(
                        'assets/nav_logo.png',
                        fit: BoxFit.contain,
                    ),
                ),
            ),

            title: Text(
                title,
                style: const TextStyle(color: Colors.white),
            ),

            // actions: [
            //     PopupMenuButton<String>(

            //         icon: const Icon(Icons.menu),

            //         onSelected: (value) async {
            //             if (!loading) {
            //                 if (value == 'log out') {
            //                     LogoutService.logout(
            //                         context: context,
            //                         onStartLoading: onStartLoading,
            //                         onEndLoading: onEndLoading,
            //                     );
            //                 } else if (value == 'profile') {
            //                     await WebViewLauncher.openProfile(context);
            //                 }
            //             }
            //         },

            //         itemBuilder: (context) => const [
            //             PopupMenuItem(value: 'group1', child: Text('Group 1')),
            //             PopupMenuItem(value: 'profile', child: Text('profile')),
            //             PopupMenuItem(value: 'log out', child: Text('log out')),
            //         ],

            //     ),
            // ],

            actions: [
                Row(
                    children: [

                        // 👤 アバター画像                        

                        Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.grey.shade300,
                                backgroundImage: hasAvatar
                                    ? NetworkImage('${ServiceLocator.baseUrl}/storage/$avatarUrl')
                                    : null,
                                child: hasAvatar ? null : const Icon(Icons.person, size: 18),
                            ),
                        ),

                        // ☰ メニュー
                        PopupMenuButton<String>(
                            icon: const Icon(Icons.menu),
                            onSelected: (value) async {
                            if (!loading) {
                                if (value == 'log out') {
                                LogoutService.logout(
                                    context: context,
                                    onStartLoading: onStartLoading,
                                    onEndLoading: onEndLoading,
                                );
                                } else if (value == 'profile') {
                                await WebViewLauncher.openProfile(context);
                                }
                            }
                            },
                            itemBuilder: (context) => const [
                            PopupMenuItem(value: 'group1', child: Text('Group 1')),
                            PopupMenuItem(value: 'profile', child: Text('profile')),
                            PopupMenuItem(value: 'log out', child: Text('log out')),
                            ],
                        ),
                    ],
                ),
            ],


        );
    }

    @override
    Size get preferredSize => const Size.fromHeight(kToolbarHeight);

}