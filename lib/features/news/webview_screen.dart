import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'news_provider.dart';
import '../bookmark/bookmark_provider.dart';

class WebViewScreen extends ConsumerStatefulWidget {
  const WebViewScreen({super.key, required this.article});
  final Article article;

  @override
  ConsumerState<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends ConsumerState<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String _currentUrl = '';

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.article.url;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
              _currentUrl = url;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.article.url));
  }

  @override
  Widget build(BuildContext context) {
    // ニュース一覧から最新のブックマーク状態を取得
    final newsState = ref.watch(newsNotifierProvider);
    final latestArticle = newsState.articles.firstWhere(
      (a) => a.id == widget.article.id,
      orElse: () => widget.article,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _currentUrl,
          style: const TextStyle(fontSize: 12),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          _WebViewBookmarkButton(article: latestArticle),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const LinearProgressIndicator(),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        onBack: () async {
          if (await _controller.canGoBack()) {
            await _controller.goBack();
          }
        },
        onHome: () {
          _controller.loadRequest(Uri.parse(widget.article.url));
        },
        onShare: () {
          Clipboard.setData(ClipboardData(text: _currentUrl));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('URLをコピーしました')),
          );
        },
        onMenu: () {
          _showMenu(context);
        },
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('再読み込み'),
              onTap: () {
                Navigator.pop(context);
                _controller.reload();
              },
            ),
            ListTile(
              leading: const Icon(Icons.open_in_browser),
              title: const Text('ブラウザで開く'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _WebViewBookmarkButton extends ConsumerWidget {
  const _WebViewBookmarkButton({required this.article});
  final Article article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      icon: Icon(
        article.bookmarked ? Icons.bookmark : Icons.bookmark_border,
        color: article.bookmarked ? colorScheme.primary : null,
      ),
      onPressed: () async {
        // 楽観的UI更新
        ref.read(newsNotifierProvider.notifier).toggleBookmark(article.id);
        final dio = ref.read(dioProvider);
        try {
          if (article.bookmarked) {
            await dio.delete('/api/bookmarks/${article.id}');
          } else {
            await dio.post<void>('/api/bookmarks/${article.id}');
          }
          // ブックマーク一覧をリフレッシュ
          ref.invalidate(bookmarkNotifierProvider);
        } catch (_) {
          // ロールバック
          ref.read(newsNotifierProvider.notifier).toggleBookmark(article.id);
        }
      },
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.onBack,
    required this.onHome,
    required this.onShare,
    required this.onMenu,
  });

  final VoidCallback onBack;
  final VoidCallback onHome;
  final VoidCallback onShare;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: onBack,
            ),
            IconButton(
              icon: const Icon(Icons.home_outlined),
              onPressed: onHome,
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: onShare,
            ),
            IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: onMenu,
            ),
          ],
        ),
      ),
    );
  }
}
