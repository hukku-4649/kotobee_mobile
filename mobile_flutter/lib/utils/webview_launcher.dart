import 'package:flutter/material.dart';
import '../models/mobile_enter_type.dart';
import '../screens/webview/profile.dart';
import 'webview_routes.dart';

class WebViewLauncher {
    static Future<void> openProfile(BuildContext context) async {

        final url = await WebViewRoutes.mobileEnter(type: MobileEnterType.profile);

        if (!context.mounted) return;


        await Navigator.of(context).push(
            MaterialPageRoute(
                builder: (_) => ProfilePage(
                    initialUrl: url,
                ),
            ),
        );

    }
}