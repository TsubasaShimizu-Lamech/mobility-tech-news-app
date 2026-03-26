# Mobility Tech News Mobile — CLAUDE.md

## プロジェクト概要

モビリティ業界の最新ニュースを閲覧するFlutterアプリ。
バックエンドは別リポジトリの Spring Boot API。

---

## 技術スタック

| 項目 | 内容 |
|------|------|
| フレームワーク | Flutter (Dart) |
| 状態管理 | flutter_riverpod ^2.5 |
| HTTPクライアント | dio ^5.4 |
| 認証 | supabase_flutter ^2.5 |
| WebView | webview_flutter ^4.7 |
| テーマ永続化 | shared_preferences ^2.2 |
| バージョン取得 | package_info_plus ^8.0 |

---

## 環境・接続先

### Supabase
- **URL**: `https://kdchjmssfmwvprsnyzlw.supabase.co`
- **Anon Key**: `sb_publishable_CekH0hGAftml9DcBTmejeQ_PvPxyK9n`
- `lib/core/config/app_config.dart` の `defaultValue` に設定済み

### Spring Boot API
- **ローカル開発時**: `http://192.168.11.12:8080`（Macのローカルネットワークアドレス）
- `lib/core/config/app_config.dart` の `apiBaseUrl` で管理
- 本番移行時は `--dart-define=API_BASE_URL=https://your-cloud-run-url` で上書き可能

---

## ディレクトリ構成

```
mobility-tech-news-mobile/          ← プロジェクトルート（flutter プロジェクト直下）
├── CLAUDE.md
├── pubspec.yaml                     # name: mobility_tech_news_mobile
├── lib/
│   ├── main.dart                    # Supabase初期化 → ProviderScope → _AuthGate
│   ├── core/
│   │   ├── config/app_config.dart   # 環境変数・定数（--dart-define で上書き可）
│   │   ├── network/api_client.dart  # Dio + JWT自動付与インターセプター
│   │   └── theme/app_theme.dart    # ダーク/ライトテーマ定義
│   ├── features/
│   │   ├── auth/
│   │   │   ├── auth_provider.dart   # Supabase Auth 状態管理
│   │   │   └── login_screen.dart    # メール/PW ログイン・新規登録
│   │   ├── news/
│   │   │   ├── news_provider.dart   # Article モデル・無限スクロール StateNotifier
│   │   │   ├── news_screen.dart     # タイムライン画面
│   │   │   ├── webview_screen.dart  # WebView画面（上部・下部バー）
│   │   │   └── widgets/
│   │   │       └── article_card.dart # 記事カード（楽観的ブックマーク更新）
│   │   ├── bookmark/
│   │   │   ├── bookmark_provider.dart # GET/POST/DELETE + ロールバック
│   │   │   └── bookmark_screen.dart   # 保存済み一覧・空状態UI
│   │   └── settings/
│   │       └── settings_screen.dart   # テーマ切替・バージョン・ログアウト
│   └── shared/
│       └── widgets/
│           └── bottom_nav.dart       # IndexedStack + 3タブ BottomNavigationBar
└── android/
    └── app/
        ├── build.gradle             # applicationId: com.example.mobility_tech_news_mobile
        └── src/main/
            ├── AndroidManifest.xml  # INTERNET権限・usesCleartextTraffic=true
            └── kotlin/.../MainActivity.kt
```

---

## ビルド・実行方法

### 前提
- fvm 3.16.5 の `flutter_tools.snapshot` はOOM（メモリ不足）でクラッシュするため使用不可
- 代わりに `fvm/cache.git/bin/flutter` を使用する（dartdev.snapshot が存在するため動作する）

### 実機（Pixel 9a）へのビルド

```bash
cd /Users/shimizutsubasa/dev/project/mobility-tech-news-mobile

/Users/shimizutsubasa/fvm/cache.git/bin/flutter run \
  --device-id 58291JEBF17048 \
  --dart-define=API_BASE_URL=http://192.168.11.12:8080
```

- `SUPABASE_URL` / `SUPABASE_ANON_KEY` は `app_config.dart` の `defaultValue` に設定済みのため省略可
- `dart-define` を省略すると `app_config.dart` の `defaultValue` が使われる

### APK手動インストール（flutter run が途中失敗した場合）

```bash
# Play Protect によるブロックを回避
~/Library/Android/sdk/platform-tools/adb shell settings put global verifier_verify_adb_installs 0

~/Library/Android/sdk/platform-tools/adb install -r \
  build/app/outputs/flutter-apk/app-debug.apk
```

### コード静的解析

```bash
FLUTTER_ROOT=/Users/shimizutsubasa/fvm/versions/3.16.5 \
  /opt/homebrew/bin/dart analyze lib/
```

---

## API仕様（Spring Boot）

| エンドポイント | メソッド | 説明 |
|--------------|--------|------|
| `/api/articles?page=0&size=20` | GET | 記事一覧（ページネーション） |
| `/api/bookmarks?page=0&size=20` | GET | ブックマーク一覧 |
| `/api/bookmarks/{id}` | POST | ブックマーク追加 |
| `/api/bookmarks/{id}` | DELETE | ブックマーク削除 |

- 全リクエストに `Authorization: Bearer {JWT}` が必要
- レスポンス形式: Spring Data の Page オブジェクト（`content`, `last` フィールドを参照）

---

## デザイン仕様

| 項目 | ダーク | ライト |
|------|-------|-------|
| 背景 | `#0F1117` | `#F5F5F7` |
| カード背景 | `#1A1D27` | `#FFFFFF` |
| アクセント | `#4A7FD4` | `#2563EB` |
| テキスト primary | `#F0F0F0` | `#1A1A1A` |
| テキスト secondary | `#888888` | `#666666` |
| カード border-radius | 14px | 14px |
| タグピル border-radius | 20px | 20px |

---

## 既知の注意事項

- **fvm 3.16.5 の dartdev.snapshot が欠損**しているため `flutter run` が使えない。必ず `fvm/cache.git/bin/flutter` を使うこと
- **pubspec.yaml の `name` フィールド**はDart識別子の制約上ハイフン不可。`mobility_tech_news_mobile`（アンダースコア）を使用
- **Android パッケージ名**も同様に `com.example.mobility_tech_news_mobile`
- Pixel 9a (Android 16) への ADB インストール時は **Play Protect の検証を無効化**する必要がある
- **APIサーバーのIPアドレス**は `192.168.11.12`。Spring Boot 起動時は `0.0.0.0` でリッスンさせること
