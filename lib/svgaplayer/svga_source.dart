import 'dart:io';

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
}

Future loadVideoItem(SVGASource source) {
  if (source.type == SVGASourceType.file) {
    return SVGAParser.shared.decodeFromFile(File(source.source));
  } else if (source.type == SVGASourceType.asset) {
    return SVGAParser.shared.decodeFromAssets(source.source);
  } else {
    return SVGAParser.shared.decodeFromURL(source.source);
  }
}