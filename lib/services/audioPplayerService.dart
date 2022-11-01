import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  AudioPlayerService._();

  static late AudioPlayer _notifyPlayer;
  static late AudioPlayer _voicePlayer;
  static late AudioPlayer audioDurationGet;

  static void init(){
    audioDurationGet = AudioPlayer();
    _voicePlayer = AudioPlayer();

    //_notifyPlayer = AudioPlayer();
    //_notifyPlayer.setAsset('assets/audio/graceful.mp3', preload: true);
  }

  static AudioPlayer getAudioPlayer() {
    return _voicePlayer;
  }

  static Future playNotificationForce() async {
    if(!_notifyPlayer.playing){
      return _notifyPlayer.play().then((value) async {
        await _notifyPlayer.stop();
        return _notifyPlayer.seek(Duration());
      });
    }
  }

  static Future<AudioPlayer> networkVoicePlayer(String source) async {
    if(_voicePlayer.playing){
      await _voicePlayer.stop();
    }

    await _voicePlayer.setUrl(source);
    return _voicePlayer;
  }
}