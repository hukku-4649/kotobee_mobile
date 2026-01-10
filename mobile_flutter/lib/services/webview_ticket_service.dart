import 'package:dio/dio.dart';

import '../locator/service_locator.dart';
import '../exceptions/auth_exception.dart';

class WebViewTicketService {
    final _api = ServiceLocator.apiClient;
    final _auth = ServiceLocator.authService;

    Future<String> issueWebViewTicket() async {
        final token = await _auth.getToken();
        if (token == null || token.isEmpty) {
            throw AuthException('You are not logged in.');
        }

        try {

            final res = await _api.dio.post(
                '/api/webview/ticket',
                options: Options(headers: {
                    'Authorization': 'Bearer $token',
                    'Accept': 'application/json',
                }),
            );

            return res.data['ticket'] as String;

        } on DioException catch (e) {
            throw AuthException(
                'Failed to issue webview ticket. (${e.response?.statusCode})',
            );
        }
        
    }
}