class AppConfig {
    static const apiBaseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://127.0.0.1:8000',
        // defaultValue: 'https://127.0.0.1:443',
        // defaultValue: 'https://192.0.0.3:8000',
        // defaultValue: 'https://willyard-lashaunda-conformable.ngrok-free.dev',
        // defaultValue: 'https://172.20.10.3',
        // defaultValue: 'https://10.20.61.136', 
    );
}