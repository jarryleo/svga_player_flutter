import 'dart:typed_data';
import 'package:flutter/cupertino.dart' show debugPrint;
import 'package:flutter_soloud/flutter_soloud.dart';


class AudioPlayerService {
  final _audioPlayer = SoLoud.instance;
  final _sourceMap = <String, AudioSource>{};
  final _soundHandle = <String, SoundHandle>{};

  // 私有构造函数
  AudioPlayerService._();

  // 工厂方法，用于创建 AudioPlayerService 实例并设置音频数据
  static Future<AudioPlayerService> init({double defaultVolume = 0.3}) async {
    final service = AudioPlayerService._();
    await service._audioPlayer.init();
    double volume = defaultVolume.clamp(0, 1);
    service._audioPlayer.setGlobalVolume(volume);
    return service;
  }

  Future<void> load(String key, Uint8List audioBytes) async {
    _sourceMap[key] = await _audioPlayer.loadMem(key, audioBytes);
  }

  // 播放
  Future<void> play(String key) async {
    var handle = _soundHandle[key];
    if (handle != null) {
      try {
        if (_audioPlayer.getIsValidVoiceHandle(handle)) {
          await stop(key);
        }
        var sound = _sourceMap[key];
        if (sound == null) {
          return;
        }
        debugPrint("replay $key");
        _soundHandle[key] = await _audioPlayer.play(sound);
      } catch (e) {
        debugPrint(e.toString());
      }
      return;
    }
    var sound = _sourceMap[key];
    if (sound == null) {
      return;
    }
    debugPrint("play $key");
    _soundHandle[key] = await _audioPlayer.play(sound);
  }

  bool isPlaying(String key) {
    var handle = _soundHandle[key];
    if (handle == null) {
      return false;
    }
    return _audioPlayer.getIsValidVoiceHandle(handle) &&
        _audioPlayer.getPause(handle) == false;
  }

  bool isPause(String key) {
    var handle = _soundHandle[key];
    if (handle == null) {
      return false;
    }
    return _audioPlayer.getPause(handle) == true;
  }

  Duration getPosition(String key) {
    var handle = _soundHandle[key];
    if (handle == null) {
      return Duration.zero;
    }
    return _audioPlayer.getPosition(handle);
  }

  void playOnSeek(String key, Duration position) {
    try {
      seek(key, position).then((_) {
        resume(key);
      });
      debugPrint("playOnSeek: $position");
    } catch (e) {
      debugPrint(e.toString());
      stop(key).then((_) async {
        var sound = _sourceMap[key];
        if (sound == null) {
          return;
        }
        _soundHandle[key] = await _audioPlayer.play(sound);
      });
    }
  }

  //seek
  Future<void> seek(String key, Duration position) async {
    var handle = _soundHandle[key];
    if (handle == null) {
      return;
    }
    _audioPlayer.seek(handle, position);
  }

  // 停止播放
  Future<void> stop(String key) async {
    var handle = _soundHandle[key];
    if (handle == null) {
      return;
    }
    debugPrint('stop play $key');
    _soundHandle.remove(key);
    await _audioPlayer.stop(handle);
  }

  // 停止所有播放
  Future<void> stopAll() async {
    _soundHandle.values.forEach((handle) {
      _audioPlayer.stop(handle);
    });
  }

  // 暂停播放
  Future<void> pause(String key) async {
    var handle = _soundHandle[key];
    if (handle == null) {
      return;
    }
    _audioPlayer.setPause(handle, true);
  }

  //暂停所有播放
  Future<void> pauseAll() async {
    _soundHandle.values.forEach((handle) async {
      _audioPlayer.setPause(handle, true);
    });
  }

  //恢复播放
  Future<void> resume(String key) async {
    var handle = _soundHandle[key];
    if (handle == null) {
      return;
    }
    _audioPlayer.setPause(handle, false);
  }

  //恢复所有播放
  Future<void> resumeAll() async {
    _soundHandle.values.forEach((handle) async {
      _audioPlayer.setPause(handle, false);
    });
  }

  // 设置音量
  Future<void> setVolume(String key, double volume) async {
    var handle = _soundHandle[key];
    if (handle == null) {
      return;
    }
    double v = volume.clamp(0, 1);
    _audioPlayer.setVolume(handle, v);
  }

  Future<void> setAllVolume(double volume) async {
    double v = volume.clamp(0, 1);
    try {
      _audioPlayer.setGlobalVolume(v);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  double getAllVolume() {
    return _audioPlayer.getGlobalVolume();
  }

  // 停止播放并释放资源
  Future<void> dispose(String key) async {
    var sound = _sourceMap[key];
    if (sound == null) {
      return;
    }
    _sourceMap.remove(key);
    _soundHandle.remove(key);
    await _audioPlayer.disposeSource(sound);
  }

  // 停止播放并释放所有资源
  Future<void> disposeAll() async {
    _soundHandle.clear();
    _soundHandle.clear();
    await _audioPlayer.disposeAllSources();
  }
}
