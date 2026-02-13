import 'package:audioplayers/audioplayers.dart';
import 'package:injectable/injectable.dart';
import '../utils/app_logger.dart';

@lazySingleton
class AudioManager {
  final AudioPlayer _player = AudioPlayer();
  
  // 暂时禁用音效，直到 assets/audio/ 资源文件被添加
  // set to true when assets are available
  final bool _areAssetsAvailable = false; 

  // Preload commonly used sounds if needed (AudioPlayers usually handles this well on demand for local assets)
  // Assets should be placed in assets/audio/

  Future<void> playCorrect() async {
    if (!_areAssetsAvailable) return;
    await _stopAndPlay('audio/sfx_correct.mp3'); 
  }

  Future<void> playWrong() async {
    if (!_areAssetsAvailable) return;
     await _stopAndPlay('audio/sfx_wrong.mp3');
  }

  Future<void> playLevelUp() async {
    if (!_areAssetsAvailable) return;
     await _stopAndPlay('audio/sfx_levelup.mp3');
  }

  Future<void> playButtonTap() async {
    if (!_areAssetsAvailable) return;
    await _stopAndPlay('audio/sfx_tap.mp3');
  }

  Future<void> _stopAndPlay(String path) async {
    try {
      await _player.stop();
      await _player.setSource(AssetSource(path));
      await _player.resume();
    } catch (e) {
      // Ignore audio errors in production to not crash app
      AppLogger.w('Audio Error: File not found or play failed ($path)', error: e);
    }
  }
}
