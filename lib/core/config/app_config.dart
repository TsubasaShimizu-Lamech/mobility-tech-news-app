// 環境変数は --dart-define で注入する
// 本番: defaultValue の API Gateway URL が使われる
// ローカル開発時の上書き例:
//   flutter run --dart-define=API_BASE_URL=http://192.168.11.12:8080

class AppConfig {
  AppConfig._();

  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://kdchjmssfmwvprsnyzlw.supabase.co',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_CekH0hGAftml9DcBTmejeQ_PvPxyK9n',
  );

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://mobility-tech-news-gateway-5rrv7j8s.an.gateway.dev',
  );

  static const int pageSize = 20;
}
