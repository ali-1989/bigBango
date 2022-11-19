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
import 'package:app/views/widgets/customCard.dart';
import 'package:flutter/material.dart';
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
    /*for (var i = 0; i < 150; i++) {
      values.add(rng.nextInt(25) * 1.0);
    }*/

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
        builder: (ctx, ctr, data) {
          return Scaffold(
              body: SafeArea(
                  child: buildBody()
              )
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
              child: Text('Reading').color(Colors.white),
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
                textDirection: TextDirection.ltr,
                children: [
                  CustomCard(
                    color: Colors.white,
                      radius: 25,
                      padding: EdgeInsets.all(5),
                      child: Icon(AppIcons.playArrow, size: 15)
                  ),

                  SizedBox(width: 10),

                  Expanded(
                    child: LayoutBuilder(
                      builder: (_, siz) {
                        return Directionality(
                          textDirection: TextDirection.ltr,
                          child: SliderTheme(
                            data: SliderThemeData(

                            ),
                            child: Slider(
                              value: 0,
                              onChanged: (v){},
                            ),
                          ),
                        );
                      }
                    ),
                  ),
                ],
              ),
            )
          ),
        ],
      ),
    );
  }

  void playSound(String sectionId){
    // currentVocab.americanVoiceId
  }

  /*void toWave() async {
    final audioBytes = (await AssetsManager.load('assets/audio/a2.mp3'))!
        .buffer.asUint8List().toList();

    //final buffer = snapshot.data as List<double>;
    //final wave = buffer.map((e) {return e;}).toList();

    final visualizer = AudioVisualizer(
      bandType: BandType.FourBand,
      sampleRate: 44100,
      zeroHzScale: 1.0,
      fallSpeed: 100.0,
      sensibility: 10.0,
    );

    int start = 0;
    int step = audioBytes.length ~/ 100;
    int end = step;

    if(audioBytes.length < 100){
      step = 4;
      end = 4;
    }

    print('->>>>>>>>>>>> len: ${audioBytes.length}    $step');

    while(end <= audioBytes.length && start < audioBytes.length) {
      final lis = visualizer.transform(audioBytes.sublist(start, end));
      //audioFFT!.sink.add(lis);
      //for(final k in lis){}

      if(lis[1] == 0.0){
        values.add(0);
      }
      else {
        values.add(lis[1] * 100);
      }

      start = end;
      end += step;


      if(end > audioBytes.length){
        end = audioBytes.length;
      }

      print('------start ${start} end: ${end}');
    }

    print('------ len: ${values.length}');
    assistCtr.updateMain();
  }*/

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