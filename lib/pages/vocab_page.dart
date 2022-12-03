import 'package:app/pages/grammar_page.dart';
import 'package:app/pages/listening_page.dart';
import 'package:app/pages/reading_page.dart';
import 'package:app/structures/injectors/grammarPagesInjector.dart';
import 'package:app/structures/injectors/listeningPagesInjector.dart';
import 'package:app/structures/injectors/readingPagesInjector.dart';
import 'package:app/structures/injectors/vocabPagesInjector.dart';
import 'package:flutter/material.dart';

import 'package:animator/animator.dart';
import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/api/taskQueueCaller.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/attribute.dart';
import 'package:iris_tools/widgets/irisImageView.dart';

import 'package:app/managers/fontManager.dart';
import 'package:app/pages/idioms_page.dart';
import 'package:app/services/audio_player_service.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/middleWare/requester.dart';
import 'package:app/structures/models/vocabModels/vocabModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appToast.dart';
import 'package:app/views/components/appbarLesson.dart';
import 'package:app/views/components/greetingView.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:app/views/states/waitToLoad.dart';
import 'package:app/views/widgets/customCard.dart';


class VocabPage extends StatefulWidget {
  final VocabPageInjector injector;

  const VocabPage({
    required this.injector,
    Key? key
  }) : super(key: key);

  @override
  State<VocabPage> createState() => _VocabPageState();
}
///======================================================================================================================
class _VocabPageState extends StateBase<VocabPage> {
  bool showTranslate = false;
  Requester requester = Requester();
  List<VocabModel> vocabList = [];
  String id$voicePlayerGroupId = 'voicePlayerGroupId';
  String id$usVoicePlayerSectionId = 'usVoicePlayerSectionId';
  String id$ukVoicePlayerSectionId = 'ukVoicePlayerSectionId';
  int currentVocabIdx = 0;
  late VocabModel currentVocab;
  TaskQueueCaller<VocabModel, dynamic> taskQue = TaskQueueCaller();
  String selectedPlayerId = '';
  bool showGreeting = false;
  bool regulatorIsCall = false;
  AttributeController atrCtr1 = AttributeController();
  AttributeController atrCtr2 = AttributeController();
  double regulator = 200;

  @override
  void initState(){
    super.initState();

    taskQue.setFn((VocabModel voc, value){
      requestSetLeitner(voc, voc.inLeitner);
    });

    assistCtr.addState(AssistController.state$loading);
    requestVocabs();
  }

  @override
  void dispose(){
    requester.dispose();
    taskQue.dispose();
    AudioPlayerService.getAudioPlayer().stop();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
        builder: (ctx, ctr, data){
          return Scaffold(
            //appBar: buildAppbar(),
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

    currentVocab = vocabList[currentVocabIdx];
    Color preBtnColor = Colors.black;
    Color nextBtnColor = Colors.black;

    if(currentVocabIdx == 0){
      preBtnColor = Colors.grey;
    }

    if(currentVocabIdx == vocabList.length){
      nextBtnColor = Colors.grey;
    }

    return Column(
      children: [
        Attribute(
          controller: atrCtr1,
          child: Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: Attribute(
                  controller: atrCtr2,
                  child: Column(
                    children: [
                      SizedBox(height: 20),

                      AppbarLesson(title: widget.injector.lessonModel.title),

                      SizedBox(height: 14),

                      /// 7/20
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Chip(
                                label: Text(widget.injector.segment.title).bold().color(Colors.white),
                                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                                visualDensity: VisualDensity.compact,
                              ),

                              SizedBox(width: 10),

                              /*SizedBox(
                                height: 15,
                                width: 2,
                                child: ColoredBox(
                                  color: Colors.black45,
                                ),
                              ),*/
                            ],
                          ),

                          Row(
                            children: [
                              Text('${vocabList.length}').englishFont().fsR(4),

                              SizedBox(width: 10),
                              Text('/').englishFont().fsR(5),

                              SizedBox(width: 10),
                              CustomCard(
                                color: Colors.grey.shade200,
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  child: Text('${currentVocabIdx+1}').englishFont().bold().fsR(4)
                              )
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 14),

                      /// progressbar
                      Directionality(
                          textDirection: TextDirection.ltr,
                          child: LinearProgressIndicator(value: calcProgress(), backgroundColor: AppColors.red.withAlpha(50))
                      ),

                      SizedBox(height: 14),

                      Builder(
                          builder: (ctx){
                            if(showGreeting){
                              addPostOrCall(subContext: ctx, fn: () {
                                final dif = atrCtr1.getHeight()! - atrCtr2.getHeight()!;

                                if(dif > 0 && !regulatorIsCall) {
                                  regulatorIsCall = true;
                                  regulator += dif;
                                  assistCtr.updateMain();
                                }});

                              return SizedBox(
                                height: regulator,
                                  child: FittedBox(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          buildGreetingView(),
                                          SizedBox(height: 20),

                                          Row(
                                            children: [
                                              ElevatedButton.icon(
                                                  onPressed: gotoNextPart,
                                                  label: Image.asset(AppImages.arrowRight2),
                                                  icon: Text('بخش بعدی')
                                              ),

                                              SizedBox(width: 30),
                                              OutlinedButton.icon(
                                                style: OutlinedButton.styleFrom(
                                                  side: BorderSide(color: AppColors.red)
                                                ),
                                                  onPressed: resetVocab,
                                                  label: Image.asset(AppImages.returnArrow),
                                                  icon: Text('شروع مجدد')
                                              ),
                                            ],
                                          )
                                        ],
                                      )
                                  )
                              );
                            }
                            else {
                              return Column(
                                children: [
                                  Visibility(
                                    visible: currentVocab.image?.fileLocation != null,
                                    child: IrisImageView(
                                      height: sh/3,
                                      url: currentVocab.image?.fileLocation,
                                      beforeLoadWidget: SizedBox(
                                          height: sh/3,
                                          child: WaitToLoad()
                                      ),
                                    ),
                                  ),

                                  Visibility(
                                    visible: currentVocab.image?.fileLocation == null,
                                    child: Image.asset(AppImages.noImage),
                                  ),

                                  SizedBox(height: 14),
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.black, width: 1, style: BorderStyle.solid)
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  GestureDetector(
                                                    onTap: (){
                                                      //leitnerClick();
                                                    },
                                                    child: CustomCard(
                                                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 7),
                                                      color: Colors.grey.shade200,
                                                      child: Image.asset(currentVocab.inLeitner? AppImages.leitnerIcoRed : AppImages.leitnerIcoBlack),
                                                    ),
                                                  ),

                                                  SizedBox(width: 10),

                                                  GestureDetector(
                                                    onTap: (){
                                                      selectedPlayerId = id$usVoicePlayerSectionId;
                                                      playSound(id$usVoicePlayerSectionId);
                                                    },
                                                    child: Assist(
                                                      controller: assistCtr,
                                                      id: id$usVoicePlayerSectionId,
                                                      groupId: id$voicePlayerGroupId,
                                                      builder: (_, ctr, data){
                                                        return AnimateWidget(
                                                          resetOnRebuild: true,
                                                          triggerOnRebuild: true,
                                                          duration: Duration(milliseconds: 500),
                                                          cycles: data == 'prepare' ? 100 : 1,
                                                          builder: (_, animate){
                                                            Color color = Colors.grey.shade200;
                                                            if(data == 'prepare'){
                                                              color = animate.fromTween((v) => ColorTween(begin: AppColors.red, end: AppColors.red.withAlpha(50)))!;
                                                            }
                                                            else if(data == 'play'){
                                                              color = AppColors.red;
                                                            }

                                                            return CustomCard(
                                                              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 7),
                                                              color: color,
                                                              child: Column(
                                                                children: [
                                                                  Image.asset(AppImages.speaker2Ico, height: 16, width: 20),
                                                                  SizedBox(height: 3),
                                                                  Text('US', style: TextStyle(fontSize: 9))
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ),

                                                  SizedBox(width: 10),

                                                  GestureDetector(
                                                    onTap: (){
                                                      selectedPlayerId = id$ukVoicePlayerSectionId;
                                                      playSound(id$ukVoicePlayerSectionId);
                                                    },
                                                    child: Assist(
                                                      controller: assistCtr,
                                                      id: id$ukVoicePlayerSectionId,
                                                      groupId: id$voicePlayerGroupId,
                                                      builder: (_, ctr, data){
                                                        return AnimateWidget(
                                                          resetOnRebuild: true,
                                                          triggerOnRebuild: true,
                                                          duration: Duration(milliseconds: 500),
                                                          cycles: data == 'prepare' ? 100 : 1,
                                                          builder: (_, animate){
                                                            Color color = Colors.grey.shade200;
                                                            if(data == 'prepare'){
                                                              color = animate.fromTween((v) => ColorTween(begin: AppColors.red, end: AppColors.red.withAlpha(50)))!;
                                                            }
                                                            else if(data == 'play'){
                                                              color = AppColors.red;
                                                            }

                                                            return CustomCard(
                                                                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 7),
                                                                color: color,
                                                                child: Column(
                                                                  children: [
                                                                    Image.asset(AppImages.speaker2Ico, height: 16, width: 20),
                                                                    SizedBox(height: 3),
                                                                    Text('UK', style: TextStyle(fontSize: 9),)
                                                                  ],
                                                                )
                                                            );
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ),

                                                  SizedBox(width: 10),

                                                  RichText(
                                                    text: TextSpan(
                                                        children: [
                                                          TextSpan(text: '[ ', style: TextStyle(fontSize: 16, color: Colors.black)),
                                                          TextSpan(text: '${currentVocab.pronunciation}', style: TextStyle(fontSize: 12, color: Colors.black)),
                                                          TextSpan(text: ' ]', style: TextStyle(fontSize: 16, color: Colors.black))
                                                        ]
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              Flexible(
                                                  child: Text(currentVocab.word, textDirection: TextDirection.ltr,)
                                                      .bold(weight: FontWeight.w400).fsR(4)
                                              ),
                                            ],
                                          ),

                                          Padding(
                                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 0),
                                            child: SizedBox(
                                              width: double.infinity,
                                              height: 1,
                                              child: ColoredBox(color: Colors.grey),
                                            ),
                                          ),

                                          AnimatedCrossFade(
                                              firstChild: InputChip(
                                                onPressed: (){
                                                  showTranslate = !showTranslate;
                                                  assistCtr.updateMain();
                                                },
                                                label: Text('مشاهده ترجمه'),
                                              ),
                                              secondChild: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                child: Text(currentVocab.translation),
                                              ),
                                              crossFadeState: showTranslate? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                              duration: Duration(milliseconds: 300)
                                          ),

                                          SizedBox(height: 10),

                                          ...buildDescription(),

                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                          }
                      ),

                      SizedBox(height: 14),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
                onPressed: onNextClick,
                icon: RotatedBox(
                    quarterTurns: 2,
                    child: Image.asset(AppImages.arrowLeftIco, color: nextBtnColor)
                ),
                label: Text('next').englishFont().color(nextBtnColor)
            ),

            TextButton.icon(
                style: TextButton.styleFrom(),
                onPressed: onPreClick,
                icon: Text('pre').englishFont().color(preBtnColor),
                label: Image.asset(AppImages.arrowLeftIco, color: preBtnColor)
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> buildDescription(){
    List<Widget> list = [];

    for(int i=0; i < currentVocab.descriptions.length; i++) {
      final k = currentVocab.descriptions[i];

      if(k.content != null) {
        final t = Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: TextDirection.ltr,
          children: [
            Text('${k.number}  ',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  fontFamily: FontManager.instance.getEnglishFont()?.family,
              ),
              textDirection: TextDirection.ltr,
            ),

            Flexible(
                child: Text('${k.content}',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      fontFamily: FontManager.instance.getEnglishFont()?.family,
                  ),
                  textDirection: TextDirection.ltr,
                )
            ),
          ],
        );

        list.add(t);
        list.add(SizedBox(height: 10,));
      }

      for(final sample in k.samples) {
        if (sample.type == 2) {
          final t = Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                  child: Text('${sample.title}',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.deepOrange,
                      fontFamily: FontManager.instance.getEnglishFont()?.family,
                    ),
                    textDirection: TextDirection.ltr,
                  )
              ),
            ],
          );

          list.add(SizedBox(height: 10));
          list.add(t);
          list.add(SizedBox(height: 10));
        }
        else {
          final contentText = Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                  child: Text('${sample.content}',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade800,
                      fontFamily: FontManager.instance.getEnglishFont()?.family,
                    ),
                    textDirection: TextDirection.ltr,
                  )
              ),
            ],
          );

          final id = Generator.generateKey(4);
          final transText = Text('${sample.translation}', style: TextStyle(color: Colors.grey.shade800));

          final voiceView = GestureDetector(
            onTap: (){
              selectedPlayerId = id;
              playSound(id);
            },
            child: Assist(
              controller: assistCtr,
              id: id,
              groupId: id$voicePlayerGroupId,
              builder: (_, ctr, data){
                return AnimateWidget(
                  resetOnRebuild: true,
                  triggerOnRebuild: true,
                  duration: Duration(milliseconds: 600),
                  cycles: data == 'prepare'  || data == 'play'? 100 : 1,
                  builder: (_, animate){
                    double val = 1;
                    if(data == 'prepare'){
                      val = animate.fromTween((v) => Tween(begin: 0.1, end: 0.5))!;
                    }

                    if(data == 'play'){
                      val = animate.fromTween((v) => Tween(begin: 0.5, end: 1))!;
                    }

                    return Opacity(
                      opacity: val,
                      child: Image.asset(AppImages.speaker3Ico),
                    );
                  },
                );
              },
            ),
          );

          list.add(Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            textDirection: TextDirection.ltr,
            children: [
              voiceView,
              SizedBox(width: 6),
              Flexible(child: contentText),
            ],
          ));

          list.add(SizedBox(height: 7));
          list.add(transText);
          list.add(SizedBox(height: 7));
        }
      }

      if(i+1 < currentVocab.descriptions.length) {
        if (k.samples.isNotEmpty) {
          list.add(SizedBox(height: 15));
          list.add(Divider());
          list.add(SizedBox(height: 12));
        }
      }
    }

    return list;
  }

  Widget buildGreetingView(){
    return GreetingView();
  }

  double calcProgress(){
    int r = ((currentVocabIdx+1) * 100) ~/ vocabList.length;
    return r/100;
  }

  void playSound(String sectionId){
    // currentVocab.americanVoiceId
    assistCtr.updateGroup(id$voicePlayerGroupId, stateData: null);
    assistCtr.update(sectionId, stateData: 'prepare');
    AudioPlayerService.networkVoicePlayer('https://download.samplelib.com/mp3/sample-3s.mp3').then((p) async {
      if(sectionId != selectedPlayerId){
        return;
      }

      assistCtr.update(sectionId, stateData: 'play');
      await p.play();
      assistCtr.update(sectionId, stateData: null);
      p.stop();
    });
  }

  void resetVocab(){
    showGreeting = false;
    currentVocabIdx = 0;

    assistCtr.updateMain();
  }

  void gotoNextPart(){
    Widget? page;

    if(widget.injector.segment.hasIdioms){
      page = IdiomsPage(injector: widget.injector);
    }
    else if (widget.injector.lessonModel.grammarModel != null){
      page = GrammarPage(injection: GrammarPageInjector(widget.injector.lessonModel));
    }
    else if (widget.injector.lessonModel.readingModel != null){
      page = ReadingPage(injector: ReadingPageInjector(widget.injector.lessonModel));
    }
    else if (widget.injector.lessonModel.listeningModel != null){
      page = ListeningPage(injector: ListeningPageInjector(widget.injector.lessonModel));
    }

    if(page != null) {
      AppRoute.replace(context, page);
    }
  }

  void onNextClick(){
    AudioPlayerService.getAudioPlayer().stop();
    assistCtr.updateGroup(id$voicePlayerGroupId, stateData: null);

    if(currentVocabIdx < vocabList.length-1) {
      currentVocabIdx++;

      currentVocab = vocabList[currentVocabIdx];
      showTranslate = currentVocab.showTranslation;
    }
    else {
      showGreeting = true;
    }

    assistCtr.updateMain();
  }

  void onPreClick(){
    if(showGreeting){
      showGreeting = false;
    }
    else {
      AudioPlayerService.getAudioPlayer().stop();
      assistCtr.updateGroup(id$voicePlayerGroupId, stateData: null);
      currentVocabIdx--;

      currentVocab = vocabList[currentVocabIdx];
      showTranslate = currentVocab.showTranslation;
    }

    assistCtr.updateMain();
  }

  void onRefresh(){
    assistCtr.clearStates();
    assistCtr.addStateAndUpdate(AssistController.state$loading);
    requestVocabs();
  }

  void leitnerClick() async {
    currentVocab.inLeitner = !currentVocab.inLeitner;
    assistCtr.updateMain();

    taskQue.addObject(currentVocab);
  }

  void requestVocabs(){
    requester.httpRequestEvents.onFailState = (req, res) async {
      assistCtr.clearStates();
      assistCtr.addStateAndUpdate(AssistController.state$error);
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      final List? data = res['data'];

      if(data is List){
        for(final k in data){
          final vo = VocabModel.fromMap(k);
          vocabList.add(vo);
        }
      }

      currentVocab = vocabList[currentVocabIdx];
      showTranslate = currentVocab.showTranslation;

      assistCtr.clearStates();
      assistCtr.updateMain();
    };

    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: '/vocabularies?LessonId=${widget.injector.lessonModel.id}');
    requester.request(context);
  }

  void requestSetLeitner(VocabModel vocab, bool state){
    requester.httpRequestEvents.onFailState = (req, res) async {
      AppToast.showToast(context, 'خطا در ارتباط با سرور');
      vocab.inLeitner = !state;
      taskQue.callNext(null);
      assistCtr.updateMain();
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      taskQue.callNext(null);
      //assistCtr.updateMain();
    };

    requester.methodType = MethodType.post;
    requester.prepareUrl(pathUrl: '/setLeitner?vocabId=${widget.injector.lessonModel.id}?state=$state');
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
