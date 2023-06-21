import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:audio_session/audio_session.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart' as rec;
import 'package:im_animations/im_animations.dart';
import 'package:iris_tools/api/duration/durationFormatter.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/helpers/pathHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/customCard.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/enums/autodidactReplyType.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/examModels/autodidactModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appDecoration.dart';
import 'package:app/tools/app/appDialogIris.dart';
import 'package:app/tools/app/appDirectories.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/tools/app/appSnack.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/tools/app/appToast.dart';
import 'package:app/tools/permissionTools.dart';
import 'package:app/tools/routeTools.dart';

class AutodidactTextComponent extends StatefulWidget {
  final AutodidactModel model;
  final VoidCallback onSendAnswer;

  const AutodidactTextComponent({
    required this.model,
    required this.onSendAnswer,
    Key? key
  }) : super(key: key);

  @override
  State<AutodidactTextComponent> createState() => AutodidactTextComponentState();
}
///=================================================================================================================
class AutodidactTextComponentState extends StateBase<AutodidactTextComponent> {
  late AutodidactModel autodidactModel;
  Requester requester = Requester();
  FlutterSoundRecorder voiceRecorder = FlutterSoundRecorder();
  TextEditingController answerCtr = TextEditingController();
  Codec recorderCodec = Codec.aacMP4;
  bool voiceRecorderIsInit = false;
  bool isVoiceFileOK = false;
  StreamSubscription? _recorderSubscription;
  late String savePath;
  AudioPlayer answerPlayer = AudioPlayer();
  Duration recordTotalTime = const Duration();
  Duration recordPlayCurrentTime = const Duration();
  Duration recordDuration = const Duration();
  bool answerVoiceIsPrepare = false;

  @override
  void initState(){
    super.initState();

    autodidactModel = widget.model;

    final p = AppDirectories.getAppFolderInInternalStorage();
    savePath = PathHelper.resolvePath('$p/record.mp4')!;

    answerPlayer.playbackEventStream.listen(eventListener);
    answerPlayer.positionStream.listen(answerDurationListener);
  }

  @override
  void dispose(){
    requester.dispose();
    answerCtr.dispose();
    cancelRecorderSubscriptions();
    voiceRecorder.closeRecorder();

    try {
      answerPlayer.dispose();
    }
    catch (e){/**/}

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
        builder: (ctx, ctr, data){
          return buildBody();
        }
    );
  }

  Widget buildBody(){
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(AppImages.doubleArrow),
              const SizedBox(width: 4),
              Text(autodidactModel.question?? ''),
            ],
          ),
          const SizedBox(height: 20),

          Directionality(
            textDirection: TextDirection.ltr,
            child: ColoredBox(
              color: Colors.grey.shade200,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 15),
                child: Text(autodidactModel.text!).englishFont().fsR(-1),
              ).wrapDotBorder(
                  color: Colors.black12,
                  alpha: 100,
                  dashPattern: [4,8]),
            ),
          ),

          const SizedBox(height: 30),
          const Align(
            alignment: Alignment.topRight,
              child: Text('پاسخ:')
          ),
          const SizedBox(height: 8),

          buildReply(),

          const SizedBox(height: 20),
          buildCorrectAnswerView(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget buildReply(){
    if(autodidactModel.replyType == AutodidactReplyType.text){
      return buildTextReply();
    }

    return buildMicReply();
  }

  Widget buildTextReply(){
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: answerCtr,
          minLines: 4,
          maxLines: 6,
          decoration: const InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
      ).wrapDotBorder(
          color: Colors.black,
          alpha: 100,
          dashPattern: [4,8]
      ),
    );
  }

  Widget buildCorrectAnswerView(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton(
          onPressed: showAnswer,
          child: const Text('نمایش پاسخ صحیح'),
        ),

        const SizedBox(width: 10),

        SizedBox(
          width: 120,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green
            ),
            onPressed: sendAnswer,
            child: const Text('ارسال پاسخ'),
          ),
        ),
      ],
    );
  }

  Widget buildMicReply(){
    if(isVoiceFileOK){
      return Directionality(
        textDirection: TextDirection.ltr,
        child: CustomCard(
          padding: const EdgeInsets.all(5),
          color: Colors.grey.shade300,
          child: Row(
            children: [
              GestureDetector(
                onTap: playPauseAnswerVoice,
                child: CustomCard(
                  radius: 50,
                  padding: const EdgeInsets.all(14),
                  child: Image.asset(answerPlayer.playing? AppImages.pauseIco : AppImages.playIco, width: 16, height: 16),
                ),
              ),

              Expanded(
                child: SliderTheme(
                  data: SliderThemeData.fromPrimaryColors(
                    primaryColor: AppThemes.instance.currentTheme.primaryColor,
                    primaryColorDark: AppThemes.instance.currentTheme.primaryColor,
                    primaryColorLight: AppThemes.instance.currentTheme.primaryColor,
                    valueIndicatorTextStyle: const TextStyle(),
                  ).copyWith(),
                  child: Slider(
                    value: percentOfRecordVoice(),
                    onChanged: (v){
                      var x = v * 100;
                      x = x * recordTotalTime.inMilliseconds / 100;

                      answerPlayer.seek(Duration(milliseconds: x.toInt()));
                    },
                  ),
                ),
              ),

              IconButton(
                  onPressed: deleteVoice,
                icon: const Icon(AppIcons.delete, color:Colors.red),
              )
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 12),

        SizedBox(
          width: 60,
          child: CustomCard(
            color: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: SizedBox(
                width: 60,
                child: Center(child: Text(DurationFormatter.duration(recordDuration, showSuffix: false)).color(Colors.white))
            ),
          ),
        ),

        const SizedBox(height: 25),

        GestureDetector(
          onTap: toggleRecord,
          child: ColorSonar(
              contentAreaRadius: 20.0,
              waveFall: 10.0,
              waveMotionEffect: Curves.linear,
              waveMotion: WaveMotion.synced,
              innerWaveColor: voiceRecorder.isRecording? AppDecoration.red.withAlpha(100) : Colors.transparent,
              middleWaveColor: voiceRecorder.isRecording? AppDecoration.red.withAlpha(50) : Colors.transparent,
              outerWaveColor: Colors.transparent,
              duration: const Duration(seconds: 2),
              child: CustomCard(
                  color: AppDecoration.red,
                  radius: 40,
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(AppImages.mic, width: 22, height: 22)
              )
          ),
        ),
      ],
    );
  }

  Future<void> initRecorder() async {
    if (!kIsWeb) {
      final status = await PermissionTools.requestMicPermission();
      if (status != PermissionStatus.granted) {
        AppToast.showToast(context, 'امکان ضبط صدا نیست');
        return;
      }
    }

    voiceRecorder.setLogLevel(Level.nothing);
    await voiceRecorder.openRecorder();

    voiceRecorder.setSubscriptionDuration(const Duration(milliseconds: 500));

    _recorderSubscription = voiceRecorder.onProgress!.listen((e) {
      if( e.duration.inMilliseconds > 100) {
        recordDuration = e.duration;
        assistCtr.updateHead();
      }

      /*if (e.decibels != null) {
          double dbLevel = e.decibels as double;
        }*/
    });


    if (!await voiceRecorder.isEncoderSupported(recorderCodec)) {
      recorderCodec = Codec.opusWebM;
      final p = AppDirectories.getAppFolderInInternalStorage();
      savePath = PathHelper.resolvePath('$p/record.WebM')!;

      if (!await voiceRecorder.isEncoderSupported(recorderCodec)) {
        AppToast.showToast(context, 'امکان ضبط صدا نیست. فرمت فایل پشتیبانی نمی شود.');
        return;
      }
    }

    voiceRecorderIsInit = true;

    if(!kIsWeb){
      final sessionConfiguration = AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.allowBluetooth | AVAudioSessionCategoryOptions.defaultToSpeaker,
        avAudioSessionMode: AVAudioSessionMode.spokenAudio,
        avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: const AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.voiceCommunication,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: true,
      );

      final session = await AudioSession.instance;
      await session.configure(sessionConfiguration);
    }
  }

  void toggleRecord() async {
    if(voiceRecorder.isRecording){
      await stopRecorder();
    }
    else {
      await startRecord();
    }

    assistCtr.updateHead();
  }

  Future<void> startRecord() async {
    if(!voiceRecorderIsInit){
      await initRecorder();
    }

    try {
      isVoiceFileOK = false;
      await voiceRecorder.startRecorder(codec: recorderCodec, toFile: savePath, audioSource: rec.AudioSource.microphone);
    }
    catch (e){
      AppToast.showToast(context, 'متاسفانه ظبط صدا موفق نبود');
    }
  }

  Future<void> stopRecorder() async {
    await voiceRecorder.stopRecorder();
    isVoiceFileOK = true;

    await prepareAnswerVoice();
  }

 void deleteVoice() {
    Future<bool> delFn(ctx) async {
      isVoiceFileOK = false;
      recordDuration = const Duration();

      if(answerPlayer.playing){
        await answerPlayer.stop();
      }

      assistCtr.updateHead();
      return false;
    }

    AppDialogIris.instance.showYesNoDialog(
        context,
      yesFn: delFn,
      desc: 'آیا ویس شما دور انداخته شود؟'
    );
  }

  void cancelRecorderSubscriptions() {
    if (_recorderSubscription != null) {
      _recorderSubscription!.cancel();
      _recorderSubscription = null;
    }
  }

  void showAnswer(){
    final w = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: CustomCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            children: [
              const Text('پاسخ صحیح').bold().fsR(4),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      autodidactModel.correctAnswer?? '',
                    ).englishFont(),
                  ),
                ),
              ).wrapDotBorder(
                  color: Colors.black,
                  alpha: 100,
                  dashPattern: [4,8]
              ),

              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: (){
                      RouteTools.popTopView(context: context);
                    },
                    child: const Text('بستن')
                ),
              ),
            ],
          ),
        ),
      ),
    );

    AppSheet.showSheetCustom(
        context,
        builder: (ctx){
          return w;
        },
        routeName: 'showAnswer',
      contentColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  void playPauseAnswerVoice() async {
    if(!answerVoiceIsPrepare){
      AppToast.showToast(context, 'در حال آماده سازی صوت');
      await prepareAnswerVoice();
    }

    if(isAnswerPlaying()){
      await answerPlayer.pause();
    }
    else {
      if(answerPlayer.position.inMilliseconds < recordTotalTime.inMilliseconds) {
        await answerPlayer.play();
      }
      else {
        await answerPlayer.pause();
        await answerPlayer.seek(const Duration());
        await answerPlayer.play();
      }
    }
  }

  double percentOfRecordVoice() {
    if(recordPlayCurrentTime.inMilliseconds <= 0 || recordTotalTime.inMilliseconds <= 0){
      return 0;
    }

    var x = recordPlayCurrentTime.inMilliseconds * 100 / recordTotalTime.inMilliseconds;

    if(x > 100){
      x = 100;
    }

    return x/100;
  }

  bool isAnswerPlaying() {
    return answerPlayer.playing && answerPlayer.position.inMilliseconds < recordTotalTime.inMilliseconds;
  }

  void answerDurationListener(Duration pos) async {
    recordPlayCurrentTime = pos;

    if(recordPlayCurrentTime.inMilliseconds >= recordTotalTime.inMilliseconds){
      await answerPlayer.stop();
    }

    assistCtr.updateHead();
  }

  void eventListener(PlaybackEvent event){
    assistCtr.updateHead();
  }

  Future<void> prepareAnswerVoice() async {
    answerVoiceIsPrepare = false;

    return answerPlayer.setFilePath(savePath).then((dur) {
      answerVoiceIsPrepare = true;

      if(dur != null){
        recordTotalTime = dur;
      }

    }).onError((error, stackTrace) {
      if(error is PlayerException){
        if(error.toString().contains('Source error')){
          AppToast.showToast(context, 'آماده سازی صوت انجام نشد');
          return;
        }
      }
    });
  }

  void sendAnswer() async {
    if(autodidactModel.replyType == AutodidactReplyType.text){
      if(answerCtr.text.trim().isEmpty){
        AppSheet.showSheetOk(context, 'لطفا پاسخ خود را بنویسید');
        return;
      }
    }

    await FocusHelper.hideKeyboardByUnFocusRootWait();

    requester.httpRequestEvents.onAnyState = (req) async {
      await hideLoading();
    };

    requester.httpRequestEvents.onFailState = (req, res) async {
      if(res?.data != null){
        final map = JsonHelper.jsonToMap(res?.data)!;

        final message = map['message'];

        if(message != null){
          AppSnack.showInfo(context, message);
          return;
        }
      }

      AppSnack.showSnack$errorCommunicatingServer(context);
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      final message = res['message']?? 'پاسخ شما ثبت شد';

      AppSnack.showInfo(context, message);
      widget.onSendAnswer.call();
    };

    final js = <String, dynamic>{};
    js['autodidactId'] = autodidactModel.id;

    if(autodidactModel.replyType == AutodidactReplyType.text){
      js['text'] = answerCtr.text.trim();
    }
    else {
      js['voiceId'] = '';
    }

    requester.methodType = MethodType.post;
    requester.prepareUrl(pathUrl: '/autodidact/solving');
    requester.bodyJson = js;

    showLoading();
    requester.request(context);
  }
}


