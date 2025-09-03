import 'dart:ui';

import 'package:svga_viewer/svgaplayer/transformation/image_transformation.dart';

class SpriteInfo {
  final String name;
  int? width;
  int? height;
  int? memory;
  String? text;
  bool? isHighlight;
  Color? textColor;
  double? textSize;
  String? imagePath;
  ImageTransformation? imageTransformation;

  SpriteInfo({
    required this.name,
    this.width,
    this.height,
    this.memory,
    this.text,
    this.isHighlight,
    this.textColor,
    this.textSize,
    this.imagePath,
    this.imageTransformation,
  });
}