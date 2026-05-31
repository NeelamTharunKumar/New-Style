import 'dart:io';

import 'package:path_provider/path_provider.dart';

class LocalImageService {
  const LocalImageService();

  bool isLocalReference(String? value) {
    return value != null && (value.startsWith('local://') || value.startsWith('file://'));
  }

  String wardrobeRefForItem(String itemId, {String extension = 'jpg'}) {
    return 'local://wardrobe/$itemId.$extension';
  }

  Future<String> copyImageIntoWardrobe(String sourcePath, {required String itemIdHint}) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw StateError('Selected image does not exist');
    }
    final directory = await getApplicationDocumentsDirectory();
    final wardrobeDir = Directory('${directory.path}/wardrobe_images');
    if (!await wardrobeDir.exists()) {
      await wardrobeDir.create(recursive: true);
    }

    final sanitizedId = _safeFilePart(itemIdHint.isEmpty ? 'wardrobe_item' : itemIdHint);
    final extension = _extensionFromPath(sourcePath);
    final destination = File('${wardrobeDir.path}/${sanitizedId}_${DateTime.now().millisecondsSinceEpoch}.$extension');
    final stored = await source.copy(destination.path);
    return stored.uri.toString();
  }

  String? pathFromLocalRef(String? value) {
    if (value == null || value.isEmpty) return null;
    final uri = Uri.tryParse(value);
    if (uri != null && uri.scheme == 'file') return uri.toFilePath();
    if (value.startsWith('/')) return value;
    return null;
  }

  String privacyLabel(String? value) {
    if (value == null || value.isEmpty) return 'No local image linked yet';
    if (value.startsWith('file://')) return 'Stored inside app-local files';
    if (value.startsWith('local://')) return 'Local-only image reference';
    return 'External-looking reference; verify before syncing';
  }

  String _extensionFromPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'png';
    if (lower.endsWith('.webp')) return 'webp';
    if (lower.endsWith('.jpeg')) return 'jpg';
    return 'jpg';
  }

  String _safeFilePart(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'_+'), '_').replaceAll(RegExp(r'^_|_$'), '');
  }
}
