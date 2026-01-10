import '../locator/service_locator.dart';
import '../models/mobile_enter_type.dart';

class WebViewRoutes {
    static Future<String> mobileEnter({
        required MobileEnterType type,
        int? stageId,
    }) async {
        // チケット発行
        final ticket = await ServiceLocator.webViewTicketService.issueWebViewTicket();
        // URL取得
        final base = ServiceLocator.baseUrl;
        // どの場所に飛ぶか    
        final typeParam = mobileEnterTypeParam(type);

        final params = <String, String>{
            'ticket': ticket,
            'type': typeParam,
            if (stageId != null) 'stage_id': stageId.toString(),
        };

        final uri = Uri.parse('$base/mobile/enter').replace(queryParameters: params);

        return uri.toString();

    }
}