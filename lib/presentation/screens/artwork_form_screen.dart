import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/artwork_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/artwork.dart';
import '../../core/config/supabase_config.dart';
import '../../core/utils/error_handler.dart';

class ArtworkFormScreen extends ConsumerStatefulWidget {
  final Artwork? artwork; // null = create, not null = edit

  const ArtworkFormScreen({super.key, this.artwork});

  @override
  ConsumerState<ArtworkFormScreen> createState() => _ArtworkFormScreenState();
}

class _ArtworkFormScreenState extends ConsumerState<ArtworkFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _yearController = TextEditingController();
  final _locationController = TextEditingController();
  
  XFile? _selectedImage;
  String? _imageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.artwork != null) {
      // Edit mode - populate fields
      final artwork = widget.artwork!;
      _titleController.text = artwork.title;
      _artistController.text = artwork.artist ?? '';
      _descriptionController.text = artwork.description ?? '';
      _categoryController.text = artwork.category ?? '';
      _yearController.text = artwork.year?.toString() ?? '';
      _locationController.text = artwork.location ?? '';
      _imageUrl = artwork.imageUrl;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _yearController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      
      // Show dialog to choose source (camera or gallery)
      if (!kIsWeb) {
        // Mobile: Show option dialog
        final ImageSource? source = await showDialog<ImageSource>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Chọn ảnh từ'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Camera'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Thư viện ảnh'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
        
        if (source == null) return;
        
        final XFile? image = await picker.pickImage(
          source: source,
          imageQuality: 80, // Compress to 80% quality
          maxWidth: 1920, // Max width 1920px
          maxHeight: 1920, // Max height 1920px
        );

        if (image != null) {
          setState(() {
            _selectedImage = image;
            _imageUrl = null; // Clear old URL when new image selected
          });
        }
      } else {
        // Web: Use gallery (file picker)
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );

        if (image != null) {
          setState(() {
            _selectedImage = image;
            _imageUrl = null; // Clear old URL when new image selected
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi chọn ảnh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return _imageUrl; // Return existing URL if no new image

    try {
      final userId = SupabaseConfig.client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final originalName = _selectedImage!.name;
      final extension = originalName.split('.').last;
      final fileName = '$timestamp.$extension';
      final filePath = '$userId/$fileName';
      
      if (kIsWeb) {
        // Web: upload bytes
        final fileBytes = await _selectedImage!.readAsBytes();
        await SupabaseConfig.client.storage.from('artwork-images').uploadBinary(
          filePath,
          fileBytes,
        );
      } else {
        // Mobile: upload File
        final file = File(_selectedImage!.path);
        await SupabaseConfig.client.storage.from('artwork-images').upload(
          filePath,
          file,
        );
      }

      // Get public URL
      final url = SupabaseConfig.client.storage
          .from('artwork-images')
          .getPublicUrl(filePath);

      return url;
    } catch (e) {
      final errorMsg = e.toString().toLowerCase();
      if (errorMsg.contains('bucket') || errorMsg.contains('storage')) {
        throw Exception('Lỗi storage. Vui lòng kiểm tra bucket "artwork-images" đã được tạo chưa.');
      } else if (errorMsg.contains('permission') || errorMsg.contains('policy')) {
        throw Exception('Không có quyền upload. Vui lòng kiểm tra storage policies.');
      } else {
        throw Exception('Lỗi upload ảnh: $e');
      }
    }
  }

  Future<void> _saveArtwork() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = SupabaseConfig.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Upload image if selected
      String? finalImageUrl = _imageUrl;
      if (_selectedImage != null) {
        finalImageUrl = await _uploadImage();
      }

      final artwork = Artwork(
        id: widget.artwork?.id ?? '', // Will be generated by Supabase if new
        userId: userId,
        title: _titleController.text.trim(),
        artist: _artistController.text.trim().isEmpty ? null : _artistController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        category: _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
        year: _yearController.text.trim().isEmpty ? null : int.tryParse(_yearController.text.trim()),
        location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        imageUrl: finalImageUrl,
        createdAt: widget.artwork?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.artwork == null) {
        // Create new
        await ref.read(artworkNotifierProvider.notifier).createArtwork(artwork);
      } else {
        // Update existing
        await ref.read(artworkNotifierProvider.notifier).updateArtwork(artwork);
      }

      if (!mounted) return;
      
      // Return true to indicate success (for edit mode)
      Navigator.of(context).pop(widget.artwork != null ? true : null);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(widget.artwork == null
              ? 'Đã tạo tác phẩm thành công!'
              : 'Đã cập nhật tác phẩm thành công!'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          ),
        ),
      );
    } catch (e) {
      ErrorHandler.logError(e);
      if (mounted) {
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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.artwork == null ? 'Thêm Tác phẩm' : 'Sửa Tác phẩm',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive: adjust layout based on screen width
          final isWideScreen = constraints.maxWidth > 600;
          final imageAspectRatio = isWideScreen ? 16 / 9 : 4 / 3; // Wider on desktop, taller on mobile
          
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWideScreen ? AppSpacing.xl : AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image picker section - responsive layout
                  if (isWideScreen)
                    // Desktop: Image on left, form on right
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image section - 40% width
                        Expanded(
                          flex: 2,
                          child: Container(
                            margin: const EdgeInsets.only(right: AppSpacing.lg, bottom: AppSpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hình ảnh',
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                _buildImagePicker(context, imageAspectRatio),
                              ],
                            ),
                          ),
                        ),
                        // Form section - 60% width
                        Expanded(
                          flex: 3,
                          child: _buildFormFields(context),
                        ),
                      ],
                    )
                  else
                    // Mobile: Stacked layout
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Image picker section
                        Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hình ảnh',
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              _buildImagePicker(context, imageAspectRatio),
                            ],
                          ),
                        ),
                        // Form fields
                        _buildFormFields(context),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildImagePicker(BuildContext context, double aspectRatio) {
    return GestureDetector(
      onTap: _pickImage,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            border: Border.all(
              color: AppColors.border,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
                  child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge - 2),
            child: _selectedImage != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              kIsWeb
                                  ? Image.network(_selectedImage!.path, fit: BoxFit.cover)
                                  : Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                            Colors.black.withValues(alpha: 0.4),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(AppSpacing.md),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : _imageUrl != null && _imageUrl!.isNotEmpty
                            ? Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(_imageUrl!, fit: BoxFit.cover),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                                Colors.black.withValues(alpha: 0.4),
                                        ],
                                      ),
                                    ),
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.all(AppSpacing.md),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.6),
                                          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                                        ),
                                        child: const Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(AppSpacing.lg),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryContainer,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.add_photo_alternate,
                                      size: 56,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  Text(
                                    'Nhấn để chọn ảnh',
                                    style: AppTypography.bodyLarge.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    'Camera hoặc Thư viện ảnh',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildFormFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Basic Information Section
        Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Thông tin cơ bản',
                          style: AppTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Title field - full width
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Tiêu đề *',
                        prefixIcon: const Icon(Icons.title),
                        filled: true,
                        fillColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.md,
                        ),
                      ),
                      style: AppTypography.bodyLarge,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tiêu đề';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Artist and Category - side by side on wide screen
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 400;
                        if (isWide) {
                          return Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _artistController,
                                  decoration: InputDecoration(
                                    labelText: 'Nghệ sĩ',
                                    prefixIcon: const Icon(Icons.person_outline),
                                    filled: true,
                                    fillColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                      vertical: AppSpacing.md,
                                    ),
                                  ),
                                  style: AppTypography.bodyLarge,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: TextFormField(
                                  controller: _categoryController,
                                  decoration: InputDecoration(
                                    labelText: 'Danh mục',
                                    prefixIcon: const Icon(Icons.category_outlined),
                                    filled: true,
                                    fillColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                      vertical: AppSpacing.md,
                                    ),
                                  ),
                                  style: AppTypography.bodyLarge,
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              TextFormField(
                                controller: _artistController,
                                decoration: InputDecoration(
                                  labelText: 'Nghệ sĩ',
                                  prefixIcon: const Icon(Icons.person_outline),
                                  filled: true,
                                  fillColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.md,
                                  ),
                                ),
                                style: AppTypography.bodyLarge,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              TextFormField(
                                controller: _categoryController,
                                decoration: InputDecoration(
                                  labelText: 'Danh mục',
                                  prefixIcon: const Icon(Icons.category_outlined),
                                  filled: true,
                                  fillColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.md,
                                  ),
                                ),
                                style: AppTypography.bodyLarge,
                              ),
                            ],
                          );
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _yearController,
                      decoration: InputDecoration(
                        labelText: 'Năm',
                        prefixIcon: const Icon(Icons.calendar_today_outlined),
                        filled: true,
                        fillColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.md,
                        ),
                      ),
                      style: AppTypography.bodyLarge,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          if (int.tryParse(value.trim()) == null) {
                            return 'Vui lòng nhập năm hợp lệ';
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              // Additional Details Section
              Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Chi tiết bổ sung',
                          style: AppTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Mô tả',
                        prefixIcon: const Icon(Icons.description_outlined),
                        filled: true,
                        fillColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                        ),
                        contentPadding: const EdgeInsets.all(AppSpacing.md),
                      ),
                      style: AppTypography.bodyLarge,
                      maxLines: 4,
                      minLines: 3,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Vị trí',
                        hintText: 'Ví dụ: Bảo tàng Mỹ thuật, Hà Nội',
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        filled: true,
                        fillColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.md,
                        ),
                      ),
                      style: AppTypography.bodyLarge,
                    ),
                  ],
                ),
              ),

        // Save Button
        Container(
          margin: const EdgeInsets.only(top: AppSpacing.md),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveArtwork,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                ),
              ),
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(
                      widget.artwork == null ? Icons.add_circle_outline : Icons.save_outlined,
                      size: 24,
                    ),
              label: Text(
                _isLoading
                    ? 'Đang xử lý...'
                    : (widget.artwork == null ? 'Tạo tác phẩm' : 'Cập nhật tác phẩm'),
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onPrimary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

