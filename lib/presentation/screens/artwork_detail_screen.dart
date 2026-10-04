import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/artwork_provider.dart';
import '../widgets/fullscreen_image_viewer.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'artwork_form_screen.dart';
import '../../domain/entities/artwork.dart';
import '../../core/utils/error_handler.dart';

class ArtworkDetailScreen extends ConsumerStatefulWidget {
  final String artworkId;
  final Artwork? artwork; // Optional: pass artwork directly from list

  const ArtworkDetailScreen({
    super.key,
    required this.artworkId,
    this.artwork,
  });

  @override
  ConsumerState<ArtworkDetailScreen> createState() => _ArtworkDetailScreenState();
}

class _ArtworkDetailScreenState extends ConsumerState<ArtworkDetailScreen> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteState();
  }

  Future<void> _loadFavoriteState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFavorite = prefs.getBool('favorite_${widget.artworkId}') ?? false;
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFavorite = !_isFavorite;
    });
    await prefs.setBool('favorite_${widget.artworkId}', _isFavorite);
  }

  Future<void> _shareArtwork(Artwork artwork) async {
    final text = '${artwork.title}${artwork.artist != null ? ' - ${artwork.artist}' : ''}\n${artwork.imageUrl ?? ''}';
    await Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    // Use passed artwork if available, otherwise fetch from provider
    final artworkAsync = widget.artwork != null
        ? AsyncValue.data(widget.artwork)
        : ref.watch(artworkProvider(widget.artworkId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chi tiết Tác phẩm',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          artworkAsync.when(
            data: (artwork) {
              if (artwork == null) return const SizedBox.shrink();
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Favorite button
                  IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.bookmark : Icons.bookmark_border,
                      color: AppColors.onPrimary,
                    ),
                    onPressed: _toggleFavorite,
                    tooltip: _isFavorite ? 'Bỏ yêu thích' : 'Yêu thích',
                  ),
                  // Share button
                  IconButton(
                    icon: const Icon(Icons.share, color: AppColors.onPrimary),
                    onPressed: () => _shareArtwork(artwork),
                    tooltip: 'Chia sẻ',
                  ),
                  // Menu button
                  PopupMenuButton(
                    iconColor: AppColors.onPrimary,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Sửa'),
                      ],
                    ),
                        onTap: () async {
                          // Wait for form screen to return
                          final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ArtworkFormScreen(artwork: artwork),
                        ),
                      );
                          
                          // After edit, refresh and go back to list
                          if (context.mounted && result == true) {
                            // Refresh the artwork data
                            ref.invalidate(artworkProvider(widget.artworkId));
                            ref.invalidate(artworkNotifierProvider);
                            
                            // Pop back to list screen
                            Navigator.of(context).pop();
                          }
                    },
                  ),
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Xóa', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                    onTap: () {
                      _showDeleteDialog(context, ref, artwork);
                    },
                      ),
                    ],
                  ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: artworkAsync.when(
        data: (artwork) {
          if (artwork == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Không tìm thấy tác phẩm',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWideScreen = constraints.maxWidth > 800;
              
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image Section - Card với khung cố định
                    Container(
                      margin: EdgeInsets.fromLTRB(
                        isWideScreen ? AppSpacing.xl : AppSpacing.md,
                        AppSpacing.lg,
                        isWideScreen ? AppSpacing.xl : AppSpacing.md,
                        AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16), // Bo góc 16px
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            Hero(
                              tag: 'artwork_image_${artwork.id}',
                              child: AspectRatio(
                                aspectRatio: artwork.imageUrl != null && artwork.imageUrl!.isNotEmpty 
                                    ? 16 / 9  // Tỷ lệ cố định 16:9
                                    : 3 / 2,  // Tỷ lệ 3:2 cho placeholder
                                child: artwork.imageUrl != null && artwork.imageUrl!.isNotEmpty
                                    ? GestureDetector(
                                        onTap: () {
                                          FullscreenImageViewer.show(
                                            context,
                                            artwork.imageUrl!,
                                            heroTag: 'artwork_image_${artwork.id}',
                                          );
                                        },
                                        child: CachedNetworkImage(
                                          imageUrl: artwork.imageUrl!,
                                          width: double.infinity,
                                          fit: BoxFit.cover, // Giữ tỷ lệ, không bị méo
                                          fadeInDuration: const Duration(milliseconds: 300),
                                          fadeOutDuration: const Duration(milliseconds: 100),
                                          memCacheWidth: isWideScreen ? 1600 : 1000, // Tăng độ nét
                                          placeholder: (context, url) => Container(
                                            color: AppColors.surfaceVariant,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                color: AppColors.primary,
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) => Container(
                                            color: AppColors.surfaceVariant,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.image_not_supported,
                                                  size: 48,
                                                  color: AppColors.textSecondary,
                                                ),
                                                const SizedBox(height: AppSpacing.sm),
                                                Text(
                                                  'Không thể tải hình ảnh',
                                                  style: AppTypography.bodySmall.copyWith(
                                                    color: AppColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        color: AppColors.surfaceVariant,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.palette_outlined,
                                              size: 48,
                                              color: AppColors.textSecondary,
                                            ),
                                            const SizedBox(height: AppSpacing.sm),
                                            Text(
                                              'Không có hình ảnh',
                                              style: AppTypography.bodySmall.copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                            ),
                            // Fullscreen button
                            if (artwork.imageUrl != null && artwork.imageUrl!.isNotEmpty)
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Material(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(12),
                                  child: InkWell(
                                    onTap: () {
                                      FullscreenImageViewer.show(
                                        context,
                                        artwork.imageUrl!,
                                        heroTag: 'artwork_image_${artwork.id}',
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      child: const Icon(
                                        Icons.fullscreen,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    // Content Card - Card nổi với bóng đổ tinh tế
                    Container(
                      margin: EdgeInsets.fromLTRB(
                        isWideScreen ? AppSpacing.xl : AppSpacing.md,
                        0, // Không có margin top để gần với image
                        isWideScreen ? AppSpacing.xl : AppSpacing.md,
                        AppSpacing.lg,
                      ),
                      padding: EdgeInsets.all(
                        isWideScreen ? AppSpacing.xl : AppSpacing.lg,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16), // Bo góc 16px
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title Section - Typography lớn
                          Text(
                            artwork.title,
                            style: AppTypography.headlineMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              height: 1.2,
                              fontSize: isWideScreen ? 28 : 22,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: AppSpacing.md), // Khoảng cách hợp lý
                      
                          // Artist Section - Phụ đề nhỏ hơn
                          if (artwork.artist != null && artwork.artist!.isNotEmpty) ...[
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12), // Bo góc 12px
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    size: 18,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      artwork.artist!,
                                      style: AppTypography.bodyLarge.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w500,
                                        fontSize: isWideScreen ? 16 : 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: AppSpacing.md),
                          ],
                      
                          // Category and Year Tags - Icon đồng bộ, bo góc 12px
                          if ((artwork.category != null && artwork.category!.isNotEmpty) ||
                              artwork.year != null) ...[
                            Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.sm,
                              children: [
                                if (artwork.category != null && artwork.category!.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryContainer.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(12), // Bo góc 12px
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.category_outlined,
                                          size: 16,
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          artwork.category!,
                                          style: AppTypography.labelMedium.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (artwork.year != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceVariant.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(12), // Bo góc 12px
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.calendar_today_outlined,
                                          size: 16,
                                          color: AppColors.textSecondary,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${artwork.year}',
                                          style: AppTypography.labelMedium.copyWith(
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: AppSpacing.lg),
                          ],
                          
                          // Description Section - Khoảng cách hợp lý
                          if (artwork.description != null && artwork.description!.isNotEmpty) ...[
                            SizedBox(height: AppSpacing.md), // Khoảng cách trước divider
                            Container(
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.divider.withValues(alpha: 0),
                                    AppColors.divider.withValues(alpha: 0.3),
                                    AppColors.divider.withValues(alpha: 0),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Container(
                                  width: 3,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  'Mô tả',
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                    fontSize: isWideScreen ? 18 : 16,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppSpacing.sm),
                            Container(
                              padding: EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12), // Bo góc 12px
                              ),
                              child: Text(
                                artwork.description!,
                                style: AppTypography.bodyMedium.copyWith(
                                  height: 1.6,
                                  color: AppColors.textPrimary,
                                  fontSize: isWideScreen ? 16 : 15,
                                ),
                              ),
                            ),
                            SizedBox(height: AppSpacing.lg),
                          ],
                          
                          // Location Section - Icon đồng bộ
                          if (artwork.location != null && artwork.location!.isNotEmpty) ...[
                            SizedBox(height: AppSpacing.md),
                            Container(
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.divider.withValues(alpha: 0),
                                    AppColors.divider.withValues(alpha: 0.3),
                                    AppColors.divider.withValues(alpha: 0),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: AppSpacing.md),
                            Container(
                              padding: EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12), // Bo góc 12px
                                border: Border.all(
                                  color: AppColors.border.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 18,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      artwork.location!,
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w500,
                                        fontSize: isWideScreen ? 16 : 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: AppSpacing.lg),
                          ],
                          
                          // Footer - Created date - Màu xám nhẹ, mảnh
                          Container(
                            padding: const EdgeInsets.only(top: AppSpacing.md),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: AppColors.divider.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time_outlined,
                                  size: 14,
                                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  'Tạo: ${_formatDate(artwork.createdAt)}',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Đang tải...',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        error: (error, stack) {
          ErrorHandler.logError(error, stack);
          final errorMessage = ErrorHandler.getErrorMessage(error);
          final isNetworkError = ErrorHandler.isNetworkError(error);
          
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: isNetworkError 
                          ? AppColors.warningContainer 
                          : AppColors.errorContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                    isNetworkError ? Icons.wifi_off : Icons.error_outline,
                    size: 64,
                      color: isNetworkError ? AppColors.warning : AppColors.error,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    isNetworkError ? 'Lỗi kết nối mạng' : 'Đã xảy ra lỗi',
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    errorMessage,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (context.mounted) {
                        ref.invalidate(artworkProvider(widget.artworkId));
                      }
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Artwork artwork) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppColors.error,
              size: 28,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Xóa Tác phẩm',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Bạn có chắc muốn xóa "${artwork.title}"? Hành động này không thể hoàn tác.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Hủy',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              try {
                await ref.read(artworkNotifierProvider.notifier).deleteArtwork(artwork.id);
                
                if (!context.mounted) return;
                
                // Invalidate providers to refresh data
                ref.invalidate(artworkProvider(widget.artworkId));
                ref.invalidate(artworkNotifierProvider);
                
                // Pop back to list screen
                Navigator.of(context).pop();
                
                // Show success message on list screen
                if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: AppSpacing.sm),
                          const Text('Đã xóa tác phẩm thành công'),
                        ],
                      ),
                      backgroundColor: AppColors.success,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                      ),
                  ),
                );
                }
              } catch (e) {
                if (context.mounted) {
                  ErrorHandler.logError(e);
                  final errorMessage = ErrorHandler.getErrorMessage(e);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.white),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(child: Text(errorMessage)),
                        ],
                      ),
                      backgroundColor: AppColors.error,
                      duration: const Duration(seconds: 4),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                      ),
                      action: SnackBarAction(
                        label: 'Đóng',
                        textColor: Colors.white,
                        onPressed: () {},
                      ),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

