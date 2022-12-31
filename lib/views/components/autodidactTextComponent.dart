import 'dart:async';

import 'package:app/structures/enums/autodidactReplyType.dart';
import 'package:app/structures/injectors/autodidactPageInjector.dart';
import 'package:app/structures/models/autodidactModel.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/tools/app/appToast.dart';
import 'package:app/tools/permissionTools.dart';
import 'package:app/views/widgets/customCard.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:audio_session/audio_session.dart';
import 'package:im_animations/im_animations.dart';
import 'package:iris_tools/api/duration/durationFormatter.dart';
import 'package:logger/logger.dart';

import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/system/extensions.dart';

import 'package:app/structures/interfaces/examStateInterface.dart';

import 'package:permission_handler/permission_handler.dart';

class AutodidactTextComponent extends StatefulWidget {
  final AutodidactPageInjector injector;

  const AutodidactTextComponent({
    required this.injector,
    Key? key
  }) : super(key: key);

  @override
  State<AutodidactTextComponent> createState() => AutodidactTextComponentState();
}
///=================================================================================================================
class AutodidactTextComponentState extends StateBase<AutodidactTextComponent> implements ExamStateInterface {
  late AutodidactModel autodidactModel;
  FlutterSoundRecorder voiceRecorder = FlutterSoundRecorder();
  Codec recorderCodec = Codec.aacMP4;
  Duration recordTime = Duration();
  Duration playTime = Duration();
  bool voiceRecorderIsInit = false;
  bool isVoiceFileOK = false;
  StreamSubscription? _recorderSubscription;
  String? savePath;

  @override
  void initState(){
    super.initState();

    autodidactModel = widget.injector.autodidactModel;
    widget.injector.state = this;
    savePath = 'record.mp4';
  }

  @override
  void dispose(){
    cancelRecorderSubscriptions();
    voiceRecorder.closeRecorder();

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
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: [
              Row(
                children: [
                  Image.asset(AppImages.doubleArrow),
                  SizedBox(width: 4),
                  Text(autodidactModel.question?? ''),
                ],
              ),
              SizedBox(height: 20),

              Directionality(
                textDirection: TextDirection.ltr,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 15),
                  child: Text(autodidactModel.text!).englishFont().fsR(-1),
                ).wrapDotBorder(
                    color: Colors.black12,
                    alpha: 100,
                    dashPattern: [4,8]),
              ),

              SizedBox(height: 30),
              buildReply()
            ],
          ),
        ),

        ElevatedButton(
          onPressed: showAnswer,
          child: Text('نمایش پاسخ'),
        ),

        SizedBox(height: 10),
      ],
    );
  }

  Widget buildReply(){
    if(autodidactModel.replyType != AutodidactReplyType.text){
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
          minLines: 4,
          maxLines: 6,
          decoration: InputDecoration(
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

  Widget buildMicReply(){
    if(isVoiceFileOK){
      return Directionality(
        textDirection: TextDirection.ltr,
        child: CustomCard(
          padding: EdgeInsets.all(5),
          color: Colors.grey.shade300,
          child: Row(
            children: [
              CustomCard(
                radius: 50,
                padding: EdgeInsets.all(14),
                child: Image.asset(AppImages.pauseIco),
              ),

              Expanded(
                child: Slider(
                  value: 0.4,
                  onChanged: (v){},

                ),
              ),

              IconButton(
                  onPressed: deleteVoice,
                icon: Icon(AppIcons.delete),
              )
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(height: 12),

        SizedBox(
          width: 60,
          child: CustomCard(
            color: Colors.red,
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: SizedBox(
                width: 60,
                child: Center(child: Text(DurationFormatter.duration(recordTime, showSuffix: false)).color(Colors.white))
            ),
          ),
        ),

        SizedBox(height: 30),

        GestureDetector(
          onTap: toggleRecord,
          child: ColorSonar(
              contentAreaRadius: 25.0,
              waveFall: 10.0,
              waveMotionEffect: Curves.linear,
              waveMotion: WaveMotion.synced,
              innerWaveColor: voiceRecorder.isRecording? AppColors.red.withAlpha(100) : Colors.transparent,
              middleWaveColor: voiceRecorder.isRecording? AppColors.red.withAlpha(50) : Colors.transparent,
              outerWaveColor: Colors.transparent,
              duration: Duration(seconds: 2),
              child: CustomCard(
                  color: AppColors.red,
                  radius: 40,
                  padding: EdgeInsets.all(10),
                  child: Image.asset(AppImages.mic)
              )
          ),
        ),
      ],
    );
  }

  Future<void> init() async {
    if (!kIsWeb) {
      final status = await PermissionTools.requestMicPermission();
      if (status != PermissionStatus.granted) {
        //throw RecordingPermissionException('Microphone permission not granted');
        return;
      }
    }

    await voiceRecorder.openRecorder();
    voiceRecorder.setLogLevel(Level.error);
    voiceRecorder.setSubscriptionDuration(Duration(milliseconds: 250));

    _recorderSubscription = voiceRecorder.onProgress!.listen((e) {
      if( e.duration.inMilliseconds > 100) {
        recordTime = e.duration;
        assistCtr.updateHead();
      }

      /*if (e.decibels != null) {
          double dbLevel = e.decibels as double;
        }*/
    });


    if (!await voiceRecorder.isEncoderSupported(recorderCodec)) {
      recorderCodec = Codec.opusWebM;
      savePath = 'record.WebM';

      if (!await voiceRecorder.isEncoderSupported(recorderCodec)) {
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
      await init();
    }

    try{
      await voiceRecorder.startRecorder(codec: recorderCodec, toFile: savePath, audioSource: AudioSource.microphone);
      isVoiceFileOK = false;
    }
    catch (e){
      AppToast.showToast(context, 'متاسفانه امکان ظبط صدا نیست');
    }
  }

  Future<void> stopRecorder() async {
    await voiceRecorder.stopRecorder();
    isVoiceFileOK = true;
  }

 void deleteVoice() {
    isVoiceFileOK = false;
    recordTime = Duration();

    assistCtr.updateHead();
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
              Text('پاسخ استاد').bold().fsR(4),
              SizedBox(height: 25),
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

              SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: (){
                      AppRoute.popTopView(context);
                    },
                    child: Text('بستن')
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

  @override
  bool isAllAnswer(){
    return true;
  }

  @override
  void checkAnswers() {
  }
}


