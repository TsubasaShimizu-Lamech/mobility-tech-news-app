import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/app_config.dart';
import '../../core/network/api_client.dart';

final dioProvider = Provider<Dio>((ref) => ApiClient.create());

// -------- Article model --------
class Article {
  const Article({
    required this.id,
    required this.title,
    required this.url,
    required this.source,
    required this.publishedAt,
    this.imageUrl,
    this.summary,
    this.tags = const [],
    required this.bookmarked,
  });

  final int id;
  final String title;
  final String url;
  final String source;
  final String publishedAt;
  final String? imageUrl;
  final String? summary;
  final List<String> tags;
  final bool bookmarked;

  Article copyWith({bool? bookmarked}) => Article(
        id: id,
        title: title,
        url: url,
        source: source,
        publishedAt: publishedAt,
        imageUrl: imageUrl,
        summary: summary,
        tags: tags,
        bookmarked: bookmarked ?? this.bookmarked,
      );

  factory Article.fromJson(Map<String, dynamic> json) => Article(
        id: json['id'] as int,
        title: json['title'] as String,
        url: json['url'] as String,
        source: json['source'] as String? ?? '',
        publishedAt: json['publishedAt'] as String? ?? '',
        imageUrl: json['imageUrl'] as String?,
        summary: json['summary'] as String?,
        tags: (json['tags'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        bookmarked: json['bookmarked'] as bool? ?? false,
      );
}

// -------- News state --------
class NewsState {
  const NewsState({
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

  NewsState copyWith({
    List<Article>? articles,
    int? page,
    bool? isLoading,
    bool? hasMore,
    String? error,
  }) =>
      NewsState(
        articles: articles ?? this.articles,
        page: page ?? this.page,
        isLoading: isLoading ?? this.isLoading,
        hasMore: hasMore ?? this.hasMore,
        error: error,
      );
}

// -------- News notifier --------
class NewsNotifier extends StateNotifier<NewsState> {
  NewsNotifier(this._dio) : super(const NewsState()) {
    fetchNext();
  }

  final Dio _dio;

  Future<void> fetchNext() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/api/articles',
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
    state = const NewsState();
    await fetchNext();
  }

  void toggleBookmark(int articleId) {
    final articles = state.articles.map((a) {
      if (a.id == articleId) return a.copyWith(bookmarked: !a.bookmarked);
      return a;
    }).toList();
    state = state.copyWith(articles: articles);
  }

  void updateBookmark(int articleId, {required bool bookmarked}) {
    final articles = state.articles.map((a) {
      if (a.id == articleId) return a.copyWith(bookmarked: bookmarked);
      return a;
    }).toList();
    state = state.copyWith(articles: articles);
  }
}

final newsNotifierProvider =
    StateNotifierProvider<NewsNotifier, NewsState>((ref) {
  return NewsNotifier(ref.watch(dioProvider));
});
