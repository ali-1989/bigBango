import 'package:iris_tools/models/two_state_return.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  AudioPlayerService._();

  //static late AudioPlayer _notifyPlayer;
  static late AudioPlayer _voicePlayer;
  static late AudioPlayer audioDurationGet;

  static void init(){
    audioDurationGet = AudioPlayer();
    _voicePlayer = AudioPlayer();

    //_notifyPlayer = AudioPlayer();
    //_notifyPlayer.setAsset('assets/audio/graceful.mp3', preload: true);
  }

  static AudioPlayer getPlayer() {
    return _voicePlayer;
  }

  static Future<void> stopPlayer() {
    if (_voicePlayer.playing) {
      return _voicePlayer.stop();
    }

    return Future.value();
  }

  static Future<TwoStateReturn<AudioPlayer?, Exception?>> getPlayerWithUrl(String source) async {
    try {
      if (_voicePlayer.playing) {
        await _voicePlayer.stop();
      }

      await _voicePlayer.setUrl(source);
    }
    catch(e) {
      return TwoStateReturn(r2: e as Exception);
    }

    return TwoStateReturn(r1: _voicePlayer);
  }
}