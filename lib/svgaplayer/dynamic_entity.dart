import 'dart:io';
import 'dart:ui' as ui show Image;

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:svga_viewer/svgaplayer/transformation/ImageTransformation.dart';

typedef SVGACustomDrawer = Function(Canvas canvas, int frameIndex);

class SVGADynamicEntity {
  final Map<String, bool> dynamicHidden = {};
  final Map<String, ui.Image> dynamicImages = {};
  final Map<String, TextPainter> dynamicText = {};
  final Map<String, SVGACustomDrawer> dynamicDrawer = {};

  void setHidden(bool value, String forKey) {
    dynamicHidden[forKey] = value;
  }

  void setImage(ui.Image image, String forKey) {
    dynamicImages[forKey] = image;
  }

  Future<void> setImageWithUrl(String url, String forKey,
      {ImageTransformation? transformation}) async {
    var image =
        await decodeImageFromList((await get(Uri.parse(url))).bodyBytes);
    if (transformation != null) {
      image = await transformation.transform(image);
    }
    dynamicImages[forKey] = image;
  }

  Future<void> setImageWithAssert(String assertPath, String forKey,
      {ImageTransformation? transformation}) async {
    var bytes = (await rootBundle.load(assertPath)).buffer.asUint8List();
    var image = await decodeImageFromList(bytes);
    if (transformation != null) {
      image = await transformation.transform(image);
    }
    dynamicImages[forKey] = image;
  }

  Future<void> setImageWithFile(File file, String forKey,
      {ImageTransformation? transformation}) async {
    var bytes = await file.readAsBytes();
    var image = await decodeImageFromList(bytes);
    if (transformation != null) {
      image = await transformation.transform(image);
    }
    dynamicImages[forKey] = image;
  }

  void setText(TextPainter textPainter, String forKey) {
    if (textPainter.textDirection == null) {
      textPainter.textDirection = TextDirection.ltr;
      textPainter.layout();
    }
    dynamicText[forKey] = textPainter;
  }

  void setDynamicDrawer(SVGACustomDrawer drawer, String forKey) {
    dynamicDrawer[forKey] = drawer;
  }

  void reset() {
    dynamicHidden.clear();
    dynamicImages.clear();
    dynamicText.clear();
    dynamicDrawer.clear();
  }
}
