import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'bookmark_provider.dart';
import '../news/widgets/article_card.dart';
import '../news/webview_screen.dart';
import '../../core/theme/app_theme.dart';

class BookmarkScreen extends ConsumerStatefulWidget {
  const BookmarkScreen({super.key});

  @override
  ConsumerState<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends ConsumerState<BookmarkScreen> {
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
      ref.read(bookmarkNotifierProvider.notifier).fetchNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookmarkNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '保存済み',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(bookmarkNotifierProvider.notifier).refresh(),
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(BookmarkState state) {
    if (state.articles.isEmpty && state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.articles.isEmpty) {
      return _EmptyState();
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
          article: article.copyWith(bookmarked: true),
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

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 72,
            color: colorScheme.secondary,
          ),
          const SizedBox(height: 20),
          Text(
            '保存した記事はここに表示されます',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '記事のブックマークアイコンをタップして\n後で読む記事を保存できます',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () {},
            icon: Icon(Icons.explore_outlined, color: accentColor),
            label: Text(
              'ニュースを見る',
              style: TextStyle(color: accentColor),
            ),
          ),
        ],
      ),
    );
  }
}
