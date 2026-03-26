import 'package:flutter/material.dart';
import '../news_provider.dart';
import '../../bookmark/bookmark_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';

class ArticleCard extends ConsumerWidget {
  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  final Article article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor =
        isDark ? AppColors.darkAccent : AppColors.lightAccent;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Source + Bookmark
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      article.source.toUpperCase(),
                      style: textTheme.labelSmall?.copyWith(
                        color: accentColor,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _BookmarkButton(article: article),
                ],
              ),
              const SizedBox(height: 8),
              // Title
              Text(
                article.title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (article.summary != null && article.summary!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  article.summary!,
                  style: textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              // Tags + date
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: article.tags
                          .take(3)
                          .map((tag) => _TagPill(tag: tag))
                          .toList(),
                    ),
                  ),
                  Text(
                    _formatDate(article.publishedAt),
                    style: textTheme.bodySmall?.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.month}/${dt.day}';
    } catch (_) {
      return raw;
    }
  }
}

class _BookmarkButton extends ConsumerWidget {
  const _BookmarkButton({required this.article});
  final Article article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      icon: Icon(
        article.bookmarked ? Icons.bookmark : Icons.bookmark_border,
        color: article.bookmarked ? colorScheme.primary : null,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
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
          // ブックマーク画面も更新
          ref.invalidate(bookmarkNotifierProvider);
        } catch (_) {
          // ロールバック
          ref.read(newsNotifierProvider.notifier).toggleBookmark(article.id);
        }
      },
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.tag});
  final String tag;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tag,
        style: TextStyle(
          color: colorScheme.primary,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
