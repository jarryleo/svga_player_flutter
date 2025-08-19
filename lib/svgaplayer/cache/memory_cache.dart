import 'dart:collection';

import '../proto/svga.pb.dart';

/// MovieEntity内存缓存工具类
class MovieEntityCache {
  /// 单例实例
  static final MovieEntityCache _instance = MovieEntityCache._internal();
  factory MovieEntityCache() => _instance;
  MovieEntityCache._internal();

  static MovieEntityCache instance = _instance;

  /// 默认最大缓存数量
  static const int _defaultMaxSize = 10;

  /// 最大缓存数量
  int _maxSize = _defaultMaxSize;

  /// LRU缓存映射
  final Map<String, MovieEntity> _cache = <String, MovieEntity>{};

  /// 访问顺序记录队列（用于实现LRU算法）
  final Queue<String> _accessQueue = Queue<String>();

  /// 获取最大缓存数量
  int get maxSize => _maxSize;

  /// 设置最大缓存数量
  set maxSize(int size) {
    if (size <= 0) {
      throw ArgumentError.value(size, 'size', 'Max size must be greater than 0');
    }
    _maxSize = size;
    // 如果新大小小于当前缓存数量，则移除多余的项
    _evictIfNeeded();
  }

  /// 获取缓存中的MovieEntity对象
  MovieEntity? get(String key) {
    if (_cache.containsKey(key)) {
      // 更新访问顺序（LRU）
      _accessQueue.remove(key);
      _accessQueue.addLast(key);
      return _cache[key];
    }
    return null;
  }

  /// 将MovieEntity对象放入缓存
  void put(String key, MovieEntity entity) {
    // 如果已经存在，先移除旧记录
    if (_cache.containsKey(key)) {
      _cache.remove(key);
      _accessQueue.remove(key);
    }

    // 添加新记录
    _cache[key] = entity;
    _accessQueue.addLast(key);

    // 检查是否需要移除旧记录
    _evictIfNeeded();
  }

  /// 从缓存中移除指定key的对象
  MovieEntity? remove(String key) {
    _accessQueue.remove(key);
    return _cache.remove(key);
  }

  /// 检查缓存是否包含指定key
  bool containsKey(String key) {
    return _cache.containsKey(key);
  }

  /// 获取缓存大小
  int get size => _cache.length;

  /// 清空缓存
  void clear() {
    _cache.clear();
    _accessQueue.clear();
  }

  /// 根据LRU策略移除多余项
  void _evictIfNeeded() {
    while (_cache.length > _maxSize) {
      if (_accessQueue.isNotEmpty) {
        final keyToRemove = _accessQueue.removeFirst();
        _cache.remove(keyToRemove);
      }
    }
  }
}
