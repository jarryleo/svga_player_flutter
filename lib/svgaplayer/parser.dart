import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:archive/archive.dart' as archive;
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show decodeImageFromList;
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' show get;

// ignore: import_of_legacy_library_into_null_safe
import 'cache/http_cache_manager.dart';
import 'proto/svga.pbserver.dart';
import 'sprite_info.dart';
import 'utils.dart';

const _filterKey = 'SVGAParser';

/// You use SVGAParser to load and decode animation files.
class SVGAParser {
  const SVGAParser();

  static const shared = SVGAParser();

  /// Download animation file from remote server, and decode it.
  Future<MovieEntity> decodeFromURL(String url) async {
    final bytes = await SvgaHttpCacheManager.instance.getData(url);
    return decodeFromBuffer(bytes);
  }

  /// Download animation file from bundle assets, and decode it.
  Future<MovieEntity> decodeFromAssets(String path) async {
    return decodeFromBuffer((await rootBundle.load(path)).buffer.asUint8List());
  }

  /// Decode animation file from local file, and decode it.
  Future<MovieEntity> decodeFromFile(File file) async {
    return decodeFromBuffer(await file.readAsBytes());
  }

  /// Download animation file from buffer, and decode it.
  Future<MovieEntity> decodeFromBuffer(List<int> bytes) {
    TimelineTask? timeline;
    if (!kReleaseMode) {
      timeline = TimelineTask(filterKey: _filterKey)
        ..start('DecodeFromBuffer', arguments: {'length': bytes.length});
    }
    final inflatedBytes = const archive.ZLibDecoder().decodeBytes(bytes);
    if (timeline != null) {
      timeline.instant('MovieEntity.fromBuffer()',
          arguments: {'inflatedLength': inflatedBytes.length});
    }
    ///解析数据生产动画对象
    final movie = MovieEntity.fromBuffer(inflatedBytes);
    movie.fileSize = bytes.length;
    if (timeline != null) {
      timeline.instant('prepareResources()',
          arguments: {'images': movie.images.keys.join(',')});
    }
    return _prepareResources(
      _processShapeItems(movie),
      timeline: timeline,
    ).whenComplete(() {
      if (timeline != null) timeline.finish();
    });
  }

  MovieEntity _processShapeItems(MovieEntity movieItem) {
    for (var sprite in movieItem.sprites) {
      List<ShapeEntity>? lastShape;
      for (var frame in sprite.frames) {
        if (frame.shapes.isNotEmpty && frame.shapes.isNotEmpty) {
          if (frame.shapes[0].type == ShapeEntity_ShapeType.KEEP &&
              lastShape != null) {
            frame.shapes = lastShape;
          } else if (frame.shapes.isNotEmpty == true) {
            lastShape = frame.shapes;
          }
        }
      }
    }
    return movieItem;
  }

  Future<MovieEntity> _prepareResources(MovieEntity movieItem,
      {TimelineTask? timeline}) {
    final images = movieItem.images;
    if (images.isEmpty) return Future.value(movieItem);
    return Future.wait(images.entries.map((item) async {
      // result null means a decoding error occurred
      var bytes = Uint8List.fromList(item.value);
      if (_isAudioData(bytes)) {
        movieItem.audioMemery += bytes.length;
        var audioPlayer = await movieItem.getAudioPlayer();
        await audioPlayer?.load(item.key, bytes);
      } else {
        final decodeImage =
            await _decodeImageItem(item.key, bytes, timeline: timeline);
        if (decodeImage != null) {
          movieItem.bitmapCache[item.key] = decodeImage;
          movieItem.spriteInfoMap[item.key] = SpriteInfo(
              name: item.key,
              width: decodeImage.width,
              height: decodeImage.height,
              memory: estimateImageMemory(decodeImage));
        }
      }
    })).then((_) => movieItem);
  }

  bool _isAudioData(Uint8List bytes) {
    //如果数据前3个byte是（73, 68, 51）则是MP3数据
    //如果数据前3个byte是（-1, -5, -108）则是wav格式数据
    if (bytes[0] == 73 && bytes[1] == 68 && bytes[2] == 51) {
      return true;
    }
    if (bytes[0] == -1 && bytes[1] == -5 && bytes[2] == -108) {
      return true;
    }
    return false;
  }

  Future<ui.Image?> _decodeImageItem(String key, Uint8List bytes,
      {TimelineTask? timeline}) async {
    TimelineTask? task;
    if (!kReleaseMode) {
      task = TimelineTask(filterKey: _filterKey, parent: timeline)
        ..start('DecodeImage', arguments: {'key': key, 'length': bytes.length});
    }
    try {
      final image = await decodeImageFromList(bytes);
      if (task != null) {
        task.finish(
          arguments: {'imageSize': '${image.width}x${image.height}'},
        );
      }
      return image;
    } catch (e, stack) {
      if (task != null) {
        task.finish(arguments: {'error': '$e', 'stack': '$stack'});
      }
      assert(() {
        FlutterError.reportError(FlutterErrorDetails(
          exception: e,
          stack: stack,
          library: 'svgaplayer',
          context: ErrorDescription('during prepare resource'),
          informationCollector: () sync* {
            yield ErrorSummary('Decoding image failed.');
          },
        ));
        return true;
      }());
      return null;
    }
  }
}
