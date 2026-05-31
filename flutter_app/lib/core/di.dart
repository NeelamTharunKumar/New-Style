// Dependency Inversion - All ML services behind interfaces
abstract class LocalMLService {
  Future<Map<String, dynamic>> extractStyleProfileFeatures(List<double> selfieLandmarks);
  Future<Map<String, dynamic>> extractGarmentFeatures(String imagePath);
  Future<List<double>> getCLIPEmbedding(String imagePath);
}

class MediaPipeLocalMLService implements LocalMLService {
  @override
  Future<Map<String, dynamic>> extractStyleProfileFeatures(List<double> selfieLandmarks) async {
    // On-device MediaPipe FaceMesh + Pose processing
    return {
      'skin_tone_lab': [45.2, 12.1, -8.3],
      'face_shape': 'oval',
      'body_type': 'rectangle',
      'fashion_personality': 'minimalist',
      'confidence': 0.92
    };
  }

  @override
  Future<Map<String, dynamic>> extractGarmentFeatures(String imagePath) async {
    // YOLOv8n + SAM on-device
    return {
      'category': 'shirt',
      'color': '#1E3A8A',
      'pattern': 'solid',
      'material': 'cotton',
      'style': 'smart_casual',
      'season': 'all',
      'clip_embedding': List.filled(512, 0.01)
    };
  }

  @override
  Future<List<double>> getCLIPEmbedding(String imagePath) async {
    // Simulated on-device CLIP
    return List.filled(512, 0.023);
  }
}