import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/artwork_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/fullscreen_image_viewer.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import 'artwork_detail_screen.dart';
import 'artwork_form_screen.dart';
import 'login_screen.dart';
import '../../domain/entities/artwork.dart';
import '../../core/utils/error_handler.dart';

class ArtworkListScreen extends ConsumerStatefulWidget {
  const ArtworkListScreen({super.key});

  @override
  ConsumerState<ArtworkListScreen> createState() => _ArtworkListScreenState();
}

enum SortOption { title, date, artist }
enum SortOrder { ascending, descending }

class _ArtworkListScreenState extends ConsumerState<ArtworkListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  // Filter state
  String? _selectedCategory;
  String? _selectedArtist;
  int? _selectedYear;
  bool _showOnlyWithCategory = false; // Chỉ hiện danh mục có nội dung
  bool _showOnlyFavorites = false; // Chỉ hiện yêu thích
  
  // Sort state
  SortOption _sortOption = SortOption.date;
  SortOrder _sortOrder = SortOrder.descending;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  // Check if there are active filters
  bool _hasActiveFilters() {
    return _selectedCategory != null ||
        _selectedArtist != null ||
        _selectedYear != null ||
        _showOnlyWithCategory ||
        _showOnlyFavorites ||
        _searchQuery.isNotEmpty;
  }
  
  // Get count of active filters
  int _getActiveFilterCount() {
    int count = 0;
    if (_selectedCategory != null) count++;
    if (_selectedArtist != null) count++;
    if (_selectedYear != null) count++;
    if (_showOnlyWithCategory) count++;
    if (_showOnlyFavorites) count++;
    if (_searchQuery.isNotEmpty) count++;
    return count;
  }
  
  void _showFilterSortBottomSheet(BuildContext context, List<Artwork> artworks) {
    // Get unique values for filters
    final categories = artworks
        .where((a) => a.category != null && a.category!.isNotEmpty)
        .map((a) => a.category!)
        .toSet()
        .toList()
      ..sort();
    
    final artists = artworks
        .where((a) => a.artist != null && a.artist!.isNotEmpty)
        .map((a) => a.artist!)
        .toSet()
        .toList()
      ..sort();
    
    final years = artworks
        .where((a) => a.year != null)
        .map((a) => a.year!)
        .toSet()
        .toList()
      ..sort();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLarge)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) => Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Lọc & Sắp xếp',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedCategory = null;
                            _selectedArtist = null;
                            _selectedYear = null;
                            _showOnlyWithCategory = false;
                            _showOnlyFavorites = false;
                            _sortOption = SortOption.date;
                            _sortOrder = SortOrder.descending;
                          });
                          setModalState(() {});
                        },
                        child: const Text('Đặt lại'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sort Section
                        Text(
                          'Sắp xếp theo',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          children: SortOption.values.map((option) {
                            final labels = {
                              SortOption.title: 'Tiêu đề',
                              SortOption.date: 'Ngày tạo',
                              SortOption.artist: 'Nghệ sĩ',
                            };
                            return FilterChip(
                              label: Text(labels[option]!),
                              selected: _sortOption == option,
                              onSelected: (selected) {
                                setState(() => _sortOption = option);
                                setModalState(() {});
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        // Sort Order
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  setState(() => _sortOrder = SortOrder.ascending);
                                  setModalState(() {});
                                },
                                icon: Icon(
                                  Icons.arrow_upward,
                                  size: 18,
                                  color: _sortOrder == SortOrder.ascending
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                                label: const Text('Tăng dần'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _sortOrder == SortOrder.ascending
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  side: BorderSide(
                                    color: _sortOrder == SortOrder.ascending
                                        ? AppColors.primary
                                        : AppColors.outline,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  setState(() => _sortOrder = SortOrder.descending);
                                  setModalState(() {});
                                },
                                icon: Icon(
                                  Icons.arrow_downward,
                                  size: 18,
                                  color: _sortOrder == SortOrder.descending
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                                label: const Text('Giảm dần'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _sortOrder == SortOrder.descending
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  side: BorderSide(
                                    color: _sortOrder == SortOrder.descending
                                        ? AppColors.primary
                                        : AppColors.outline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        // Filter Section
                        Text(
                          'Lọc theo',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        // Category Filter
                        if (categories.isNotEmpty) ...[
                          Text(
                            'Danh mục',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Wrap(
                            spacing: AppSpacing.sm,
                            children: [
                              FilterChip(
                                label: const Text('Tất cả'),
                                selected: _selectedCategory == null,
                                onSelected: (selected) {
                                  setState(() => _selectedCategory = null);
                                  setModalState(() {});
                                },
                              ),
                              ...categories.map((category) => FilterChip(
                                label: Text(category),
                                selected: _selectedCategory == category,
                                onSelected: (selected) {
                                  setState(() => _selectedCategory = selected ? category : null);
                                  setModalState(() {});
                                },
                              )),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        // Artist Filter
                        if (artists.isNotEmpty) ...[
                          Text(
                            'Nghệ sĩ',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Wrap(
                            spacing: AppSpacing.sm,
                            children: [
                              FilterChip(
                                label: const Text('Tất cả'),
                                selected: _selectedArtist == null,
                                onSelected: (selected) {
                                  setState(() => _selectedArtist = null);
                                  setModalState(() {});
                                },
                              ),
                              ...artists.map((artist) => FilterChip(
                                label: Text(artist),
                                selected: _selectedArtist == artist,
                                onSelected: (selected) {
                                  setState(() => _selectedArtist = selected ? artist : null);
                                  setModalState(() {});
                                },
                              )),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        // Year Filter
                        if (years.isNotEmpty) ...[
                          Text(
                            'Năm',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Wrap(
                            spacing: AppSpacing.sm,
                            children: [
                              FilterChip(
                                label: const Text('Tất cả'),
                                selected: _selectedYear == null,
                                onSelected: (selected) {
                                  setState(() => _selectedYear = null);
                                  setModalState(() {});
                                },
                              ),
                              ...years.map((year) => FilterChip(
                                label: Text(year.toString()),
                                selected: _selectedYear == year,
                                onSelected: (selected) {
                                  setState(() => _selectedYear = selected ? year : null);
                                  setModalState(() {});
                                },
                              )),
                            ],
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        // Quick Filters Section
                        Text(
                          'Lọc nhanh',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        // Show only with category
                        SwitchListTile(
                          title: const Text('Chỉ hiện danh mục có nội dung'),
                          subtitle: const Text('Chỉ hiển thị tác phẩm có danh mục'),
                          value: _showOnlyWithCategory,
                          onChanged: (value) {
                            setState(() => _showOnlyWithCategory = value);
                            setModalState(() {});
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                        // Show only favorites
                        SwitchListTile(
                          title: const Text('Chỉ hiện yêu thích'),
                          subtitle: const Text('Chỉ hiển thị tác phẩm đã đánh dấu yêu thích'),
                          value: _showOnlyFavorites,
                          onChanged: (value) {
                            setState(() => _showOnlyFavorites = value);
                            setModalState(() {});
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ),
                // Apply Button
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Áp dụng'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Future<List<Artwork>> _applyFiltersAndSort(List<Artwork> artworks) async {
    // Apply filters
    var filtered = artworks.where((artwork) {
      // Category filter
      if (_selectedCategory != null && artwork.category != _selectedCategory) {
        return false;
      }
      // Show only with category
      if (_showOnlyWithCategory && (artwork.category == null || artwork.category!.isEmpty)) {
        return false;
      }
      // Artist filter
      if (_selectedArtist != null && artwork.artist != _selectedArtist) {
        return false;
      }
      // Year filter
      if (_selectedYear != null && artwork.year != _selectedYear) {
        return false;
      }
      return true;
    }).toList();
    
    // Apply favorite filter (async check)
    if (_showOnlyFavorites) {
      final prefs = await SharedPreferences.getInstance();
      filtered = filtered.where((artwork) {
        return prefs.getBool('favorite_${artwork.id}') == true;
      }).toList();
    }
    
    // Apply sort
    filtered.sort((a, b) {
      int comparison = 0;
      
      switch (_sortOption) {
        case SortOption.title:
          comparison = a.title.compareTo(b.title);
          break;
        case SortOption.date:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case SortOption.artist:
          final artistA = a.artist ?? '';
          final artistB = b.artist ?? '';
          comparison = artistA.compareTo(artistB);
          break;
      }
      
      return _sortOrder == SortOrder.ascending ? comparison : -comparison;
    });
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final artworksAsync = ref.watch(artworkNotifierProvider);
    final authState = ref.watch(authStateProvider);

    // Guard: If user is not authenticated, redirect to login
    ref.listen<AsyncValue<User?>>(authStateProvider, (previous, next) {
      next.whenData((user) {
        if (user == null) {
          // User logged out, navigate to login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }
          });
        }
      });
    });

    // Also check current auth state
    authState.whenData((user) {
      if (user == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bộ Sưu Tập Nghệ Thuật'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Filter button with badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {
                  artworksAsync.whenData((artworks) {
                    _showFilterSortBottomSheet(context, artworks);
                  });
                },
                tooltip: 'Lọc & Sắp xếp',
              ),
              if (_hasActiveFilters())
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Center(
                      child: Text(
                        '${_getActiveFilterCount()}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (context.mounted) {
                ref.read(artworkNotifierProvider.notifier).refresh();
              }
            },
            tooltip: 'Làm mới',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await ref.read(authNotifierProvider.notifier).signOut();
                await Future.delayed(const Duration(milliseconds: 100));
                if (!context.mounted) return;
                final user = ref.read(currentUserProvider);
                if (user == null) {
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đăng xuất thất bại: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm tác phẩm...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase().trim());
              },
            ),
          ),
          // Active Filters Chips
          if (_hasActiveFilters())
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (_searchQuery.isNotEmpty)
                      Chip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search, size: 16),
                            const SizedBox(width: 4),
                            Text('Tìm: $_searchQuery'),
                          ],
                        ),
                        onDeleted: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        deleteIcon: Icon(Icons.close, size: 18),
                        backgroundColor: AppColors.primaryContainer,
                      ),
                    if (_selectedCategory != null) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Chip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.category, size: 16),
                            const SizedBox(width: 4),
                            Text('Danh mục: $_selectedCategory'),
                          ],
                        ),
                        onDeleted: () {
                          setState(() => _selectedCategory = null);
                        },
                        deleteIcon: Icon(Icons.close, size: 18),
                        backgroundColor: AppColors.primaryContainer,
                      ),
                    ],
                    if (_selectedArtist != null) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Chip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person, size: 16),
                            const SizedBox(width: 4),
                            Text('Nghệ sĩ: $_selectedArtist'),
                          ],
                        ),
                        onDeleted: () {
                          setState(() => _selectedArtist = null);
                        },
                        deleteIcon: Icon(Icons.close, size: 18),
                        backgroundColor: AppColors.primaryContainer,
                      ),
                    ],
                    if (_selectedYear != null) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Chip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 4),
                            Text('Năm: $_selectedYear'),
                          ],
                        ),
                        onDeleted: () {
                          setState(() => _selectedYear = null);
                        },
                        deleteIcon: Icon(Icons.close, size: 18),
                        backgroundColor: AppColors.primaryContainer,
                      ),
                    ],
                    if (_showOnlyWithCategory) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Chip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.label, size: 16),
                            const SizedBox(width: 4),
                            Text('Có danh mục'),
                          ],
                        ),
                        onDeleted: () {
                          setState(() => _showOnlyWithCategory = false);
                        },
                        deleteIcon: Icon(Icons.close, size: 18),
                        backgroundColor: AppColors.secondaryContainer,
                      ),
                    ],
                    if (_showOnlyFavorites) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Chip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.favorite, size: 16, color: Colors.red),
                            const SizedBox(width: 4),
                            Text('Yêu thích'),
                          ],
                        ),
                        onDeleted: () {
                          setState(() => _showOnlyFavorites = false);
                        },
                        deleteIcon: Icon(Icons.close, size: 18),
                        backgroundColor: AppColors.secondaryContainer,
                      ),
                    ],
                    const SizedBox(width: AppSpacing.xs),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedCategory = null;
                          _selectedArtist = null;
                          _selectedYear = null;
                          _showOnlyWithCategory = false;
                          _showOnlyFavorites = false;
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                      icon: Icon(Icons.clear_all, size: 18),
                      label: Text('Xóa tất cả'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Artworks List
          Expanded(
            child: artworksAsync.when(
              data: (artworks) {
                // Filter artworks based on search query
                // Nếu search query khớp với tên category, chỉ hiện artworks có category đó
                var filteredArtworks = _searchQuery.isEmpty
                    ? artworks
                    : artworks.where((artwork) {
                        final title = artwork.title.toLowerCase();
                        final artist = artwork.artist?.toLowerCase() ?? '';
                        final category = artwork.category?.toLowerCase() ?? '';
                        
                        // Nếu search query khớp với category, chỉ hiện artworks có category đó
                        if (category == _searchQuery) {
                          return true;
                        }
                        
                        // Nếu không, tìm kiếm bình thường
                        return title.contains(_searchQuery) ||
                            artist.contains(_searchQuery) ||
                            category.contains(_searchQuery);
                      }).toList();
                
                // Apply filters and sort (async)
                return FutureBuilder<List<Artwork>>(
                  future: _applyFiltersAndSort(filteredArtworks),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }
                    
                    final filteredArtworks = snapshot.data!;
                    
                    // Show result count và artworks list
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return Column(
                          children: [
                            // Result count indicator - chỉ hiện khi có filter
                            if (_hasActiveFilters() || filteredArtworks.length != artworks.length)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant.withValues(alpha: 0.3),
                                  border: Border(
                                    bottom: BorderSide(
                                      color: AppColors.border.withValues(alpha: 0.2),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 16,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Flexible(
                                      child: Text(
                                        'Hiển thị ${filteredArtworks.length} / ${artworks.length} tác phẩm',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: AppColors.textSecondary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            // Artworks list
                            Expanded(
                              child: _buildArtworksList(
                                context,
                                filteredArtworks,
                                artworks,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
              error: (error, stack) {
                ErrorHandler.logError(error, stack);
                final errorMessage = ErrorHandler.getErrorMessage(error);
                final isAuthError = ErrorHandler.isAuthError(error);
                final isNetworkError = ErrorHandler.isNetworkError(error);
                
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isNetworkError 
                            ? Icons.wifi_off
                            : isAuthError
                              ? Icons.lock_outline
                              : Icons.error_outline,
                          size: 64,
                          color: isNetworkError 
                            ? Colors.orange
                            : Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          errorMessage,
                          style: TextStyle(
                            fontSize: 16,
                            color: isNetworkError ? Colors.orange[700] : Colors.red[700],
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        if (isAuthError)
                          ElevatedButton.icon(
                            onPressed: () {
                              if (context.mounted) {
                                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                  (route) => false,
                                );
                              }
                            },
                            icon: const Icon(Icons.login),
                            label: const Text('Đăng nhập lại'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                              ),
                            ),
                          )
                        else
                          ElevatedButton.icon(
                            onPressed: () {
                              if (context.mounted) {
                                ref.read(artworkNotifierProvider.notifier).refresh();
                              }
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Thử lại'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const ArtworkFormScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(0.0, 1.0);
                const end = Offset.zero;
                const curve = Curves.ease;

                var tween = Tween(begin: begin, end: end).chain(
                  CurveTween(curve: curve),
                );

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Thêm tác phẩm'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
  
  Widget _buildArtworksList(
    BuildContext context,
    List<Artwork> filteredArtworks,
    List<Artwork> allArtworks,
  ) {
    if (filteredArtworks.isEmpty && allArtworks.isNotEmpty) {
      // No search results
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
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
                'Không tìm thấy kết quả',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Thử tìm kiếm với từ khóa khác hoặc xóa bộ lọc',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (filteredArtworks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.palette_outlined,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Chưa có tác phẩm nào',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Nhấn nút + để thêm tác phẩm đầu tiên',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (context.mounted) {
          await ref.read(artworkNotifierProvider.notifier).refresh();
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive grid layout với tỷ lệ cân đối
          final screenWidth = constraints.maxWidth;
          int crossAxisCount;
          double childAspectRatio;
          double spacing;
          
          if (screenWidth > 1200) {
            // Desktop large: 5 columns
            crossAxisCount = 5;
            childAspectRatio = 0.7;
            spacing = AppSpacing.lg;
          } else if (screenWidth > 900) {
            // Desktop: 4 columns
            crossAxisCount = 4;
            childAspectRatio = 0.72;
            spacing = AppSpacing.md;
          } else if (screenWidth > 600) {
            // Tablet: 3 columns
            crossAxisCount = 3;
            childAspectRatio = 0.75;
            spacing = AppSpacing.md;
          } else {
            // Mobile: 2 columns
            crossAxisCount = 2;
            childAspectRatio = 0.78;
            spacing = AppSpacing.sm;
          }
          
          return GridView.builder(
            padding: EdgeInsets.all(spacing),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: childAspectRatio,
            ),
            // Performance optimizations
            cacheExtent: 500, // Cache 500 pixels worth of widgets
            itemCount: filteredArtworks.length,
            itemBuilder: (context, index) {
              final artwork = filteredArtworks[index];
              return _ArtworkCard(key: ValueKey(artwork.id), artwork: artwork);
            },
          );
        },
      ),
    );
  }
}

class _ArtworkCard extends StatefulWidget {
  final Artwork artwork;

  const _ArtworkCard({super.key, required this.artwork});

  @override
  State<_ArtworkCard> createState() => _ArtworkCardState();
}

class _ArtworkCardState extends State<_ArtworkCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: _isHovered ? 8 : 4,
          shadowColor: AppColors.primary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          ),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ArtworkDetailScreen(
                        artworkId: widget.artwork.id,
                        artwork: widget.artwork, // Pass artwork directly
                      ),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              );
            },
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                    widget.artwork.imageUrl != null && widget.artwork.imageUrl!.isNotEmpty
                        ? Hero(
                            tag: 'artwork_image_${widget.artwork.id}',
                            child: GestureDetector(
                              onTap: () {
                                FullscreenImageViewer.show(
                                  context,
                                  widget.artwork.imageUrl!,
                                  heroTag: 'artwork_image_${widget.artwork.id}',
                                );
                              },
                            child: CachedNetworkImage(
                              imageUrl: widget.artwork.imageUrl!,
                            fit: BoxFit.cover,
                            // Performance: Use fadeInDuration for smoother loading
                            fadeInDuration: const Duration(milliseconds: 200),
                            fadeOutDuration: const Duration(milliseconds: 100),
                            // Performance: Use memCacheWidth to reduce memory usage
                            memCacheWidth: 400, // Limit image width in memory for grid view
                            placeholder: (context, url) => Container(
                              color: AppColors.surfaceVariant,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.surfaceVariant,
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 48,
                                color: AppColors.textTertiary,
                                  ),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primaryContainer,
                              AppColors.primaryContainer.withValues(alpha: 0.5),
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.palette,
                          size: 48,
                          color: AppColors.primary,
                        ),
                        ),
                  // Gradient overlay at bottom for better text readability
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Fullscreen button overlay
                  if (widget.artwork.imageUrl != null && widget.artwork.imageUrl!.isNotEmpty)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                        child: InkWell(
                          onTap: () {
                            FullscreenImageViewer.show(
                              context,
                              widget.artwork.imageUrl!,
                              heroTag: 'artwork_image_${widget.artwork.id}',
                            );
                          },
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            child: const Icon(
                              Icons.fullscreen,
                              color: Colors.white,
                              size: 18,
                            ),
                        ),
                      ),
                    ),
                  ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        widget.artwork.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Artist
                      if (widget.artwork.artist != null && widget.artwork.artist!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.artwork.artist!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      // Category chip
                      if (widget.artwork.category != null && widget.artwork.category!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Chip(
                          label: Text(
                            widget.artwork.category!,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          backgroundColor: AppColors.primaryContainer,
                          side: BorderSide.none,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

