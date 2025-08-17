import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  late final BytesSource source;

  // 私有构造函数
  AudioPlayerService._(this.source);

  // 工厂方法，用于创建 AudioPlayerService 实例并设置音频数据
  static Future<AudioPlayerService> init(Uint8List audioBytes) async {
    var source = BytesSource(audioBytes);
    final service = AudioPlayerService._(source);
    return service;
  }

  // 播放
  Future<void> play() async {
    await _audioPlayer.play(source);
  }

  // 停止播放
  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  // 暂停播放
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  //恢复播放
  Future<void> resume() async {
    await _audioPlayer.resume();
  }

  // 设置音量
  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
  }

  // 停止播放并释放资源
  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
