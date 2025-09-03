import 'dart:typed_data';
import 'dart:ui' as ui show Image, PictureRecorder;

import 'package:flutter/painting.dart';

class ImageDecoder {
  /// 解码图片
  static Future<ui.Image> decodeImage(Uint8List bytes,
      {int? targetWidth, int? targetHeight}) async {
    final originalImage = await decodeImageFromList(bytes);
    // 如果指定了目标尺寸，则调整图像大小
    ui.Image finalImage = originalImage;
    if (targetWidth != null &&
        targetHeight != null &&
        targetWidth != originalImage.width &&
        targetHeight != originalImage.height) {
      finalImage = await _resizeImage(originalImage, targetWidth, targetHeight);
    }
    return finalImage;
  }

  /// 调整图片大小
  static Future<ui.Image> _resizeImage(
      ui.Image image, int width, int height) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      Paint(),
    );

    final picture = recorder.endRecording();
    final resizedImage = await picture.toImage(width, height);
    return resizedImage;
  }
}
