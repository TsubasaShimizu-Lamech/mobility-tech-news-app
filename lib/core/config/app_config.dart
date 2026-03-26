// 環境変数は --dart-define で注入する
// 例: flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co \
//                 --dart-define=SUPABASE_ANON_KEY=eyJ... \
//                 --dart-define=API_BASE_URL=http://localhost:8080

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
    defaultValue: 'http://192.168.11.12:8080',
  );

  static const int pageSize = 20;
}
