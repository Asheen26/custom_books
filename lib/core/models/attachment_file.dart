import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class AttachmentFile {
  final String path;
  final String name;
  final String extension;

  const AttachmentFile({
    required this.path,
    required this.name,
    required this.extension,
  });

  factory AttachmentFile.fromXFile(XFile xFile) {
    final name = xFile.name.isNotEmpty
        ? xFile.name
        : xFile.path.split(Platform.pathSeparator).last;
    final ext = name.contains('.') ? name.split('.').last.toLowerCase() : '';
    return AttachmentFile(path: xFile.path, name: name, extension: ext);
  }

  factory AttachmentFile.fromPlatformFile(PlatformFile pf) {
    final ext = pf.extension?.toLowerCase() ?? '';
    return AttachmentFile(path: pf.path!, name: pf.name, extension: ext);
  }

  /// Whether the file is a displayable image.
  bool get isImage =>
      ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);

  /// Whether the file is a PDF document.
  bool get isPdf => extension == 'pdf';

  /// Returns the file size in bytes, or 0 if the file cannot be read.
  Future<int> sizeInBytes() async {
    try {
      return await File(path).length();
    } catch (_) {
      return 0;
    }
  }
}
