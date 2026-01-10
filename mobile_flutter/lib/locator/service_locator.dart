import '../network/api_client.dart';
import '../services/auth_service.dart';
import '../services/grammar_game_service.dart';
import '../services/vocabulary_game_service.dart';
import '../services/kana_game_service.dart';
import '../services/webview_ticket_service.dart';

class ServiceLocator {
    static late final String baseUrl;
    static late ApiClient apiClient;
    static late AuthService authService;
    static late GrammarGameService grammarGameService;
    static late VocabularyGameService vocabularyGameService;
    static late KanaGameService kanaGameService;
    static late WebViewTicketService webViewTicketService; 


    static void init({
        required String baseUrl,
    }) {
        ServiceLocator.baseUrl = baseUrl;
        apiClient              = ApiClient(baseUrl: baseUrl);
        authService            = AuthService(apiClient: apiClient);
        webViewTicketService   = WebViewTicketService();
        grammarGameService     = GrammarGameService();
        vocabularyGameService  = VocabularyGameService();
        kanaGameService        = KanaGameService();
    }
}