import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:audio_session/audio_session.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart' as rec;
import 'package:im_animations/im_animations.dart';
import 'package:iris_tools/api/duration/durationFormatter.dart';
import 'package:iris_tools/api/helpers/fileHelper.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/helpers/localeHelper.dart';
import 'package:iris_tools/api/helpers/pathHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/customCard.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:app/services/file_upload_service.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/enums/fileUploadType.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/examModels/speakingModel.dart';
import 'package:app/structures/models/mediaModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_dialog_iris.dart';
import 'package:app/tools/app/app_directories.dart';
import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_sheet.dart';
import 'package:app/tools/app/app_snack.dart';
import 'package:app/tools/app/app_toast.dart';
import 'package:app/tools/permission_tools.dart';
import 'package:app/views/components/playVoiceView.dart';
import 'package:app/views/sheets/speakingCorrectAnswerSheet.dart';

class SpeakingComponent extends StatefulWidget {
  final SpeakingModel speakingModel;
  final VoidCallback onSendAnswer;

  const SpeakingComponent({
    required this.speakingModel,
    required this.onSendAnswer,
    Key? key
  }) : super(key: key);

  @override
  State<SpeakingComponent> createState() => SpeakingComponentState();
}
///=================================================================================================================
class SpeakingComponentState extends StateSuper<SpeakingComponent> {
  late SpeakingModel speakingModel;
  Requester requester = Requester();
  FlutterSoundRecorder voiceRecorder = FlutterSoundRecorder();
  Codec recorderCodec = Codec.aacMP4;
  bool recorderIsInit = false;
  bool isVoiceRecorded = false;
  StreamSubscription? _recorderSubscription;
  late String savePath;
  Duration currentRecordDuration = const Duration();
  PlayVoiceController answerPlayController = PlayVoiceController();
  Map<Codec, String> codecs = {};

  @override
  void initState(){
    super.initState();

    speakingModel = widget.speakingModel;

    final p = AppDirectories.getAppFolderInInternalStorage();
    savePath = PathHelper.resolvePath('$p/record.')!;

    answerPlayController.onPrepareEvent = onPrepareError;

    codecs[Codec.opusWebM] = 'webm';
    codecs[Codec.aacADTS] = 'aac';
    codecs[Codec.amrNB] = 'amr';
    codecs[Codec.amrWB] = 'amr';
    codecs[Codec.mp3] = 'mp3';
    codecs[Codec.opusOGG] = 'ogg';
    codecs[Codec.vorbisOGG] = 'ogg';
    codecs[Codec.flac] = 'flac';
    codecs[Codec.pcm8] = 'pcm';
    codecs[Codec.aacMP4] = 'mp4';
  }

  @override
  void dispose(){
    requester.dispose();
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
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(AppImages.doubleArrow),
              const SizedBox(width: 4),

              Expanded(child: Text(speakingModel.question?? '', maxLines: 2)),
            ],
          ),
          const SizedBox(height: 20),

          Directionality(
            textDirection: LocaleHelper.autoDirection(speakingModel.text!),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 15),
              child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: double.infinity,
                    minHeight: 50,
                  ),
                  child: Text(speakingModel.text!).englishFont().fsR(-1)),
            ).wrapDotBorder(
                color: Colors.black12,
                alpha: 100,
                dashPattern: [4,8]),
          ),

          const SizedBox(height: 30),
          const Divider(color: Colors.black26),
          const SizedBox(height: 15),

          const Align(
              alignment: Alignment.topRight,
              child: Row(
                children: [
                  SizedBox(
                    height: 15,
                    width: 2,
                    child: ColoredBox(color: Colors.black),
                  ),

                  SizedBox(width: 6),
                  Text('پاسخ شما:'),
                ],
              )
          ),
          const SizedBox(height: 15),

          buildMicReply(),

          const SizedBox(height: 20),
          buildCorrectAnswerView(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget buildMicReply(){
    if(isVoiceRecorded){
      return Directionality(
        textDirection: TextDirection.ltr,
        child: CustomCard(
          padding: const EdgeInsets.all(5),
          color: Colors.grey.shade200,
          child: Row(
            children: [
              Expanded(
                  child: PlayVoiceView(address: getVoiceAddress(), controller: answerPlayController)
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
                child: Center(child: Text(DurationFormatter.duration(currentRecordDuration, showSuffix: false)).color(Colors.white))
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

  Widget buildCorrectAnswerView(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: showAnswer,
            child: const Text('شنیدن پاسخ صحیح'),
          ),
        ),

        const SizedBox(width: 10),

        Visibility(
          visible: isVoiceRecorded,
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green
              ),
              onPressed: sendAnswer,
              child: const Text('ارسال پاسخ'),
            ),
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

    if (!await voiceRecorder.isEncoderSupported(recorderCodec)) {
      for (final c in codecs.entries) {
        recorderCodec = c.key;

        if (!await voiceRecorder.isEncoderSupported(recorderCodec)) {
          //AppToast.showToast(context, 'امکان ضبط صدا نیست. فرمت فایل پشتیبانی نمی شود.');
        }
        else {
          break;
        }
      }
    }

    _recorderSubscription = voiceRecorder.onProgress!.listen((e) {
      if( e.duration.inMilliseconds > 100) {
        currentRecordDuration = e.duration;
        assistCtr.updateHead();
      }

      /*if (e.decibels != null) {
          double dbLevel = e.decibels as double;
        }*/
    });

    recorderIsInit = true;

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
    if(!recorderIsInit){
      await initRecorder();
    }

    try {
      isVoiceRecorded = false;
      await voiceRecorder.startRecorder(codec: recorderCodec, toFile: getVoiceAddress(), audioSource: rec.AudioSource.microphone);
    }
    catch (e){
      AppToast.showToast(context, ' متاسفانه ظبط صدا موفق نبود');
    }
  }

  Future<void> stopRecorder() async {
    await voiceRecorder.stopRecorder();
    isVoiceRecorded = true;
    assistCtr.updateHead();

    /*await System.wait250();
    await answerPlayController.prepare();*/
  }

 void deleteVoice() {
    Future<bool> delFn(ctx) async {
      isVoiceRecorded = false;
      currentRecordDuration = const Duration();

      if(answerPlayController.isPlay){
        await answerPlayController.stop();
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
    final w = SpeakingCorrectAnswerSheet(speakingModel: widget.speakingModel);

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

  void onPrepareError(bool? isPrepare, Object? error) async {

    if(isPrepare == null && error == null){
      AppToast.showToast(context, 'در حال آماده سازی صوت');
      return;
    }

    if(error is PlayerException){
      if(error.toString().contains('Source error')){
        AppToast.showToast(context, 'آماده سازی صوت انجام نشد');
        return;
      }
    }
    else {
      assistCtr.updateHead();
    }
  }

  void sendAnswer() async {
    String? audioId;

    if(!isVoiceRecorded){
      AppSheet.showSheetOk(context, 'لطفا پاسخ خود را ضبط کنید');
      return;
    }

    showLoading();
    var newFile = '${File(getVoiceAddress()).parent.path}/record.mp3';

    if(FileHelper.existSync(getVoiceAddress())) {
      FileHelper.renameSync(getVoiceAddress(), newFile);
    }

    final twoResponse = await FileUploadService.uploadFiles([File(newFile)], FileUploadType.autodidact);

    if(twoResponse.hasResult2()){
      await hideLoading();
      AppSnack.showSnackText(context, AppMessages.operationFailedTryAgain);
      return;
    }
    else {
      final data = twoResponse.result1![Keys.data];

      if(data is List) {
        final media = MediaModel.fromMap(data[0]['file']);
        audioId = media.id;
      }
    }

    FocusHelper.hideKeyboardByUnFocusRoot();

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

      AppSnack.showSnackText(context, AppMessages.errorCommunicatingServer);
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      final message = res['message']?? 'پاسخ شما ثبت شد';

      AppSnack.showInfo(context, message);
      widget.onSendAnswer.call();
    };

    final js = <String, dynamic>{};
    js['speakingId'] = speakingModel.id;
    js['userAnswerVoiceId'] = audioId;

    requester.methodType = MethodType.post;
    requester.prepareUrl(pathUrl: '/speaking/solving');
    requester.bodyJson = js;

    requester.request(context);
  }

  String getVoiceAddress() {
    for(final x in codecs.entries){
      if(x.key == recorderCodec){
        return savePath + x.value;
      }
    }

    return '';
  }
}
