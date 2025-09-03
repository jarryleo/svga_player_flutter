import 'dart:io';

import 'package:flutter/cupertino.dart' show debugPrint;
import 'package:svga_viewer/svgaplayer/proto/svga.pb.dart';

import 'cache/memory_cache.dart';
import 'parser.dart';

/// SVGA 数据源类型枚举
enum SVGASourceType {
  url,
  asset,
  file,
}

/// SVGA 数据源类
class SVGASource {
  final String? name;
  final String source;
  final SVGASourceType type;

  /// URL 类型构造函数
  SVGASource.network(this.name, String url)
      : source = url,
        type = SVGASourceType.url;

  /// Asset 类型构造函数
  SVGASource.asset(this.name, String assetName)
      : source = assetName,
        type = SVGASourceType.asset;

  /// File 类型构造函数
  SVGASource.file(this.name, File file)
      : source = file.path,
        type = SVGASourceType.file;

  /// 判断是否为网络资源
  bool get isNetwork => type == SVGASourceType.url;

  /// 判断是否为 Asset 资源
  bool get isAsset => type == SVGASourceType.asset;

  /// 判断是否为文件资源
  bool get isFile => type == SVGASourceType.file;

  @override
  String toString() {
    return 'name: $name, type: ${type.name}, source: $source';
  }

  ///加载SVGA资源
  Future loadVideoItem({bool userMemoryCache = true}) async {
    if(userMemoryCache) {
      var cacheKey = toString();
      var cache = MovieEntityCache.instance.get(cacheKey);
      if (cache?.isRelease == false) {
        debugPrint('use memory cache : $cacheKey');
        return cache;
      } else {
        MovieEntityCache.instance.remove(cacheKey);
      }
    }
    MovieEntity? movie;
    if (type == SVGASourceType.file) {
      movie = await SVGAParser.shared.decodeFromFile(File(source));
    } else if (type == SVGASourceType.asset) {
      movie = await SVGAParser.shared.decodeFromAssets(source);
    } else {
      movie = await SVGAParser.shared.decodeFromURL(source);
    }
    if (userMemoryCache) {
      movie.autorelease = false;
      var cacheKey = toString();
      MovieEntityCache.instance.put(cacheKey, movie);
    }
    return movie;
  }
}
