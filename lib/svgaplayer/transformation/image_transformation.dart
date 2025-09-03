import 'dart:ui';

abstract class ImageTransformation {
  Future<Image> transform(Image image) async{
    return image;
  }
}
