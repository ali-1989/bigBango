import 'dart:math';

import 'package:flutter/material.dart';

import 'package:extended_sliver/extended_sliver.dart';
import 'package:iris_runtime_cache/iris_runtime_cache.dart';
import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/features/overlayDialog.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/custom_card.dart';
import 'package:iris_tools/widgets/iris_search_bar.dart';

import 'package:app/managers/api_manager.dart';
import 'package:app/services/session_service.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/enums/appStoreScope.dart';
import 'package:app/structures/enums/assist_groups.dart';
import 'package:app/structures/injectors/examPageInjector.dart';
import 'package:app/structures/injectors/grammarPagesInjector.dart';
import 'package:app/structures/injectors/listeningPagesInjector.dart';
import 'package:app/structures/injectors/readingPagesInjector.dart';
import 'package:app/structures/injectors/vocabPagesInjector.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/examModels/examModel.dart';
import 'package:app/structures/models/lessonModels/grammarSegmentModel.dart';
import 'package:app/structures/models/lessonModels/iSegmentModel.dart';
import 'package:app/structures/models/lessonModels/lessonModel.dart';
import 'package:app/structures/models/lessonModels/listeningSegmentModel.dart';
import 'package:app/structures/models/lessonModels/readingSegmentModel.dart';
import 'package:app/structures/models/lessonModels/speakingSegmentModel.dart';
import 'package:app/structures/models/lessonModels/vocabSegmentModel.dart';
import 'package:app/structures/models/lessonModels/writingSegmentModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_overlay.dart';
import 'package:app/tools/app/app_sheet.dart';
import 'package:app/tools/app/app_snack.dart';
import 'package:app/tools/app/app_toast.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/views/dialogs/selectGrammarDialog.dart';
import 'package:app/views/dialogs/selectListeningDialog.dart';
import 'package:app/views/dialogs/selectQuizDialog.dart';
import 'package:app/views/dialogs/selectReadingDialog.dart';
import 'package:app/views/dialogs/selectSpeakingDialog.dart';
import 'package:app/views/dialogs/selectVocabIdiomsDialog.dart';
import 'package:app/views/dialogs/selectWritingDialog.dart';
import 'package:app/views/pages/exam_page.dart';
import 'package:app/views/pages/grammar_page.dart';
import 'package:app/views/pages/idioms_page.dart';
import 'package:app/views/pages/listening_page.dart';
import 'package:app/views/pages/reading_page.dart';
import 'package:app/views/pages/speaking_page.dart';
import 'package:app/views/pages/timetable_page.dart';
import 'package:app/views/pages/vocab_page.dart';
import 'package:app/views/pages/writing_page.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:app/views/states/waitToLoad.dart';

class HomePage extends StatefulWidget {
  static String id$homePageHead = '${identityHashCode(HomePage)}_head';

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => HomePageState();
}
///===================================================================================================================
class HomePageState extends StateSuper<HomePage> {
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
      groupIds: const [AssistGroup.updateOnLessonChange],
      builder: (_, ctr, data) {
        if(assistCtr.hasState(state$error)){
          return ErrorOccur(
            onTryAgain: onTryAgain,
          );
        }

        if(assistCtr.hasState(state$loading)){
          return const WaitToLoad();
        }

        return Column(
          children: [
            SizedBox(height: 60 * hr),

            Expanded(
                child: CustomScrollView(
                  slivers: [
                    ExtendedSliverAppbar(
                      toolbarHeight: 70*hr,
                      toolBarColor: Colors.transparent,
                      isOpacityFadeWithTitle: true,
                      isOpacityFadeWithToolbar: false,
                      actions: const SizedBox(),
                      leading: const SizedBox(),
                      background: SizedBox(
                        height: 210 * hr,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Positioned(
                              bottom: 30*hr,
                              left: 0,
                              right: 0,
                              child: Image.asset(AppImages.homeBackground,
                              fit: BoxFit.fill,
                            ),
                            ),

                            Positioned(
                              top: 14 * hr,
                              left: 25 *hr,
                              right: 25 *hr,
                              child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 30 * hr),
                              child: Image.asset(AppImages.homeBackIcons, height: 90 *hr,
                                fit: BoxFit.contain,
                              ),
                            ),
                            ),

                            Positioned(
                              bottom: 68 * hr,
                              left: 0,
                              right: 0,
                              child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 30),
                              child: Center(
                                  child: CustomCard(
                                      color: Colors.white,
                                      padding: const EdgeInsets.fromLTRB(5, 3, 5, 1),
                                      child: RichText(
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
                              bottom: 5 *hr,
                              left: 0,
                              right: 0,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20 *hr),
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
    return Padding(
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
    );
  }

  Widget buildFirstStateOfLesson(LessonModel lesson){
    return ColoredBox(
      color: Colors.grey.withAlpha(50),
      child: GestureDetector(
        onTap: (){
          onLessonClick(lesson);
        },
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
                     const SizedBox(
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

                    /// title
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 5),
                        child: Text(lesson.title, maxLines: 1),
                      ),
                    ),

                    Builder(
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
                              Text('${lesson.improvementPercentage} %', maxLines: 1, style: const TextStyle(fontSize: 12)),

                              const SizedBox(height: 4),
                              SizedBox(
                                width: 35,
                                child: LinearProgressIndicator(
                                  backgroundColor: Colors.greenAccent.withAlpha(40),
                                  color: Colors.greenAccent,
                                  value: lesson.improvementPercentage/100,
                                  minHeight: 3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text('پیشرفت' , maxLines: 1, style: TextStyle(fontSize: 10)),
                            ],
                          ),
                        );
                      }
                    ),

                    const SizedBox(width: 4),
                    Card(
                        elevation: 0,
                        color: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        child: GestureDetector(
                          onTap: (){
                            onLessonDescriptionClick(lesson);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                            child: Icon(
                                AppIcons.info,
                                size: 16,
                                color: lesson.description == null? Colors.grey.shade400 : Colors.black,
                            ),
                          ),
                        ),
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> genLessonItems(LessonModel lesson){
    final res = <Widget>[];

    bool hasVocab1 = lesson.vocabSegment?.vocabularyCategories.isNotEmpty ?? false;
    bool hasVocab2 = lesson.vocabSegment?.idiomCategories.isNotEmpty ?? false;

    if( hasVocab1 || hasVocab2){
      res.add(buildSegmentView(lesson, lesson.vocabSegment));
    }

    if(lesson.grammarSegment?.categories.isNotEmpty?? false){
      res.add(buildSegmentView(lesson, lesson.grammarSegment));
    }

    if(lesson.readingSegment?.categories.isNotEmpty?? false){
      res.add(buildSegmentView(lesson, lesson.readingSegment));
    }

    if(lesson.listeningSegment?.listeningList.isNotEmpty?? false){
      res.add(buildSegmentView(lesson, lesson.listeningSegment));
    }

   if(lesson.writingSegment?.categories.isNotEmpty?? false){
      res.add(buildSegmentView(lesson, lesson.writingSegment));
    }

    if(lesson.speakingSegment?.categories.isNotEmpty?? false){
      res.add(buildSegmentView(lesson, lesson.speakingSegment));
    }

    return res;
  }

  Widget buildSecondStateOfLesson(LessonModel lesson){
    List<Widget> lessonItems = genLessonItems(lesson);

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

                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: (){
                      onLessonClick(lesson);
                    },
                    child: Row(
                      children: [
                        const SizedBox(
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

                        /// title
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 5),
                            child: Text(lesson.title, maxLines: 1,),
                          ),
                        ),

                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${lesson.improvementPercentage} %', maxLines: 1, style: const TextStyle(fontSize: 12),),

                              const SizedBox(height: 4),
                              SizedBox(
                                width: 35,
                                child: LinearProgressIndicator(
                                  backgroundColor: Colors.greenAccent.withAlpha(40),
                                  color: Colors.greenAccent,
                                  value: lesson.improvementPercentage/100,
                                  minHeight: 3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text('پیشرفت', maxLines: 1, style: TextStyle(fontSize: 10)),
                            ],
                          ),
                        ),

                        const SizedBox(width: 4),
                        Card(
                          elevation: 0,
                          color: Colors.grey.shade100,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          child: GestureDetector(
                            onTap: (){
                              onLessonDescriptionClick(lesson);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                              child: Icon(
                                AppIcons.info,
                                size: 16,
                                color: lesson.description == null? Colors.grey.shade400 : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
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

                        const SizedBox(height: 10),

                        /*SizedBox(
                          width: double.infinity,
                          child: Wrap(
                            spacing: 7,
                            runSpacing: 7,
                            alignment: WrapAlignment.start,
                            runAlignment: WrapAlignment.start,
                            crossAxisAlignment: WrapCrossAlignment.start,
                            direction: Axis.horizontal,
                            children: lessonItems,
                          ),
                        ),*/

                        GridView.builder(
                          key: ValueKey(Generator.generateKey(5)),
                          shrinkWrap: true,
                          itemCount: lessonItems.length,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 7.0,
                            mainAxisSpacing: 7.0,
                            mainAxisExtent: 75,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            return lessonItems[index];
                          },
                        ),

                        const SizedBox(height: 8),

                        /// quiz button section
                        Visibility(
                          visible: lesson.quizSegment?.categories.isNotEmpty?? false,
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: (){
                                    onExamClick(lesson);
                                  },
                                child: CustomCard(
                                  color: Colors.grey.shade200,
                                  padding: const EdgeInsets.all(5.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          CustomCard(
                                              color: Colors.white,
                                              padding: const EdgeInsets.all(5),
                                              child: Image.asset(AppImages.examIco)
                                          ),

                                          const SizedBox(width: 10),

                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('آزمون'),
                                              const SizedBox(height: 5),
                                              const Text('Quiz').alpha(alpha: 100),
                                            ],
                                          ),

                                        ],
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: CustomCard(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                            child: Row(
                                              children: [
                                                Image.asset(AppImages.startExercise, height: 18),
                                                const SizedBox(width: 6),

                                                const Text('شروع').fsR(-1),
                                              ],
                                            )
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8),
                            ],
                          ),
                        ),

                        /// support button section
                        SizedBox(
                          width: double.infinity,
                          height: 46,
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
                        ),

                        const SizedBox(height: 5),
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

  Widget buildSegmentView(LessonModel lesson, ISegmentModel? segmentModel){
    if(segmentModel == null){
      return const SizedBox();
    }

    return LayoutBuilder(
      builder: (_, siz) {
        return SizedBox(
          width: max(0, (siz.maxWidth/2) -4),
          child: GestureDetector(
            onTap: (){
              onLessonSegmentClick(lesson, segmentModel);
            },
            child: Stack(
              children: [
                CustomCard(
                  color: Colors.grey.shade200,
                  padding: const EdgeInsets.fromLTRB(5.0, 5, 5, 5),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CustomCard(
                              color: Colors.white,
                              padding: const EdgeInsets.all(5),
                              child: Image.asset(segmentModel.icon)
                          ),

                          const SizedBox(width: 10),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(segmentModel.title),
                              const SizedBox(height: 5),
                              Text(segmentModel.engTitle).alpha(alpha: 100).fsR(-1),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      Visibility(
                        visible: segmentModel.progress != null,
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.greenAccent.withAlpha(40),
                            color: Colors.greenAccent,
                            value: (segmentModel.progress?? 100) /100,
                            minHeight: 3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  bottom: 6,
                  left: 5,
                  child: Visibility(
                    visible: segmentModel.progress != null,
                      child: Text('${segmentModel.progress} %').fsR(-1)
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  void onLessonSegmentClick(LessonModel lessonModel, ISegmentModel segment){
    Widget? dialog;

    if(segment is VocabularySegmentModel){
      if(segment.idiomCategories.isNotEmpty && segment.vocabularyCategories.isNotEmpty){
        dialog = SelectVocabIdiomsDialog(lessonModel :lessonModel, segmentModel: segment);
      }

      if(segment.vocabularyCategories.length > 1){
        dialog = SelectVocabIdiomsDialog(lessonModel :lessonModel, segmentModel: segment);
      }

      if(segment.idiomCategories.length > 1){
        dialog = SelectVocabIdiomsDialog(lessonModel :lessonModel, segmentModel: segment);
      }
    }

    if(segment is GrammarSegmentModel){
      if(segment.categories.length > 1){
        dialog = SelectGrammarDialog(lessonModel: lessonModel);
      }
    }

    if(segment is ReadingSegmentModel){
      if(segment.categories.length > 1){
        dialog = SelectReadingDialog(lessonModel: lessonModel);
      }
    }

    if(segment is ListeningSegmentModel){
      if(segment.listeningList.length > 1){
        dialog = SelectListeningDialog(lessonModel: lessonModel);
      }
    }

    if(segment is WritingSegmentModel){
      if(segment.categories.length > 1){
        dialog = SelectWritingDialog(lessonModel: lessonModel);
      }
    }

    if(segment is SpeakingSegmentModel){
      if(segment.categories.length > 1){
        dialog = SelectSpeakingDialog(lessonModel: lessonModel);
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
     if(segment.vocabularyCategories.isNotEmpty){
       page = VocabPage(injector: VocabIdiomsPageInjector(lessonModel, segment.vocabularyCategories.first.id));
     }

     page = IdiomsPage(injector: VocabIdiomsPageInjector(lessonModel, segment.idiomCategories.first.id));
    }
    else if (segment is GrammarSegmentModel){
      page = GrammarPage(injector: GrammarPageInjector(lessonModel));
    }
    else if (segment is ReadingSegmentModel){
      page = ReadingPage(injector: ReadingPageInjector(lessonModel, categoryId: lessonModel.readingSegment!.categories.first.id));
    }
    else if (segment is ListeningSegmentModel && lessonModel.listeningSegment != null && lessonModel.listeningSegment!.listeningList.isNotEmpty){
      page = ListeningPage(injector: ListeningPageInjector(lessonModel, lessonModel.listeningSegment!.listeningList[0].id));
    }
    else if (segment is WritingSegmentModel){
      page = WritingPage(lesson: lessonModel, categoryId: segment.categories.first.id);
    }
    else if (segment is SpeakingSegmentModel){
      page = SpeakingPage(lesson: lessonModel, categoryId: segment.categories.first.id);
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

  void onExamClick(LessonModel lessonModel){
    if(lessonModel.quizSegment!.categories.isEmpty){
      return;
    }

    if(lessonModel.quizSegment!.categories.length < 2){
      requestExam(lessonModel.quizSegment!.categories.first.id);
    }

    final view = OverlayScreenView(
      content: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          AppOverlay.hideDialog(context);
        },
        child: GestureDetector(
          onTap: (){},
          child: SizedBox.expand(
              child: SelectQuizDialog(lessonModel: lessonModel),
          ),
        ),
      ),
      backgroundColor: Colors.black26,
    );

    AppOverlay.showDialogScreen(context, view, canBack: true);
  }

  void requestExam(String categoryId){
    requester.httpRequestEvents.onAnyState = (req) async {
      await hideLoading();
    };

   requester.httpRequestEvents.onFailState = (req, res) async {
     AppSheet.showSheetNotice(context, AppMessages.errorCommunicatingServer);
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      final data = res['data'];

      if(data is List){
        List<ExamModel> examList = [];

        for (final k in data) {
          final exam = ExamModel.fromMap(k);
          examList.add(exam);
        }

        if(examList.isNotEmpty){
          final examPageInjector = ExamPageInjector();
          examPageInjector.prepareExamList(examList);
          examPageInjector.answerUrl = '/quiz/solving';

          final examPage = ExamPage(injector: examPageInjector);

          RouteTools.pushPage(context, examPage);
        }
        else {
          AppSheet.showSheetNotice(context, 'آزمونی ثبت نشده است');
        }
      }
    };

    showLoading();
    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: '/quizzes?CategoryId=$categoryId');
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
        AppSnack.showSnackText(context, AppMessages.operationFailed);
        return;
      }
    }

    final page = TimetablePage(
        lesson: lesson,
        maxUserTime: IrisRuntimeCache.find(AppStoreScope.user$supportTime, user.userId)!.value
    );

    RouteTools.pushPage(context, page);
  }

  void onLessonDescriptionClick(LessonModel lesson) {
    if(lesson.description == null){
      return;
    }

    AppSheet.showSheetCustom(
        context,
        backgroundColor: Colors.transparent,
        contentColor: Colors.transparent,
        builder: (_){
          return ClipRRect(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            child: ColoredBox(
              color: AppDecoration.mainColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('توضیحات\n${lesson.title}', maxLines: 2).color(Colors.white).bold(),

                    const SizedBox(height: 10),

                    ListView(
                      shrinkWrap: true,
                      children: [
                        Text(lesson.description!, textAlign: TextAlign.justify,).color(Colors.white).fsR(-1),

                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('باشه').color(Colors.white)
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      routeName: 'LessonDescription',
        isScrollControlled: true
    );
  }
}
