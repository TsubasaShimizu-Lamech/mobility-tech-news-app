import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(NewsState state) {
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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WebViewScreen(article: article),
              ),
            );
          },
        );
      },
    );
  }
}
