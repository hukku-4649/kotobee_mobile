import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../network/api_client.dart';

import '../locator/service_locator.dart';

import '../exceptions/auth_exception.dart';

import 'auth_service.dart';

class GrammarGameService {


    final _api = ServiceLocator.apiClient;
    final _auth = ServiceLocator.authService;

    Future<Map<String, dynamic>> stages() async {  

        final token = await _auth.getToken();
        if (token == null || token.isEmpty) {
            throw AuthException('You are not logged in.');
        }

        try {
            final res = await _api.dio.get(
                '/api/grammar/stages',
                options: Options(headers: {
                    'Authorization': 'Bearer $token',
                }),
            );

            final data = res.data;

            // print(data);
            // print(res.data['played_stage_ids']);
            // print(res.data['stage_urls']);

            if (data is Map) {
                return Map<String, dynamic>.from(data);
            }            

            // たまに String で来る環境もあるので保険（必要なら）
            throw Exception('Unexpected response type: ${data.runtimeType}');

        } on DioException catch (e) {            

            final status = e.response?.statusCode;
            final body = e.response?.data;                        

            throw AuthException('Failed to retrieve stages.(${e.response?.statusCode})');
        }


    }

    // スタートmodalに必要な情報を取得
    Future<Map<String, dynamic>> start_page(int stageId) async {

        final token = await _auth.getToken();
        if (token == null || token.isEmpty) {
            throw AuthException('You are not logged in.');
        }

        try {            
            final res = await _api.dio.get(
                '/api/grammar/start_page/$stageId',
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
    

    // チケット発効
    // Future<String> issueWebViewTicket() async {
    //     final token = await _auth.getToken();
    //     if (token == null || token.isEmpty) {
    //         throw AuthException('You are not logged in.');
    //     }

    //     final res = await _api.dio.post(
    //         '/api/webview/ticket',
    //         options: Options(headers: {
    //             'Authorization': 'Bearer $token',
    //             'Accept': 'application/json',
    //         }),
    //     );
        
    //     return res.data['ticket'] as String;
    // }


    
}