class AppConfig {
    static const apiBaseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://127.0.0.1:8000',
        // defaultValue: 'http://127.0.0.1:8888',
        // defaultValue: 'https://127.0.0.1:443',
        // defaultValue: 'https://192.0.0.3:8000',
        // defaultValue: 'https://172.20.10.3',
    );
}
