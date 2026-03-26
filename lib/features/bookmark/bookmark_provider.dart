import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/app_config.dart';
import '../news/news_provider.dart';

// -------- Bookmark state --------
class BookmarkState {
  const BookmarkState({
    this.articles = const [],
    this.page = 0,
    this.isLoading = false,
    this.hasMore = true,
    this.error,
  });

  final List<Article> articles;
  final int page;
  final bool isLoading;
  final bool hasMore;
  final String? error;

  BookmarkState copyWith({
    List<Article>? articles,
    int? page,
    bool? isLoading,
    bool? hasMore,
    String? error,
  }) =>
      BookmarkState(
        articles: articles ?? this.articles,
        page: page ?? this.page,
        isLoading: isLoading ?? this.isLoading,
        hasMore: hasMore ?? this.hasMore,
        error: error,
      );
}

class BookmarkNotifier extends StateNotifier<BookmarkState> {
  BookmarkNotifier(this._dio, this._ref) : super(const BookmarkState()) {
    fetchNext();
  }

  final Dio _dio;
  final Ref _ref;

  Future<void> fetchNext() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/api/bookmarks',
        queryParameters: {
          'page': state.page,
          'size': AppConfig.pageSize,
        },
      );
      final data = res.data!;
      final content = (data['content'] as List<dynamic>)
          .map((e) => Article.fromJson(e as Map<String, dynamic>))
          .toList();
      final last = data['last'] as bool? ?? true;

      state = state.copyWith(
        articles: [...state.articles, ...content],
        page: state.page + 1,
        isLoading: false,
        hasMore: !last,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    }
  }

  Future<void> refresh() async {
    state = const BookmarkState();
    await fetchNext();
  }

  Future<void> toggleBookmark(Article article) async {
    final wasBookmarked = article.bookmarked;

    // 楽観的UI更新
    _applyToggle(article.id, !wasBookmarked);

    try {
      if (wasBookmarked) {
        await _dio.delete('/api/bookmarks/${article.id}');
        // 保存済み一覧からも除去
        state = state.copyWith(
          articles: state.articles.where((a) => a.id != article.id).toList(),
        );
      } else {
        await _dio.post<void>('/api/bookmarks/${article.id}');
      }
      // ニュース一覧の状態も同期
      _ref
          .read(newsNotifierProvider.notifier)
          .updateBookmark(article.id, bookmarked: !wasBookmarked);
    } on DioException {
      // 失敗時はロールバック
      _applyToggle(article.id, wasBookmarked);
    }
  }

  void _applyToggle(int id, bool bookmarked) {
    final articles = state.articles.map((a) {
      if (a.id == id) return a.copyWith(bookmarked: bookmarked);
      return a;
    }).toList();
    state = state.copyWith(articles: articles);
  }
}

final bookmarkNotifierProvider =
    StateNotifierProvider<BookmarkNotifier, BookmarkState>((ref) {
  return BookmarkNotifier(ref.watch(dioProvider), ref);
});
