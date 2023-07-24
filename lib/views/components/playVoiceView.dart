import 'package:app/tools/app/appImages.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/widgets/customCard.dart';
import 'package:just_audio/just_audio.dart';

typedef OnPlayState = void Function(bool isPlaying);
typedef OnDurationChange = void Function(Duration duration);
typedef OnPrepareEvent = void Function(bool? isPrepare, Object? error);
///==================================================================================
class PlayVoiceView extends StatefulWidget {
  final String address;
  final PlayVoiceController controller;
  final double buttonSize;
  final EdgeInsets buttonPadding;
  final bool isUrl;

  const PlayVoiceView({
    required this.address,
    required this.controller,
    this.buttonPadding = const EdgeInsets.all(14),
    this.buttonSize = 12,
    this.isUrl = false,
    Key? key,
  }) : super(key: key);

  @override
  State<PlayVoiceView> createState() => _PlayVoiceViewState();
}
///==================================================================================
class _PlayVoiceViewState extends State<PlayVoiceView> {
  AudioPlayer player = AudioPlayer();
  Duration totalTime = const Duration();
  Duration currentTime = const Duration();
  bool voiceIsPrepare = false;

  @override
  void initState(){
    super.initState();

    widget.controller._setState(this);

    player.positionStream.listen((event) async {
      currentTime = event;
      widget.controller.onDurationChange?.call(event);

      if(currentTime.inMilliseconds >= totalTime.inMilliseconds){
        await player.stop();
      }

      if(mounted){
        setState(() {});
      }
    });

    player.playerStateStream.listen((event) {
      widget.controller.onPlayState?.call(event.playing);

      if(mounted){
        setState(() {});
      }
    });
  }


  @override
  void dispose(){
    try {
      player.dispose();
    }
    catch (e){/**/}

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: playPauseClick,
          child: CustomCard(
            radius: 30,
            padding: widget.buttonPadding,
            child: Image.asset(player.playing? AppImages.pauseIco : AppImages.playIco, width: widget.buttonSize, height: widget.buttonSize),
          ),
        ),

        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              thumbShape: CustomThumb(),
              valueIndicatorShape: CustomThumb(),
              valueIndicatorColor: Colors.transparent,
              overlayColor: Colors.transparent,
            ),
            child: Slider(
              value: percentOfVoiceForSlider(),
              onChanged: (v){
                var x = v * 100;
                x = x * totalTime.inMilliseconds / 100;

                player.seek(Duration(milliseconds: x.toInt()));
                setState(() {});
              },
            ),
          ),
        ),
      ],
    );
  }

  void playPauseClick() async {
    if(!voiceIsPrepare){
      await prepareVoice();
    }

    if(isPlaying()){
      await player.pause();
    }
    else {
      if(player.position.inMilliseconds < totalTime.inMilliseconds) {
        await player.play();
      }
      else {
        await player.pause();
        await player.seek(const Duration());
        await player.play();
      }
    }
  }

  bool isPlaying() {
    return player.playing && player.position.inMilliseconds < totalTime.inMilliseconds;
  }

  Future<void> prepareVoice() async {
    voiceIsPrepare = false;
    widget.controller.onPrepareEvent?.call(null, null);

    Future fut;

    if(widget.isUrl) {
      fut = player.setUrl(widget.address);
    }
    else {
      fut = player.setFilePath(widget.address);
    }

    return fut.then((dur) {
      voiceIsPrepare = true;

      if(dur != null){
        totalTime = dur;
      }

      widget.controller.onPrepareEvent?.call(true, null);

    }).onError((error, stackTrace) {
      widget.controller.onPrepareEvent?.call(false, error);
    });
  }

  double percentOfVoiceForSlider() {
    if(currentTime.inMilliseconds <= 0 || totalTime.inMilliseconds <= 0){
      return 0;
    }

    var x = currentTime.inMilliseconds * 100 / totalTime.inMilliseconds;

    if(x > 100){
      x = 100;
    }

    return x/100;
  }
}
///========================================================================================
class PlayVoiceController {
  late _PlayVoiceViewState _state;

  OnPlayState? onPlayState;
  OnDurationChange? onDurationChange;
  OnPrepareEvent? onPrepareEvent;

  Duration get totalTime => _state.totalTime;
  Duration get currentTime => _state.currentTime;
  bool get isPlay => _state.isPlaying();

  void _setState(_PlayVoiceViewState state) {
    _state = state;
  }

  void pause(){
    _state.player.pause();
  }

  Future prepare(){
    return _state.prepareVoice();
  }

  Future play(){
    return _state.player.play();
  }

  Future stop(){
    return _state.player.stop();
  }

  void seek(Duration duration){
    _state.player.seek(duration);
  }
}
///========================================================================================
class CustomThumb extends SliderComponentShape {

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(7, 7);
  }

  @override
  void paint(PaintingContext context, Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow}) {

    final canvas = context.canvas;
    final paint = Paint()..color = sliderTheme.thumbColor?? Colors.pink;

    //canvas.drawRect(Rect.fromLTWH(center.dx-2, center.dy-8, 4, 16), paint);
    canvas.drawCircle(Offset(center.dx-2, center.dy), 7, paint);
  }
}