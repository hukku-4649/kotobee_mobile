import 'package:flutter/material.dart';
import '../locator/service_locator.dart';
import '../screens/login_page.dart';

class LogoutService {
    static Future<void> logout({
        
        required BuildContext context,
        required VoidCallback onStartLoading,
        required VoidCallback onEndLoading,

    }) async {

        onStartLoading();
        
        try {
            await ServiceLocator.authService.logoutApi();

            if (!context.mounted) return;

            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => LoginPage()),
                (route) => false,
            );

        } finally {
            onEndLoading();
        }

    }
}