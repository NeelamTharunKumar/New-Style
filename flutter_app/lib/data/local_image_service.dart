class LocalImageService {
  const LocalImageService();

  bool isLocalReference(String? value) {
    return value != null && (value.startsWith('local://') || value.startsWith('file://'));
  }

  String wardrobeRefForItem(String itemId, {String extension = 'jpg'}) {
    return 'local://wardrobe/$itemId.$extension';
  }

  String privacyLabel(String? value) {
    if (value == null || value.isEmpty) return 'No local image linked yet';
    if (isLocalReference(value)) return 'Local-only image reference';
    return 'External-looking reference; verify before syncing';
  }
}
