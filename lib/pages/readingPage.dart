import 'dart:async';
import 'dart:math';

import 'package:app/models/abstract/stateBase.dart';
import 'package:app/models/lessonModels/lessonModel.dart';
import 'package:app/models/lessonModels/readingModel.dart';
import 'package:app/system/requester.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/views/components/appbarLesson.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:app/views/states/waitToLoad.dart';
import 'package:flutter/material.dart';
import 'package:iris_audio_visualizer/audio_visualizer.dart';
import 'package:iris_audio_visualizer/visualizers/visualizer.dart';
import 'package:iris_tools/api/managers/assetManager.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

class ReadingPageInjector {
  late LessonModel lessonModel;
  late ReadingModel segment;
}
///-----------------------------------------------------
class ReadingPage extends StatefulWidget {
  final ReadingPageInjector injector;

  const ReadingPage({
    required this.injector,
    Key? key
  }) : super(key: key);

  @override
  State<ReadingPage> createState() => _ReadingPageState();
}
///======================================================================================================================
class _ReadingPageState extends StateBase<ReadingPage> {
  Requester requester = Requester();
  StreamController? audioFFT = StreamController<List<double>>();
  List<double> values = [];

  @override
  void initState(){
    super.initState();

    var rng =  Random();
    for (var i = 0; i < 100; i++) {
      values.add(rng.nextInt(70) * 1.0);
    }

    assistCtr.addState(AssistController.state$loading);
    requestReading();
  }

  @override
  void dispose(){
    requester.dispose();

    //AudioPlayerService.getAudioPlayer().stop();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
        builder: (ctx, ctr, data){
          return Scaffold(
            body: SafeArea(
                child: buildBody()
            ),
          );
        }
    );
  }

  Widget buildBody(){
    if(assistCtr.hasState(AssistController.state$error)){
      return ErrorOccur(onRefresh: onRefresh);
    }

    if(assistCtr.hasState(AssistController.state$loading)){
      return WaitToLoad();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(height: 20),
          AppbarLesson(title: widget.injector.segment.title),
          SizedBox(height: 14),

          DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(15)
              ),
            child: Center(
              child: GestureDetector(
                onTap: (){toWave();},
                  child: Text('Reading').color(Colors.white)
              ),
            ),
          ),

          SizedBox(height: 20),

          Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              width: sw,
              child: DecoratedBox(
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'ali ali ali\n ali ali'
                  , style: TextStyle(height: 1.7)
                  ).englishFont(),
                ).wrapDotBorder(
                  padding: EdgeInsets.zero,
                  color: Colors.black12,
                  alpha: 120,
                  radius: 6,
                  dashPattern: [5, 7]
                ),
              ),
            ),
          ),

          SizedBox(height: 20),

          DecoratedBox(
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10)
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(AppIcons.playArrow),


                ],
              ),
            )
          ),

          WaveProgressBar(
            progressPercentage: 0,
            listOfHeights: values,
            width: 10,
            height: 50,
            initialColor: Colors.grey,
            backgroundColor: Colors.transparent,
            progressColor: Colors.red,
            timeInMilliSeconds: 200,
            isHorizontallyAnimated: false,
            isVerticallyAnimated: false,
          ),
        ],
      ),
    );
  }

  void playSound(String sectionId){
    // currentVocab.americanVoiceId
  }

  void toWave() async {
    final sampleAudio = (await AssetsManager.load('assets/audio/ss.wav'))!
        .buffer.asUint8List().toList();

    final visualizer = AudioVisualizer(
      bandType: BandType.TenBand,
      /*sampleRate: 44100,
      zeroHzScale: 1.0,
      fallSpeed: 100.0,
      sensibility: 3.0,*/
    );

    int start = 0;
    int end = 2000;

    while(end < sampleAudio.length && start < sampleAudio.length) {
      audioFFT!.sink.add(visualizer.transform(sampleAudio.sublist(start, end)));
      start = end;
      end += 2000;
      await Future.delayed(Duration(milliseconds: 50), (){});
    }
  }

  void onRefresh(){
    assistCtr.clearStates();
    assistCtr.addStateAndUpdate(AssistController.state$loading);
    requestReading();
  }

  void requestReading(){
    requester.httpRequestEvents.onFailState = (req, res) async {
      assistCtr.clearStates();
      assistCtr.addStateAndUpdate(AssistController.state$error);
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      final List? data = res['data'];

      assistCtr.clearStates();
      assistCtr.updateMain();
    };

    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: '/vocabularies?LessonId=${widget.injector.lessonModel.id}');
    requester.request(context);
  }
}


/*
htmlText = '''
    <body>
    <p>verb (used with object)</p>
    <p><strong>1 ali bagheri is very good:</strong></p>
    <p><span style="color: #ff0000;">&nbsp; &nbsp; she is not good</span></p>
    <p>noun</p>
    <p><strong>2 ali bagheri is very good ali bagheri is very good ali bagheri is very good:</strong></p>
    <p><span style="color: #ff0000;">&nbsp; &nbsp; she is not good</span></p>
    <p><strong>&nbsp;&nbsp;</strong></p>
    </body>
''';


Directionality(
                      textDirection: TextDirection.ltr,
                      child: HTML.toRichText(context, htmlText, defaultTextStyle: AppThemes.body2TextStyle())
                    ),
* */