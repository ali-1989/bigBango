import 'package:app/managers/api_manager.dart';
import 'package:flutter/material.dart';

import 'package:extended_sliver/extended_sliver.dart';
import 'package:iris_runtime_cache/iris_runtime_cache.dart';
import 'package:iris_tools/features/overlayDialog.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/customCard.dart';
import 'package:iris_tools/widgets/irisSearchBar.dart';

import 'package:app/pages/exam_page.dart';
import 'package:app/pages/grammar_page.dart';
import 'package:app/pages/listening_page.dart';
import 'package:app/pages/reading_page.dart';
import 'package:app/pages/timetable_page.dart';
import 'package:app/pages/vocab_page.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/builders/examBuilderContent.dart';
import 'package:app/structures/enums/appAssistKeys.dart';
import 'package:app/structures/enums/appStoreScope.dart';
import 'package:app/structures/injectors/grammarPagesInjector.dart';
import 'package:app/structures/injectors/listeningPagesInjector.dart';
import 'package:app/structures/injectors/readingPagesInjector.dart';
import 'package:app/structures/injectors/vocabPagesInjector.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/examModels/autodidactModel.dart';
import 'package:app/structures/models/examModels/examModel.dart';
import 'package:app/structures/models/lessonModels/grammarSegmentModel.dart';
import 'package:app/structures/models/lessonModels/iSegmentModel.dart';
import 'package:app/structures/models/lessonModels/lessonModel.dart';
import 'package:app/structures/models/lessonModels/listeningSegmentModel.dart';
import 'package:app/structures/models/lessonModels/readingSegmentModel.dart';
import 'package:app/structures/models/lessonModels/vocabularySegmentModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/services/session_service.dart';
import 'package:app/tools/app/appDecoration.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appOverlay.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/tools/app/appSnack.dart';
import 'package:app/tools/app/appToast.dart';
import 'package:app/tools/routeTools.dart';
import 'package:app/views/dialogs/selectGrammarDialog.dart';
import 'package:app/views/dialogs/selectListeningDialog.dart';
import 'package:app/views/dialogs/selectReadingDialog.dart';
import 'package:app/views/dialogs/selectVocabIdiomsDialog.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:app/views/states/waitToLoad.dart';

class HomePage extends StatefulWidget {
  static String id$homePageHead = '${identityHashCode(HomePage)}_head';

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => HomePageState();
}
///===================================================================================================================
class HomePageState extends StateBase<HomePage> {
  List<LessonModel> lessons = [];
  List<LessonModel> lessonsBackup = [];
  List<int> openedLessonsIds = [];
  Requester requester = Requester();
  String state$loading = 'state_loading';
  String state$error = 'state_error';

  @override
  void initState(){
    super.initState();

    assistCtr.addState(state$loading);
    requestLessons();
  }

  @override
  void dispose(){
    requester.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Assist(
      controller: assistCtr,
      id: HomePage.id$homePageHead,
      groupIds: [AppAssistKeys.updateOnLessonChange],
      builder: (_, ctr, data) {
        if(assistCtr.hasState(state$error)){
          return ErrorOccur(
            onTryAgain: onTryAgain,
          );
        }

        if(assistCtr.hasState(state$loading)){
          return WaitToLoad();
        }

        return Column(
          children: [
            const SizedBox(height: 60),

            Expanded(
                child: CustomScrollView(
                  slivers: [
                    ExtendedSliverAppbar(
                      toolbarHeight: 70,
                      toolBarColor: Colors.transparent,
                      isOpacityFadeWithTitle: true,
                      isOpacityFadeWithToolbar: false,
                      actions: const SizedBox(),
                      leading: const SizedBox(),
                      background: SizedBox(
                        height: 210,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Positioned(
                              bottom: 30,
                              left: 0,
                              right: 0,
                              child: Image.asset(AppImages.homeBackground,
                              fit: BoxFit.fill,
                            ),
                            ),

                            Positioned(
                              top: 20,
                              left: 0,
                              right: 0,
                              child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 30),
                              child: Image.asset(AppImages.homeBackIcons,
                                fit: BoxFit.contain,
                              ),
                            ),
                            ),

                            Positioned(
                              bottom: 62,
                              left: 0,
                              right: 0,
                              child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 30),
                              child: Center(
                                  child: Chip(
                                      backgroundColor: Colors.white,
                                      label: RichText(
                                        text: const TextSpan(
                                            children: [
                                              TextSpan(text: 'آکادمی آنلاین آموزش انگلیسی ', style: TextStyle(color: Colors.black)),
                                              TextSpan(text: 'بیگ بنگو ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
                                            ]
                                        ),
                                      )
                                  )
                              ),
                            ),
                            ),

                            Positioned(
                              bottom: 5,
                              left: 0,
                              right: 0,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: IrisSearchBar(
                                  hint: 'جستجو در دروس',
                                  onChangeEvent: onSearch,
                                  insertDefaultClearIcon: false,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border(
                                      top: BorderSide(color: Colors.grey.shade300),
                                      bottom: BorderSide(color: Colors.grey.shade300),
                                      left: BorderSide(color: Colors.grey.shade300),
                                      right: BorderSide(color: Colors.grey.shade300),
                                    )
                                  ),
                                )
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    /*SliverToBoxAdapter(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),*/

                    SliverToBoxAdapter(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const SizedBox(width: 15),
                              Image.asset(AppImages.lessonListIco, width: 18, height: 18),
                              const SizedBox(width: 6,),
                              const Text('لیست دروس', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),

                    /// lessons list
                    SliverList(
                      delegate: SliverChildBuilderDelegate((ctx, idx){
                        return buildListItem(lessons[idx]);
                        },
                        childCount: lessons.length,
                      ),
                    ),
                  ],
                )
            ),
          ],
        );
      }
    );
  }

  Widget buildListItem(LessonModel lesson){
    return GestureDetector(
      onTap: (){
        onLessonClick(lesson);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: AnimatedCrossFade(
            duration: const Duration(milliseconds: 500),
            crossFadeState: isOpen(lesson) ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: buildFirstStateOfLesson(lesson),
            secondChild: buildSecondStateOfLesson(lesson),
          ),
        ),
      ),
    );
  }

  Widget buildFirstStateOfLesson(LessonModel lesson){
    return ColoredBox(
      color: Colors.grey.withAlpha(50),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: ColoredBox(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 3),
              child: Row(
                children: [
                   SizedBox(
                    width: 1.5,
                    height: 20,
                    child: ColoredBox(
                      color: AppDecoration.red,
                    ),
                  ),

                  const SizedBox(width: 12),
                  Card(
                      elevation: 0,
                      color: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        child: Text('${lesson.number}', style: const TextStyle(color: Colors.black)),
                      )
                  ),

                  const SizedBox(width: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(lesson.title),
                  ),

                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if(lesson.isLock){
                          return Align(
                            alignment: Alignment.centerLeft,
                              child: Image.asset(AppImages.lockIco, width: 30, height: 30)
                          );
                        }

                        return Directionality(
                          textDirection: TextDirection.ltr,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${lesson.improvementPercentage} %', style: TextStyle(fontSize: 12)),

                              const SizedBox(height: 4),
                              SizedBox(
                                width: 70,
                                child: LinearProgressIndicator(
                                  backgroundColor: Colors.greenAccent.withAlpha(40),
                                  color: Colors.greenAccent,
                                  value: lesson.improvementPercentage/100,
                                  minHeight: 3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text('میزان پیشرفت', style: TextStyle(fontSize: 10),),
                            ],
                          ),
                        );
                      }
                    ),
                  ),

                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSecondStateOfLesson(LessonModel lesson){
    return ColoredBox(
      color: AppDecoration.red,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: ColoredBox(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 3),
              child: Column(
                children: [

                  Row(
                    children: [
                      SizedBox(
                        width: 1.5,
                        height: 20,
                        child: ColoredBox(
                          color: AppDecoration.red,
                        ),
                      ),

                      const SizedBox(width: 12),
                      Card(
                          elevation: 0,
                          color: AppDecoration.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            child: Text('${lesson.number}', style: const TextStyle(color: Colors.white)),
                          )
                      ),

                      const SizedBox(width: 12),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text(lesson.title),
                      ),

                      Expanded(
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${lesson.improvementPercentage} %', style: TextStyle(fontSize: 12),),

                              const SizedBox(height: 4),
                              SizedBox(
                                width: 70,
                                child: LinearProgressIndicator(
                                  backgroundColor: Colors.greenAccent.withAlpha(40),
                                  color: Colors.greenAccent,
                                  value: lesson.improvementPercentage/100,
                                  minHeight: 3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text('میزان پیشرفت', style: TextStyle(fontSize: 10)),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),
                    ],
                  ),

                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),

                        /// divider
                        SizedBox(
                          height: 2,
                          width: double.infinity,
                          child: ColoredBox(
                              color: Colors.grey.shade200
                          ),
                        ),

                        Builder(
                            builder: (_){
                              bool hasVocab = lesson.vocabSegmentModel != null && (lesson.vocabSegmentModel!.count > 0 || lesson.vocabSegmentModel!.idiomCount > 0);
                              bool hasGrammar = lesson.grammarModel != null && lesson.grammarModel!.grammarList.isNotEmpty;

                              bool hasAny = hasVocab || hasGrammar;

                              if(!hasAny){
                                return SizedBox();
                              }

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 7),
                                child: Row(
                                  children: [
                                    buildSegment(lesson, hasVocab? lesson.vocabSegmentModel : lesson.grammarModel),

                                    SizedBox(width: 8),

                                    buildSegment(lesson, !hasVocab ? null : lesson.grammarModel),
                                  ],
                                ),
                              );
                            }
                        ),

                        const SizedBox(width: 7),

                        Builder(
                            builder: (_){
                              bool hasReading = lesson.readingModel != null && lesson.readingModel!.readingList.isNotEmpty;
                              bool hasListening = lesson.listeningModel != null && lesson.listeningModel!.listeningList.isNotEmpty;

                              bool hasAny = hasReading || hasListening;

                              if(!hasAny){
                                return SizedBox();
                              }

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 7),
                                child: Row(
                                  children: [
                                    buildSegment(lesson, hasReading? lesson.readingModel : lesson.listeningModel),

                                    SizedBox(width: 8),

                                    buildSegment(lesson, !hasReading ? null : lesson.listeningModel),
                                  ],
                                ),
                              );
                            }
                        ),

                        const SizedBox(width: 7),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          child: Row(
                            children: [
                              Expanded(
                                  child: Stack(
                                    children: [
                                      CustomCard(
                                        color: Colors.grey.shade200,
                                        padding: const EdgeInsets.symmetric(horizontal:5.0, vertical: 10),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                CustomCard(
                                                    color: Colors.white,
                                                    padding: EdgeInsets.all(5),
                                                    child: Image.asset(AppImages.examIco)
                                                ),

                                                SizedBox(width: 10),

                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('آزمون'),
                                                    SizedBox(height: 5),
                                                    Text('Quiz').alpha(alpha: 100),
                                                  ],
                                                ),

                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      Positioned(
                                        bottom: 10,
                                        left: 5,
                                        child: GestureDetector(
                                          onTap: (){
                                            requestExams(lesson);
                                          },
                                          child: CustomCard(
                                            padding: EdgeInsets.all(10),
                                            child: Row(
                                              children: [
                                                Image.asset(AppImages.startExercise),
                                                SizedBox(width: 10),
                                                Text('شروع'),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: (){
                                requesterSupport(lesson);
                              },
                              child: Row(
                                children: [
                                  Image.asset(AppImages.supportIco, width: 25, height: 25),
                                  const SizedBox(width: 10),
                                  Text(AppMessages.supportOfLesson),
                                ],
                              )
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSegment(LessonModel lesson, ISegmentModel? segmentModel){

    if(segmentModel == null){
      return Flexible(
        fit: FlexFit.tight,
        flex: 1,
        child: SizedBox(),
      );
    }

    if(segmentModel is ListeningSegmentModel && segmentModel.listeningList.isEmpty){
      return Flexible(
        fit: FlexFit.tight,
        flex: 1,
        child: SizedBox(),
      );
    }

    return Flexible(
        fit: FlexFit.tight,
        flex: 1,
        child: GestureDetector(
          onTap: (){
            onLessonSegmentClick(lesson, segmentModel);
          },
          child: Stack(
            children: [
              CustomCard(
                color: Colors.grey.shade200,
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CustomCard(
                            color: Colors.white,
                            padding: EdgeInsets.all(5),
                            child: Image.asset(segmentModel.icon)
                        ),

                        SizedBox(width: 10),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(segmentModel.title),
                            SizedBox(height: 5),
                            Text(segmentModel.engTitle).alpha(alpha: 100),
                          ],
                        ),

                      ],
                    ),

                    SizedBox(height: 8),

                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.greenAccent.withAlpha(40),
                        color: Colors.greenAccent,
                        value: segmentModel.progress /100,
                        minHeight: 3,
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                bottom: 10,
                left: 5,
                child: Text('${segmentModel.progress} %'),
              ),
            ],
          ),
        )
    );
  }

  void onLessonSegmentClick(LessonModel lessonModel, ISegmentModel segment){
    Widget? dialog;

    if(segment is VocabularySegmentModel){
      if(segment.hasIdioms){
        dialog = SelectVocabIdiomsDialog(injector: VocabIdiomsPageInjector(lessonModel));
      }
    }

    if(segment is GrammarSegmentModel){
      if(segment.grammarList.length > 1){
        dialog = SelectGrammarDialog(lessonModel: lessonModel);
      }
    }

    if(segment is ReadingSegmentModel){
      if(segment.readingList.length > 1){
        dialog = SelectReadingDialog(lessonModel: lessonModel);
      }
    }

    if(segment is ListeningSegmentModel){
      if(segment.listeningList.length > 1){
        dialog = SelectListeningDialog(lessonModel: lessonModel);
      }
    }

    if(dialog != null){
      final view = OverlayScreenView(
        content: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: (){
            AppOverlay.hideDialog(context);
          },
          child: GestureDetector(
            onTap: (){},
            child: SizedBox.expand(
                child: dialog
            ),
          ),
        ),
        backgroundColor: Colors.black26,
      );

      AppOverlay.showDialogScreen(context, view, canBack: true);
      return;
    }

    Widget? page;

    if(segment is VocabularySegmentModel){
      page = VocabPage(injector: VocabIdiomsPageInjector(lessonModel));
    }
    else if (segment is GrammarSegmentModel){
      page = GrammarPage(injector: GrammarPageInjector(lessonModel));
    }
    else if (segment is ReadingSegmentModel){
      page = ReadingPage(injector: ReadingPageInjector(lessonModel));
    }
    else if (lessonModel.listeningModel != null && lessonModel.listeningModel!.listeningList.isNotEmpty){
      page = ListeningPage(injector: ListeningPageInjector(lessonModel, lessonModel.listeningModel!.listeningList[0].id));
    }

    if(page != null) {
      RouteTools.pushPage(context, page);
    }
  }

  bool isOpen(LessonModel model){
    return openedLessonsIds.contains(model.id);
  }

  void onLessonClick(LessonModel model){
    if(model.isLock){
      AppToast.showToast(context, 'این درس خریداری نشده است. به فروشگاه مراجعه کنید.');
      return;
    }

    if(openedLessonsIds.contains(model.id)){
      openedLessonsIds.remove(model.id);
    }
    else {
      openedLessonsIds.add(model.id);
    }

    assistCtr.updateHead();
  }

  void onSearch(String text){
    lessons.clear();

    if(text.length < 2){
      lessons.addAll(lessonsBackup);
    }
    else {
      lessons.addAll(lessonsBackup.where((element) => element.title.contains(text)));
    }

    assistCtr.updateHead();
  }

  void onTryAgain(){
    assistCtr.clearStates();
    assistCtr.addStateAndUpdateHead(state$loading);
    requestLessons();
  }

  void requestLessons(){
    lessons.clear();

    requester.httpRequestEvents.onFailState = (req, res) async {
      assistCtr.clearStates();
      assistCtr.addStateAndUpdateHead(state$error);
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      assistCtr.clearStates();

      final List? data = res['data'];

      if(data is List){
        for(final k in data){
          final les = LessonModel.fromMap(k);
          lessons.add(les);
        }
      }

      lessonsBackup.addAll(lessons);
      assistCtr.updateHead();
    };

    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: '/lessons?CourseLevelId=${SessionService.getLastLoginUser()?.courseLevel?.id}');
    requester.request(context);
  }

  void requestExams(LessonModel lessonModel){
    requester.httpRequestEvents.onAnyState = (req) async {
      await hideLoading();
    };

   requester.httpRequestEvents.onFailState = (req, res) async {
     AppSheet.showSheetNotice(context, AppMessages.errorCommunicatingServer);
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      final data = res['data'];

      if(data is Map){
        final List quizzes = data['quizzes']?? [];
        final List autodidacts = data['autodidacts']?? [];

        List<ExamModel> examList = [];
        List<AutodidactModel> autodidactList = [];

        for (final k in quizzes) {
          final exam = ExamModel.fromMap(k);
          examList.add(exam);
        }

        for (final k in autodidacts) {
          final exam = AutodidactModel.fromMap(k);
          autodidactList.add(exam);
        }

        if(quizzes.isNotEmpty || autodidacts.isNotEmpty){
          final examPageInjector = ExamBuilderContent();
          examPageInjector.prepareExamList(examList);
          examPageInjector.setAutodidacts(autodidactList);
          examPageInjector.answerUrl = '/quiz/solving';

          final examPage = ExamPage(builder: examPageInjector);

          RouteTools.pushPage(context, examPage);
        }
        else {
          AppSheet.showSheetNotice(context, 'آزمونی ثبت نشده است');
        }
      }
    };

    showLoading();
    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: '/quizzes?LessonId=${lessonModel.id}');
    requester.request(context);
  }

  void requesterSupport(LessonModel lesson) async {
    final user = SessionService.getLastLoginUser();
    final rt = IrisRuntimeCache.find(AppStoreScope.user$supportTime, user!.userId);

    if(rt == null || !rt.isUpdate()){
      showLoading();
      final userTime = await ApiManager.requestUserRemainingMinutes(user.userId);
      await hideLoading();

      if(userTime == null){
        AppSnack.showSnack$OperationFailed(context);
        return;
      }
    }

    final page = TimetablePage(
        lesson: lesson,
        maxUserTime: IrisRuntimeCache.find(AppStoreScope.user$supportTime, user.userId)!.value
    );

    RouteTools.pushPage(context, page);
  }
}
