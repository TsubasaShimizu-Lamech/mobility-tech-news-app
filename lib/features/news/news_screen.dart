import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'news_provider.dart';
import 'widgets/article_card.dart';
import 'webview_screen.dart';

class NewsScreen extends ConsumerStatefulWidget {
  const NewsScreen({super.key});

  @override
  ConsumerState<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends ConsumerState<NewsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      ref.read(newsNotifierProvider.notifier).fetchNext();
    }
  }

  void _openArticle(BuildContext context, Article article) {
    if (kIsWeb) {
      launchUrl(Uri.parse(article.url), mode: LaunchMode.externalApplication);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => WebViewScreen(article: article)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MOBILITY TECH NEWS',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 16,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(newsNotifierProvider.notifier).refresh(),
        child: LayoutBuilder(
          builder: (context, constraints) =>
              _buildBody(context, state, constraints.maxWidth),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, NewsState state, double width) {
    if (state.articles.isEmpty && state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.articles.isEmpty && state.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text(state.error!),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () =>
                  ref.read(newsNotifierProvider.notifier).fetchNext(),
              child: const Text('再試行'),
            ),
          ],
        ),
      );
    }

    final crossAxisCount = width >= 900 ? 3 : (width >= 600 ? 2 : 1);

    if (crossAxisCount == 1) {
      return ListView.builder(
        controller: _scrollController,
        itemCount: state.articles.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.articles.length) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final article = state.articles[index];
          return ArticleCard(
            article: article,
            onTap: () => _openArticle(context, article),
            showImagePlaceholder: false,
          );
        },
      );
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: 340,
        crossAxisSpacing: 0,
        mainAxisSpacing: 0,
      ),
      itemCount: state.articles.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.articles.length) {
          return const Center(child: CircularProgressIndicator());
        }
        final article = state.articles[index];
        return ArticleCard(
          article: article,
          onTap: () => _openArticle(context, article),
        );
      },
    );
  }
}
