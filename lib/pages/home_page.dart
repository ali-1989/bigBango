import 'package:app/models/abstract/stateBase.dart';
import 'package:app/models/lessonModels/grammarModel.dart';
import 'package:app/models/lessonModels/iSegmentModel.dart';
import 'package:app/models/lessonModels/lessonModel.dart';
import 'package:app/models/lessonModels/lessonVocabularyModel.dart';
import 'package:app/pages/grammarPage.dart';
import 'package:app/pages/select_language_level_page.dart';
import 'package:app/pages/vocabSegmentPage.dart';
import 'package:app/system/requester.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appOverlay.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/views/widgets/customCard.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:app/views/components/lessonSegmentView.dart';
import 'package:app/views/states/waitToLoad.dart';
import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/features/overlayDialog.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/searchBar.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => HomePageState();
}
///===================================================================================================================
class HomePageState extends StateBase<HomePage> {
  List<LessonModel> lessons = [];
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
      builder: (_, ctr, data) {
        if(assistCtr.hasState(state$error)){
          return ErrorOccur(
            onRefresh: onRefresh,
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
                              child: GestureDetector(
                                onTap: (){
                                  AppRoute.push(context, SelectLanguageLevelPage());
                                },
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
                            ),

                            Positioned(
                              bottom: 5,
                              left: 0,
                              right: 0,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: SearchBar(
                                  hint: 'جستجو در دروس',
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
                  const SizedBox(
                    width: 1.5,
                    height: 20,
                    child: ColoredBox(
                      color: Colors.red,
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
      color: Colors.red,
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
                      const SizedBox(
                        width: 1.5,
                        height: 20,
                        child: ColoredBox(
                          color: Colors.red,
                        ),
                      ),

                      const SizedBox(width: 12),
                      Card(
                          elevation: 0,
                          color: Colors.red,
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

                        SizedBox(
                          height: 2,
                          width: double.infinity,
                          child: ColoredBox(
                              color: Colors.grey.shade200
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          child: Row(
                            children: [
                              buildSegment(lesson, lesson.vocabModel ?? lesson.grammarModel),

                              SizedBox(width: 8),

                              buildSegment(lesson, lesson.vocabModel != null ? lesson.grammarModel : null),
                            ],
                          ),
                        ),

                        const SizedBox(width: 7),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          child: Row(
                            children: [
                              buildSegment(lesson, lesson.readingModel ?? lesson.speakingModel),

                              SizedBox(width: 8),

                              buildSegment(lesson, lesson.readingModel != null ? lesson.speakingModel : null),
                            ],
                          ),
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
                                    ],
                                  )
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: (){},
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

  void onLessonSegmentClick(LessonModel lesson, ISegmentModel section){
    Widget page = SizedBox();

    if(section is LessonVocabularyModel){
      if(!section.hasIdioms){
        final inject = VocabSegmentPageInjector();
        inject.lessonModel = lesson;
        inject.segment = section;

        AppRoute.push(context, VocabSegmentPage(injection: inject));
        return;
      }

      final inject = LessonSegmentViewInjection();
      inject.lessonModel = lesson;
      inject.segment = section;

      page = LessonSegmentView(injection: inject);
    }
    else if (section is GrammarModel){
      final inject = GrammarPageInjector();
      inject.lessonModel = lesson;
      inject.segment = section;

      page = GrammarPage(injection: inject);
    }


    final view = OverlayScreenView(
      content: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          AppOverlay.hideScreen(context);
        },
        child: GestureDetector(
          onTap: (){},
          child: SizedBox.expand(
              child: page
          ),
        ),
      ),
      backgroundColor: Colors.black26,
    );
    AppOverlay.showScreen(context, view, canBack: true);
  }

  bool isOpen(LessonModel model){
    return openedLessonsIds.contains(model.id);
  }

  void onLessonClick(LessonModel model){
    if(model.isLock){
      return;
    }

    if(openedLessonsIds.contains(model.id)){
      openedLessonsIds.remove(model.id);
    }
    else {
      openedLessonsIds.add(model.id);
    }

    assistCtr.updateMain();
  }

  void onRefresh(){
    assistCtr.removeState(state$error);
    assistCtr.addStateAndUpdate(state$loading);
    requestLessons();
  }

  void requestLessons(){

    requester.httpRequestEvents.onFailState = (req, res) async {
      assistCtr.clearStates();
      assistCtr.addStateAndUpdate(state$error);
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      assistCtr.clearStates();
      lessons.clear();

      final List? data = res['data'];

      if(data is List){
        for(final k in data){
          final les = LessonModel.fromMap(k);
          lessons.add(les);
        }
      }

      assistCtr.updateMain();
    };

    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: '/lessons?CourseLevelId=${Session.getLastLoginUser()?.courseLevelId}');
    requester.request(context);
  }
}


/*Row(
                            children: [
                              const SizedBox(width: 15),
                              Image.asset(AppImages.clockIco, width: 16, height: 16),
                              const SizedBox(width: 6),
                              const Text('اخیرا مطالعه شده', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),*/

/*Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: ColoredBox(
                                color: Colors.grey.withAlpha(50),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: SizedBox(
                                      height: 100,
                                      child: Row(
                                        children: [
                                            Expanded(
                                                child: Card(
                                                  color: Colors.white,
                                                  elevation: 0,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.max,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        const Text('عنوان درس'),

                                                        Directionality(
                                                          textDirection: TextDirection.ltr,
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              const Text('30 %', style: TextStyle(fontSize: 12),),

                                                              const SizedBox(height: 4),
                                                              LinearProgressIndicator(
                                                                backgroundColor: Colors.greenAccent.withAlpha(40),
                                                                color: Colors.greenAccent,
                                                                value: 0.3,
                                                                minHeight: 3,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                            ),

                                          Expanded(
                                              child: Card(
                                                color: Colors.white,
                                                elevation: 0,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.max,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      const Text('عنوان درس'),

                                                      Directionality(
                                                        textDirection: TextDirection.ltr,
                                                       child: Column(
                                                         crossAxisAlignment: CrossAxisAlignment.start,
                                                         children: [
                                                           const Text('30 %', style: TextStyle(fontSize: 12),),

                                                           const SizedBox(height: 4),
                                                           LinearProgressIndicator(
                                                             backgroundColor: Colors.greenAccent.withAlpha(40),
                                                             color: Colors.greenAccent,
                                                             value: 0.3,
                                                             minHeight: 3,
                                                           ),
                                                         ],
                                                       ),
                                                     ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),*/
