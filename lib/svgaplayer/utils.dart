import 'dart:math';
import 'dart:ui' as ui show Image;

int estimateImageMemory(ui.Image image) {
  // 对于 RGBA 格式的图像，每个像素占用4字节
  const bytesPerPixel = 4;
  return image.width * image.height * bytesPerPixel;
}

String formatFileSize(int bytes, {int decimals = 2}) {
  if (bytes <= 0) return "0 B";
  const suffixes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
  var i = (log(bytes) / log(1024)).floor();
  return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
}
