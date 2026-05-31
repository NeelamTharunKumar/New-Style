import 'package:flutter/services.dart';

class NativeMlBridge {
  NativeMlBridge({MethodChannel? channel}) : _channel = channel ?? const MethodChannel('bharatfit/native_ml');

  final MethodChannel _channel;

  Future<bool> isAvailable() async {
    try {
      final result = await _channel.invokeMethod<bool>('isAvailable');
      return result == true;
    } on MissingPluginException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> analyzeGarmentImage({
    required String imagePath,
    required String localImageRef,
    required String itemIdHint,
  }) async {
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>('analyzeGarmentImage', {
        'imagePath': imagePath,
        'localImageRef': localImageRef,
        'itemIdHint': itemIdHint,
      });
      return result;
    } on MissingPluginException {
      return null;
    } catch (_) {
      return null;
    }
  }
}
