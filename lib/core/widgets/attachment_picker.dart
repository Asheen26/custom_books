import 'dart:io';

import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/models/attachment_file.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/bottom_sheet_drag_handle.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Default maximum number of attachments allowed.
const int kDefaultMaxAttachments = 5;

/// Default maximum file size per attachment (10 MB).
const int kDefaultMaxFileSizeBytes = 10 * 1024 * 1024;

class AttachmentPicker extends StatefulWidget {
  /// Label shown inside the attach button.
  final String label;

  /// Called every time the attachment list changes.
  final ValueChanged<List<AttachmentFile>> onChanged;

  /// Initial list of attachments (e.g. when editing an existing record).
  final List<AttachmentFile> initialFiles;

  /// Maximum number of files the user may attach.
  final int maxFiles;

  /// Maximum size in bytes for a single file.
  final int maxFileSizeBytes;

  const AttachmentPicker({
    super.key,
    this.label = 'Attach Receipt',
    required this.onChanged,
    this.initialFiles = const [],
    this.maxFiles = kDefaultMaxAttachments,
    this.maxFileSizeBytes = kDefaultMaxFileSizeBytes,
  });

  @override
  State<AttachmentPicker> createState() => _AttachmentPickerState();
}

class _AttachmentPickerState extends State<AttachmentPicker> {
  late final List<AttachmentFile> _files;

  @override
  void initState() {
    super.initState();
    _files = List.from(widget.initialFiles);
  }

  // ── Internal helpers ──────────────────────────────────────────────────────

  Future<void> _addFile(AttachmentFile file) async {
    if (_files.length >= widget.maxFiles) {
      if (mounted) {
        ToastificationHelper.showWarning(
          context,
          'Maximum ${widget.maxFiles} attachments allowed.',
        );
      }
      return;
    }
    final size = await file.sizeInBytes();
    if (size > widget.maxFileSizeBytes) {
      if (mounted) {
        final mb = (widget.maxFileSizeBytes / (1024 * 1024)).round();
        ToastificationHelper.showWarning(
          context,
          '"${file.name}" exceeds the $mb MB limit and was not added.',
        );
      }
      return;
    }
    if (mounted) {
      setState(() => _files.add(file));
      widget.onChanged(List.unmodifiable(_files));
    }
  }

  void _removeFile(int index) {
    setState(() => _files.removeAt(index));
    widget.onChanged(List.unmodifiable(_files));
  }

  // ── Pickers ───────────────────────────────────────────────────────────────

  Future<void> _pickFromCamera() async {
    final remaining = widget.maxFiles - _files.length;
    if (remaining <= 0) {
      ToastificationHelper.showWarning(
        context,
        'Maximum ${widget.maxFiles} attachments already reached.',
      );
      return;
    }
    try {
      final results = await Navigator.push<List<XFile>>(
        context,
        MaterialPageRoute(
          builder: (_) => AttachmentCameraReviewPage(maxPhotos: remaining),
          fullscreenDialog: true,
        ),
      );
      if (results == null || results.isEmpty) return;
      for (final xFile in results) {
        await _addFile(AttachmentFile.fromXFile(xFile));
      }
    } catch (_) {
      if (mounted) {
        ToastificationHelper.showError(
          context,
          'Could not open camera. Please try again.',
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
      );
      if (picked == null) return;
      await _addFile(AttachmentFile.fromXFile(picked));
    } catch (_) {
      if (mounted) {
        ToastificationHelper.showError(
          context,
          'Could not open gallery. Please try again.',
        );
      }
    }
  }

  Future<void> _pickFromFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: [
          'pdf', 'doc', 'docx', 'xls', 'xlsx',
          'jpg', 'jpeg', 'png', 'gif', 'webp',
        ],
      );
      if (result == null || result.files.isEmpty) return;

      final remaining = widget.maxFiles - _files.length;
      final toAdd = result.files.take(remaining).toList();

      if (result.files.length > remaining) {
        if (mounted) {
          ToastificationHelper.showWarning(
            context,
            'Only $remaining more attachment(s) allowed. '
            'Extra files were skipped.',
          );
        }
      }

      for (final pf in toAdd) {
        if (pf.path == null) continue;
        await _addFile(AttachmentFile.fromPlatformFile(pf));
      }
    } catch (_) {
      if (mounted) {
        ToastificationHelper.showError(
          context,
          'Could not open file picker. Please try again.',
        );
      }
    }
  }

  // ── Bottom sheet ──────────────────────────────────────────────────────────

  Future<void> _showPickerSheet() async {
    if (_files.length >= widget.maxFiles) {
      ToastificationHelper.showWarning(
        context,
        'Maximum ${widget.maxFiles} attachments allowed.',
      );
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimensions.radius20),
        ),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.width20,
            vertical: Dimensions.height20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BottomSheetDragHandle(),
              SizedBox(height: Dimensions.height10 / 2),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: Dimensions.font16 * 1.05,
                  fontWeight: FontWeight.w700,
                  color: sheetCtx.colors.textPrimary,
                ),
              ),
              SizedBox(height: Dimensions.height10 / 2),
              Text(
                'Up to ${widget.maxFiles} files · max '
                '${(widget.maxFileSizeBytes / (1024 * 1024)).round()} MB each'
                '  (${_files.length}/${widget.maxFiles} used)',
                style: TextStyle(
                  fontSize: Dimensions.font16 * 0.75,
                  color: sheetCtx.colors.textSecondary,
                ),
              ),
              SizedBox(height: Dimensions.height20),
              _sheetOption(
                sheetCtx,
                icon: Icons.camera_alt_outlined,
                label: 'Take a Photo',
                subtitle: 'Use your camera',
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _pickFromCamera();
                },
              ),
              SizedBox(height: Dimensions.height10),
              _sheetOption(
                sheetCtx,
                icon: Icons.photo_library_outlined,
                label: 'Select from Device',
                subtitle: 'Choose a photo from your gallery',
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _pickFromGallery();
                },
              ),
              SizedBox(height: Dimensions.height10),
              _sheetOption(
                sheetCtx,
                icon: Icons.insert_drive_file_outlined,
                label: 'Select from Documents',
                subtitle: 'PDF, Word, or other files',
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _pickFromFiles();
                },
              ),
              SizedBox(height: Dimensions.height10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetOption(
    BuildContext ctx, {
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radius15),
      child: Container(
        padding: EdgeInsets.all(Dimensions.width15),
        decoration: BoxDecoration(
          color: ctx.colors.surfaceLight,
          borderRadius: BorderRadius.circular(Dimensions.radius15),
          border: Border.all(color: ctx.colors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(Dimensions.width10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(Dimensions.radius15 / 2),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: Dimensions.iconSize24,
              ),
            ),
            SizedBox(width: Dimensions.width15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: Dimensions.font16 * 0.9,
                      fontWeight: FontWeight.w700,
                      color: ctx.colors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: Dimensions.font16 * 0.75,
                      color: ctx.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _AttachButton(
          label: widget.label,
          count: _files.length,
          onTap: _showPickerSheet,
        ),
        if (_files.isNotEmpty) ...[
          SizedBox(height: Dimensions.height15),
          _ThumbnailRow(files: _files, onRemove: _removeFile),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AttachButton  (private)
// ─────────────────────────────────────────────────────────────────────────────

class _AttachButton extends StatelessWidget {
  final String label;
  final int count;
  final VoidCallback onTap;

  const _AttachButton({
    required this.label,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: Dimensions.height45 * 1.8,
            height: Dimensions.height45 * 1.8,
            decoration: BoxDecoration(
              border: Border.all(color: context.colors.border),
              borderRadius: BorderRadius.circular(Dimensions.radius15 / 2),
              color: context.colors.surfaceLight,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.attach_file_rounded,
                  color: context.colors.textSecondary,
                  size: Dimensions.iconSize24,
                ),
                SizedBox(height: Dimensions.height10 / 4),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.7,
                    color: context.colors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (count > 0)
            Positioned(
              top: -Dimensions.height10 * 0.6,
              right: -Dimensions.width10 * 0.6,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width10 * 0.7,
                  vertical: Dimensions.height10 * 0.4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(Dimensions.radius20),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.7,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ThumbnailRow  (private)
// ─────────────────────────────────────────────────────────────────────────────

class _ThumbnailRow extends StatelessWidget {
  final List<AttachmentFile> files;
  final void Function(int index) onRemove;

  const _ThumbnailRow({required this.files, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Dimensions.width10,
      runSpacing: Dimensions.height10,
      children: files.asMap().entries.map((e) {
        return _Thumbnail(file: e.value, index: e.key, onRemove: onRemove);
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _Thumbnail  (private)
// ─────────────────────────────────────────────────────────────────────────────

class _Thumbnail extends StatelessWidget {
  final AttachmentFile file;
  final int index;
  final void Function(int) onRemove;

  const _Thumbnail({
    required this.file,
    required this.index,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Dimensions.height45 * 1.8,
      height: Dimensions.height45 * 1.8,
      decoration: BoxDecoration(
        color: context.colors.surfaceLight,
        borderRadius: BorderRadius.circular(Dimensions.radius15 / 2),
        border: Border.all(color: context.colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (file.isImage)
            Image.file(
              File(file.path),
              fit: BoxFit.cover,
              errorBuilder: (_, e, stack) => _FilePlaceholder(file: file),
            )
          else
            _FilePlaceholder(file: file),
          Positioned(
            top: Dimensions.height10 * 0.4,
            right: Dimensions.width10 * 0.4,
            child: GestureDetector(
              onTap: () => onRemove(index),
              child: Container(
                padding: EdgeInsets.all(Dimensions.height10 * 0.35),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: Dimensions.iconSize16 * 0.85,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _FilePlaceholder  (private)
// ─────────────────────────────────────────────────────────────────────────────

class _FilePlaceholder extends StatelessWidget {
  final AttachmentFile file;

  const _FilePlaceholder({required this.file});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.surfaceLight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            file.isPdf
                ? Icons.picture_as_pdf_rounded
                : Icons.insert_drive_file_rounded,
            color: context.colors.textSecondary,
            size: Dimensions.iconSize24 * 1.2,
          ),
          SizedBox(height: Dimensions.height10 / 3),
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: Dimensions.width10 / 2),
            child: Text(
              file.extension.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: Dimensions.font16 * 0.65,
                fontWeight: FontWeight.w600,
                color: context.colors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AttachmentCameraReviewPage extends StatefulWidget {
  final int maxPhotos;

  const AttachmentCameraReviewPage({super.key, required this.maxPhotos});

  @override
  State<AttachmentCameraReviewPage> createState() =>
      _AttachmentCameraReviewPageState();
}

class _AttachmentCameraReviewPageState
    extends State<AttachmentCameraReviewPage> {
  final List<XFile> _photos = [];
  bool _isTaking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _takePhoto());
  }

  Future<void> _takePhoto() async {
    if (_isTaking) return;
    if (_photos.length >= widget.maxPhotos) {
      _done();
      return;
    }
    setState(() => _isTaking = true);
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
      );
      if (!mounted) return;
      if (picked != null) {
        setState(() => _photos.add(picked));
      } else if (_photos.isEmpty) {
        Navigator.pop(context, <XFile>[]);
      }
    } catch (_) {
      if (mounted && _photos.isEmpty) Navigator.pop(context, <XFile>[]);
    } finally {
      if (mounted) setState(() => _isTaking = false);
    }
  }

  void _done() => Navigator.pop(context, List<XFile>.from(_photos));

  void _removePhoto(int index) => setState(() => _photos.removeAt(index));

  @override
  Widget build(BuildContext context) {
    final last = _photos.isNotEmpty ? _photos.last : null;
    final canTakeMore = _photos.length < widget.maxPhotos;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width15,
                vertical: Dimensions.height10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Cancel
                  GestureDetector(
                    onTap: () => Navigator.pop(context, <XFile>[]),
                    child: Container(
                      padding: EdgeInsets.all(Dimensions.width10 * 0.8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: Dimensions.iconSize24,
                      ),
                    ),
                  ),
                  // Counter
                  if (_photos.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.width15,
                        vertical: Dimensions.height10 * 0.5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius20),
                      ),
                      child: Text(
                        '${_photos.length} / ${widget.maxPhotos}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: Dimensions.font16 * 0.85,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  // Done button
                  if (_photos.isNotEmpty)
                    GestureDetector(
                      onTap: _done,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.width15,
                          vertical: Dimensions.height10 * 0.6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius:
                              BorderRadius.circular(Dimensions.radius20),
                        ),
                        child: Text(
                          'Done (${_photos.length})',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: Dimensions.font16 * 0.9,
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(width: Dimensions.iconSize24 * 1.8),
                ],
              ),
            ),

            // ── Preview ────────────────────────────────────────────────────
            Expanded(
              child: last == null
                  ? Center(
                      child: _isTaking
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'No photos yet',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: Dimensions.font16,
                              ),
                            ),
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(File(last.path), fit: BoxFit.contain),
                        if (_isTaking)
                          Container(
                            color: Colors.black38,
                            child: const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white),
                            ),
                          ),
                      ],
                    ),
            ),

            // ── Thumbnail strip ────────────────────────────────────────────
            if (_photos.length > 1)
              SizedBox(
                height: Dimensions.height45 * 1.5,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width15,
                    vertical: Dimensions.height10 * 0.5,
                  ),
                  itemCount: _photos.length,
                  separatorBuilder: (_, i) =>
                      SizedBox(width: Dimensions.width10 * 0.6),
                  itemBuilder: (ctx, i) {
                    final isLast = i == _photos.length - 1;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: Dimensions.height45 * 1.2,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                Dimensions.radius15 / 3),
                            border: Border.all(
                              color:
                                  isLast ? AppColors.primary : Colors.white38,
                              width: isLast ? 2 : 1,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.file(
                            File(_photos[i].path),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: -Dimensions.height10 * 0.5,
                          right: -Dimensions.width10 * 0.5,
                          child: GestureDetector(
                            onTap: () => _removePhoto(i),
                            child: Container(
                              padding: EdgeInsets.all(
                                  Dimensions.height10 * 0.3),
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: Dimensions.iconSize16 * 0.75,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

            // ── Shutter button ─────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width20,
                vertical: Dimensions.height20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (canTakeMore)
                    GestureDetector(
                      onTap: _isTaking ? null : _takePhoto,
                      child: Container(
                        width: Dimensions.height45 * 1.6,
                        height: Dimensions.height45 * 1.6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          color: _isTaking
                              ? Colors.white24
                              : Colors.white.withValues(alpha: 0.15),
                        ),
                        child: _isTaking
                            ? const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: Dimensions.iconSize24 * 1.3,
                              ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
