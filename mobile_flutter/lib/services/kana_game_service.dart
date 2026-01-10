import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../network/api_client.dart';

import '../locator/service_locator.dart';

import '../exceptions/auth_exception.dart';

import 'auth_service.dart';


class KanaGameService {

    final _api = ServiceLocator.apiClient;
    final _auth = ServiceLocator.authService;

    // スタートmodalに必要な情報を取得
    Future<Map<String, dynamic>> start_page(int setting_id) async {

        final token = await _auth.getToken();
        if (token == null || token.isEmpty) {
            throw AuthException('You are not logged in.');
        }

        try {

            final res = await _api.dio.get(
                '/api/kana/start_page/$setting_id',
                options: Options(headers: {
                    'Authorization': 'Bearer $token',
                }),
            );

            final data = res.data;

            if (data is Map) return Map<String, dynamic>.from(data);

            throw Exception('Unexpected response type: ${data.runtimeType}');

        } on DioException catch (e) {

            throw AuthException('Failed to retrieve start information.(${e.response?.statusCode})');

        }
    }
}