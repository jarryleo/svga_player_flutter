
import 'dart:io';
import 'dart:typed_data' show Uint8List;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class HttpCacheManager {
  static final HttpCacheManager _instance = HttpCacheManager._internal();

  factory HttpCacheManager() => _instance;

  HttpCacheManager._internal();

  // 添加最大缓存大小限制（字节），默认200MB
  int _maxCacheSize = 200 * 1024 * 1024;

  // 添加缓存大小属性
  int _currentCacheSize = 0;

  /// 设置最大缓存大小（字节）
  void setMaxCacheSize(int maxSize) {
    _maxCacheSize = maxSize;
  }

  /// 获取当前缓存大小
  Future<int> getCurrentCacheSize() async {
    if (kIsWeb) return 0;

    final cacheDir = await _getCacheDirectory();
    final dir = Directory(cacheDir);

    if (!await dir.exists()) return 0;

    int size = 0;
    await for (FileSystemEntity entity in dir.list(recursive: true)) {
      if (entity is File) {
        size += await entity.length();
      }
    }
    _currentCacheSize = size;
    return size;
  }

  /// 清除所有缓存
  Future<void> clearCache() async {
    if (kIsWeb) return;

    final cacheDir = await _getCacheDirectory();
    final dir = Directory(cacheDir);

    if (await dir.exists()) {
      await dir.delete(recursive: true);
      _currentCacheSize = 0;
    }
  }

  /// 清除过期缓存文件
  Future<void> clearExpiredCache() async {
    if (kIsWeb) return;

    final cacheDir = await _getCacheDirectory();
    final dir = Directory(cacheDir);

    if (!await dir.exists()) return;

    // 缓存有效期1小时(3600秒)
    final expireDuration = Duration(hours: 1);
    final now = DateTime.now();

    await for (FileSystemEntity entity in dir.list()) {
      if (entity is File) {
        final lastModified = await entity.lastModified();
        if (now.difference(lastModified) > expireDuration) {
          await entity.delete();
        }
      }
    }
  }

  Future<String> _getCacheDirectory() async {
    final directory = await getTemporaryDirectory();
    return '${directory.path}/http_cache';
  }

  Future<http.Response> getCachedResponse(String url) async {
    final client = http.Client();

    final request = http.Request('GET', Uri.parse(url));
    // 设置缓存控制头
    request.headers['Cache-Control'] = 'max-age=3600'; // 缓存1小时
    request.headers['Accept-Encoding'] = 'gzip, deflate';

    final response = await client.send(request);
    return http.Response.fromStream(response);
  }

  Future<Uint8List> getData(String url) async {
    if (kIsWeb) {
      final response = await getCachedResponse(url);
      return response.bodyBytes;
    }
    //检查缓存
    final cacheDir = await _getCacheDirectory();
    final fileName = _getFileNameFromUrl(url);
    final file = File('$cacheDir/$fileName');
    if (await file.exists()) {
      return file.readAsBytes();
    }
    return _downloadAndCache(url);
  }

  String _getFileNameFromUrl(String url) {
    return url.hashCode.toString();
  }

  Future<Uint8List> _downloadAndCache(String url) async {
    // 下载文件
    final response = await getCachedResponse(url);
    if (response.statusCode == 200) {
      // 异步保存到缓存
      _getCacheDirectory().then((dir) async {
        await Directory(dir).create(recursive: true);
        final fileName = _getFileNameFromUrl(url);
        final file = File('$dir/$fileName');
        file.writeAsBytes(response.bodyBytes);

        // 检查并管理缓存大小
        await _manageCacheSize(dir);
      });
      return response.bodyBytes;
    } else {
      throw Exception('Failed to download file');
    }
  }

  /// 管理缓存大小，当超过限制时清除旧文件
  Future<void> _manageCacheSize(String cacheDirPath) async {
    if (kIsWeb) return;

    final dir = Directory(cacheDirPath);
    if (!await dir.exists()) return;

    // 获取当前缓存大小
    int currentSize = 0;
    final filesWithModified = <FileWithModified>[];

    await for (FileSystemEntity entity in dir.list()) {
      if (entity is File) {
        final length = await entity.length();
        currentSize += length;
        filesWithModified.add(FileWithModified(
            file: entity,
            lastModified: await entity.lastModified(),
            size: length
        ));
      }
    }

    // 如果缓存大小超过限制，删除最旧的文件
    if (currentSize > _maxCacheSize) {
      // 按修改时间排序，最旧的在前
      filesWithModified.sort((a, b) => a.lastModified.compareTo(b.lastModified));

      int deletedSize = 0;
      for (final fileWithModified in filesWithModified) {
        if (currentSize - deletedSize <= _maxCacheSize * 0.8) { // 保留一些余量
          break;
        }

        try {
          await fileWithModified.file.delete();
          deletedSize += fileWithModified.size;
        } catch (e) {
          // 删除失败，忽略错误
        }
      }
    }
  }
}

/// 用于存储文件和其修改时间的辅助类
class FileWithModified {
  final File file;
  final DateTime lastModified;
  final int size;

  FileWithModified({
    required this.file,
    required this.lastModified,
    required this.size,
  });
}