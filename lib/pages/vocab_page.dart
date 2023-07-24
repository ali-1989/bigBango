import 'dart:async';

import 'package:app/managers/api_manager.dart';
import 'package:app/tools/app_tools.dart';
import 'package:flutter/material.dart';

import 'package:animator/animator.dart';
import 'package:iris_tools/api/callAction/taskQueueCaller.dart';
import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/api/helpers/localeHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/attribute.dart';
import 'package:iris_tools/widgets/customCard.dart';
import 'package:iris_tools/widgets/irisImageView.dart';

import 'package:app/managers/font_manager.dart';
import 'package:app/services/audio_player_service.dart';
import 'package:app/services/review_service.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/enums/appAssistKeys.dart';
import 'package:app/structures/injectors/vocabPagesInjector.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/vocabModels/vocabModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appDecoration.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appToast.dart';
import 'package:app/tools/routeTools.dart';
import 'package:app/views/components/appbarLesson.dart';
import 'package:app/views/components/greetingView.dart';
import 'package:app/views/components/backBtn.dart';
import 'package:app/views/states/emptyData.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:app/views/states/waitToLoad.dart';

class VocabPage extends StatefulWidget {
  final VocabIdiomsPageInjector injector;

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
  String id$usVoicePlayerSectionId = 'usVoicePlayerSectionId';
  String id$ukVoicePlayerSectionId = 'ukVoicePlayerSectionId';
  String selectedPlayerId = '';
  String? voiceUrl;
  int currentVocabIdx = 0;
  late VocabModel currentVocab;
  TaskQueueCaller<VocabModel, dynamic> leitnerTaskQue = TaskQueueCaller();
  TaskQueueCaller<Set<String>, dynamic> reviewTaskQue = TaskQueueCaller();
  bool showGreeting = false;
  bool regulatorIsCall = false;
  AttributeController atrCtr1 = AttributeController();
  AttributeController atrCtr2 = AttributeController();
  double regulator = 200;
  Timer? reviewSendTimer;
  Set<String> reviewIds = {};

  @override
  void initState(){
    super.initState();

    //currentVocabIdx = widget.injector.lessonModel.vocabSegmentModel?.reviewCount?? 0;

    if(currentVocabIdx > 0){
      currentVocabIdx--;
    }

    leitnerTaskQue.setFn((VocabModel voc, value){
      requestSetLeitner(voc, voc.inLeitner);
    });

    reviewTaskQue.setFn((Set<String> lis, value){
      requestSetReview(lis);
    });

    if(widget.injector.vocabModel != null) {
      vocabList.add(widget.injector.vocabModel!);
      currentVocab = widget.injector.vocabModel!;
    }
    else {
      assistCtr.addState(AssistController.state$loading);
      requestVocabs();
    }
  }

  @override
  void dispose(){
    reviewSendTimer?.cancel();
    leitnerTaskQue.dispose();
    reviewTaskQue.dispose();
    requester.dispose();

    AudioPlayerService.getPlayer().stop();

    if(reviewIds.isNotEmpty){
      ReviewService.addReviews(ReviewSection.vocab, reviewIds);
    }

    ApiManager.requestGetLessonProgress(widget.injector.lessonModel);

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
      return ErrorOccur(onTryAgain: onRefresh, backButton: const BackBtn());
    }

    if(assistCtr.hasState(AssistController.state$loading)){
      return const WaitToLoad();
    }

    if(vocabList.isEmpty){
      return const EmptyData(backButton: BackBtn());
    }

    currentVocab = vocabList[currentVocabIdx];
    Color preBtnColor = Colors.black;
    Color nextBtnColor = Colors.black;

    if(currentVocabIdx == 0 && !showGreeting){
      preBtnColor = Colors.grey;
    }

    if(currentVocabIdx >= vocabList.length || showGreeting){
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
                      const SizedBox(height: 20),

                      AppbarLesson(title: widget.injector.lessonModel.title),

                      const SizedBox(height: 14),

                      /// 7/20 & title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Visibility(
                            visible: widget.injector.segment != null,
                            child: Row(
                              children: [
                                Chip(
                                  label: Text('${widget.injector.segment?.title}').bold().color(Colors.white),
                                  padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                                  visualDensity: VisualDensity.compact,
                                ),

                                const SizedBox(width: 10),

                                const SizedBox(
                                    height: 14,
                                    child: VerticalDivider(width: 3, color: Colors.black54)
                                ),
                                const SizedBox(width: 10),
                                const Text('بخش اول').alpha()
                                /*SizedBox(
                                  height: 15,
                                  width: 2,
                                  child: ColoredBox(
                                    color: Colors.black45,
                                  ),
                                ),*/
                              ],
                            ),
                          ),

                          Visibility(
                            visible: vocabList.length > 1,
                            child: Row(
                              children: [
                                Text('${vocabList.length}').englishFont().fsR(4),

                                const SizedBox(width: 10),
                                const Text('/').englishFont().fsR(5),

                                const SizedBox(width: 10),
                                CustomCard(
                                  color: Colors.grey.shade200,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    child: Text('${currentVocabIdx+1}').englishFont().bold().fsR(4)
                                )
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      /// progressbar
                      Visibility(
                        visible: vocabList.length > 1,
                        child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: LinearProgressIndicator(
                                value: calcProgress(),
                                backgroundColor: AppDecoration.red.withAlpha(50)
                            )
                        ),
                      ),

                      const SizedBox(height: 14),

                      Builder(
                          builder: (ctx){
                            if(showGreeting){
                              addPostOrCall(subContext: ctx, fn: () {
                                final dif = atrCtr1.getHeight()! - atrCtr2.getHeight()!;

                                if(dif > 0 && !regulatorIsCall) {
                                  regulatorIsCall = true;
                                  regulator += dif;
                                  assistCtr.updateHead();
                                }});

                              return SizedBox(
                                height: regulator,
                                  width: double.infinity,
                                  child: FittedBox(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          buildGreetingView(),
                                          const SizedBox(height: 20),

                                          Row(
                                            children: [
                                              ElevatedButton.icon(
                                                  onPressed: gotoNextPart,
                                                  label: Image.asset(AppImages.arrowRight2),
                                                  icon: const Text('بخش بعدی')
                                              ),

                                              const SizedBox(width: 30),
                                              OutlinedButton.icon(
                                                style: OutlinedButton.styleFrom(
                                                  side: const BorderSide(color: AppDecoration.red)
                                                ),
                                                  onPressed: resetVocab,
                                                  label: const Text('شروع مجدد'),
                                                  icon: Image.asset(AppImages.returnArrow)
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 15)
                                        ],
                                      )
                                  )
                              )
                              .wrapBoxBorder(
                                color: Colors.black54,
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
                                          child: const WaitToLoad()
                                      ),
                                    ),
                                  ),

                                  Visibility(
                                    visible: currentVocab.image?.fileLocation == null,
                                    child: Image.asset(AppImages.noImage),
                                  ),

                                  const SizedBox(height: 14),
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.black45, width: 1, style: BorderStyle.solid)
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
                                                      leitnerClick();
                                                    },
                                                    child: CustomCard(
                                                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 7),
                                                      color: Colors.grey.shade200,
                                                      child: Image.asset(currentVocab.inLeitner? AppImages.leitnerIcoRed : AppImages.leitnerIcoBlack),
                                                    ),
                                                  ),

                                                  const SizedBox(width: 10),

                                                  GestureDetector(
                                                    onTap: (){
                                                      selectedPlayerId = id$usVoicePlayerSectionId;
                                                      voiceUrl = currentVocab.americanVoice?.fileLocation;

                                                      playSound(id$usVoicePlayerSectionId);
                                                    },
                                                    child: Assist(
                                                      controller: assistCtr,
                                                      id: id$usVoicePlayerSectionId,
                                                      groupIds: const [AppAssistKeys.voicePlayerGroupId$vocabPage],
                                                      builder: (_, ctr, data){
                                                        return AnimateWidget(
                                                          resetOnRebuild: true,
                                                          triggerOnRebuild: true,
                                                          duration: const Duration(milliseconds: 500),
                                                          cycles: data == 'prepare' ? 100 : 1,
                                                          builder: (_, animate){
                                                            Color color = Colors.grey.shade200;
                                                            if(data == 'prepare'){
                                                              color = animate.fromTween((v) => ColorTween(begin: AppDecoration.red, end: AppDecoration.red.withAlpha(50)))!;
                                                            }
                                                            else if(data == 'play'){
                                                              color = AppDecoration.red;
                                                            }

                                                            return CustomCard(
                                                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 7),
                                                              color: color,
                                                              child: Column(
                                                                children: [
                                                                  Image.asset(AppImages.speaker2Ico, height: 16, width: 20),
                                                                  const SizedBox(height: 3),
                                                                  const Text('US', style: TextStyle(fontSize: 9))
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ),

                                                  const SizedBox(width: 10),

                                                  GestureDetector(
                                                    onTap: (){
                                                      selectedPlayerId = id$ukVoicePlayerSectionId;
                                                      voiceUrl = currentVocab.britishVoice?.fileLocation;

                                                      playSound(id$ukVoicePlayerSectionId);
                                                    },
                                                    child: Assist(
                                                      controller: assistCtr,
                                                      id: id$ukVoicePlayerSectionId,
                                                      groupIds: const [AppAssistKeys.voicePlayerGroupId$vocabPage],
                                                      builder: (_, ctr, data){
                                                        return AnimateWidget(
                                                          resetOnRebuild: true,
                                                          triggerOnRebuild: true,
                                                          duration: const Duration(milliseconds: 500),
                                                          cycles: data == 'prepare' ? 100 : 1,
                                                          builder: (_, animate){
                                                            Color color = Colors.grey.shade200;
                                                            if(data == 'prepare'){
                                                              color = animate.fromTween((v) => ColorTween(begin: AppDecoration.red, end: AppDecoration.red.withAlpha(50)))!;
                                                            }
                                                            else if(data == 'play'){
                                                              color = AppDecoration.red;
                                                            }

                                                            return CustomCard(
                                                                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 7),
                                                                color: color,
                                                                child: Column(
                                                                  children: [
                                                                    Image.asset(AppImages.speaker2Ico, height: 16, width: 20),
                                                                    const SizedBox(height: 3),
                                                                    const Text('UK', style: TextStyle(fontSize: 9),)
                                                                  ],
                                                                )
                                                            );
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ),

                                                  const SizedBox(width: 10),

                                                  RichText(
                                                    text: TextSpan(
                                                        children: [
                                                          const TextSpan(text: '[ ', style: TextStyle(fontSize: 16, color: Colors.black)),
                                                          TextSpan(text: '${currentVocab.pronunciation}', style: const TextStyle(fontSize: 12, color: Colors.black)),
                                                          const TextSpan(text: ' ]', style: TextStyle(fontSize: 16, color: Colors.black))
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

                                          /// divider
                                          const Padding(
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
                                                  assistCtr.updateHead();
                                                },
                                                label: const Text('مشاهده ترجمه'),
                                              ),
                                              secondChild: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(
                                                        height: 14,
                                                        child: VerticalDivider(width: 3, color: Colors.black54)
                                                    ),

                                                    const SizedBox(width: 10),
                                                    Text(currentVocab.translation),
                                                  ],
                                                ),
                                              ),
                                              crossFadeState: showTranslate? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                              duration: const Duration(milliseconds: 300)
                                          ),

                                          const SizedBox(height: 10),

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

                      const SizedBox(height: 14),
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
                label: const Text('next').englishFont().color(nextBtnColor)
            ),

            TextButton.icon(
                style: TextButton.styleFrom(),
                onPressed: onPreClick,
                icon: const Text('prev').englishFont().color(preBtnColor),
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
      final desc = currentVocab.descriptions[i];

      if(desc.content != null) {
        final dir = LocaleHelper.autoDirection(desc.content!);

        final t = Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: dir,
          children: [
            Text('${desc.number}) ',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  fontFamily: FontManager.instance.getEnglishFont()?.family,
              ),
              textDirection: dir,
            ),

            Flexible(
                child: Text('${desc.content}',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      fontFamily: FontManager.instance.getEnglishFont()?.family,
                  ),
                  textDirection: dir,
                )
            ),
          ],
        );

        list.add(t);
        list.add(const SizedBox(height: 10,));
      }

      for(final sample in desc.samples) {
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

          list.add(const SizedBox(height: 10));
          list.add(t);
          list.add(const SizedBox(height: 10));
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
              voiceUrl = sample.voice?.fileLocation;
              playSound(id);
            },
            child: Assist(
              controller: assistCtr,
              id: id,
              groupIds: const [AppAssistKeys.voicePlayerGroupId$vocabPage],
              builder: (_, ctr, data){
                return AnimateWidget(
                  resetOnRebuild: true,
                  triggerOnRebuild: true,
                  duration: const Duration(milliseconds: 600),
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
              const SizedBox(width: 6),
              Flexible(child: contentText),
            ],
          ));

          list.add(const SizedBox(height: 7));
          list.add(transText);
          list.add(const SizedBox(height: 7));
        }
      }

      if(i+1 < currentVocab.descriptions.length) {
        if (desc.samples.isNotEmpty) {
          list.add(const SizedBox(height: 15));
          list.add(const Divider());
          list.add(const SizedBox(height: 12));
        }
      }
    }

    return list;
  }

  Widget buildGreetingView(){
    return const GreetingView();
  }

  double calcProgress(){
    int r = ((currentVocabIdx+1) * 100) ~/ vocabList.length;
    return r/100;
  }

  void playSound(String sectionId){
    if(voiceUrl == null){
      AppToast.showToast(context, 'صدایی ثبت نشده');
      return;
    }

    assistCtr.updateGroup(AppAssistKeys.voicePlayerGroupId$vocabPage, stateData: null);
    assistCtr.updateAssist(sectionId, stateData: 'prepare');

    AudioPlayerService.getPlayerWithUrl(voiceUrl!).then((twoState) async {
      if(sectionId != selectedPlayerId){
        return;
      }

      if(twoState.hasResult1()){
        assistCtr.updateAssist(sectionId, stateData: 'play');
        await twoState.result1!.play();
        assistCtr.updateAssist(sectionId, stateData: null);
        twoState.result1!.stop();
      }
      else {
        AppToast.showToast(context, 'متاسفانه امکان پخش صدا نیست');
      }
    });
  }

  void resetVocab(){
    showGreeting = false;
    currentVocabIdx = 0;

    assistCtr.updateHead();
  }

  void gotoNextPart(){
    final page = AppTools.getNextPartOfLesson(widget.injector.lessonModel);

    if(page != null) {
      RouteTools.pushReplacePage(context, page);
    }
  }

  void onNextClick(){
    AudioPlayerService.getPlayer().stop();
    assistCtr.updateGroup(AppAssistKeys.voicePlayerGroupId$vocabPage, stateData: null);

    if(currentVocabIdx < vocabList.length-1) {
      currentVocabIdx++;

      currentVocab = vocabList[currentVocabIdx];
      showTranslate = currentVocab.showTranslation;

      /*if(!widget.injector.lessonModel.vocabSegmentModel!.reviewIds.contains(currentVocab.id)) {
        sendReview(currentVocab.id);
      }todo*/
    }
    else {
      showGreeting = true;
    }

    assistCtr.updateHead();
  }

  void onPreClick(){
    if(showGreeting){
      showGreeting = false;
    }
    else {
      AudioPlayerService.getPlayer().stop();
      assistCtr.updateGroup(AppAssistKeys.voicePlayerGroupId$vocabPage, stateData: null);
      currentVocabIdx--;

      currentVocab = vocabList[currentVocabIdx];
      showTranslate = currentVocab.showTranslation;
    }

    assistCtr.updateHead();
  }

  void onRefresh(){
    assistCtr.clearStates();
    assistCtr.addStateAndUpdateHead(AssistController.state$loading);
    requestVocabs();
  }

  void leitnerClick() async {
    currentVocab.inLeitner = !currentVocab.inLeitner;
    assistCtr.updateHead();

    leitnerTaskQue.addObject(currentVocab);
  }

  void requestVocabs(){
    requester.httpRequestEvents.onFailState = (req, res) async {
      assistCtr.clearStates();
      assistCtr.addStateAndUpdateHead(AssistController.state$error);
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      final List? data = res['data'];

      if(data is List){
        for(final k in data){
          final vo = VocabModel.fromMap(k);
          vocabList.add(vo);
        }
      }

      if(vocabList.isNotEmpty) {
        currentVocab = vocabList[currentVocabIdx];
        showTranslate = currentVocab.showTranslation;

        /*if(!widget.injector.lessonModel.vocabSegmentModel!.reviewIds.contains(currentVocab.id)) {
          sendReview(currentVocab.id);
        }todo*/
      }

      assistCtr.clearStates();
      assistCtr.updateHead();
    };

    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: '/vocabularies?CategoryId=${widget.injector.categoryId}');
    requester.request(context);
  }

  void requestSetLeitner(VocabModel vocab, bool state){
    requester.httpRequestEvents.onFailState = (req, res) async {
      AppToast.showToast(context, 'خطا در ارتباط با سرور');
      vocab.inLeitner = !state;
      leitnerTaskQue.callNext(null);
      assistCtr.updateHead();
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      if(state){
        AppToast.showToast(context, 'به لایتنر اضافه شد');
      }

      leitnerTaskQue.callNext(null);
      //assistCtr.updateHead();
    };

    final js = <String, dynamic>{};
    js['contentId'] = vocab.id;
    js['contentType'] = 1;

    requester.methodType = MethodType.post;
    requester.prepareUrl(pathUrl: '/leitner/addOrRemove');
    requester.bodyJson = js;
    requester.request(context);
  }

  void sendReview(String id){
    reviewIds.add(id);

    if(reviewSendTimer == null || !reviewSendTimer!.isActive){
      reviewSendTimer = Timer(const Duration(seconds: 5), (){
        reviewTaskQue.addObject({...reviewIds});
      });
    }
  }

  void requestSetReview(Set<String> ids) async {
    final status = await ReviewService.requestSetReview(ReviewSection.vocab, ids.toList());

    if(status){
      reviewIds.removeAll(ids);
      //todo.widget.injector.lessonModel.vocabSegmentModel!.reviewIds.addAll(ids);
      //widget.injector.lessonModel.vocabSegmentModel!.reviewCount++;

      ReviewService.requestUpdateLesson(widget.injector.lessonModel);
    }

    reviewTaskQue.callNext(null);
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
