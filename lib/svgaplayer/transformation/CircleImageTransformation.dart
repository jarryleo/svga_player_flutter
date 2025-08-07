import 'dart:ui';

import 'ImageTransformation.dart';

class CircleImageTransformation extends ImageTransformation {
  @override
  Future<Image> transform(Image image) async {
    // 计算圆形的半径（取较短边的一半）
    final radius =
        (image.width < image.height ? image.width : image.height) / 2;

    final center = Offset(image.width / 2, image.height / 2);

    // 创建 PictureRecorder 来记录绘制操作
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    // 创建圆形路径
    final clipPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));

    // 应用裁剪
    canvas.clipPath(clipPath);

    // 绘制原始图像
    final srcRect =
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    final dstRect = Rect.fromLTWH(
      (image.width - radius * 2) / 2,
      (image.height - radius * 2) / 2,
      radius * 2,
      radius * 2,
    );

    canvas.drawImageRect(
      image,
      srcRect,
      dstRect,
      Paint(),
    );

    // 结束录制并生成新图像
    final picture = pictureRecorder.endRecording();
    final circularImage =
        await picture.toImage((radius * 2).toInt(), (radius * 2).toInt());

    return circularImage;
  }
}
