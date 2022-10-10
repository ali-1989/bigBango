import 'dart:math';

import 'package:app/models/abstract/stateBase.dart';
import 'package:app/models/lessonModel.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appOverlay.dart';
import 'package:app/views/customCard.dart';
import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/cupertino.dart';
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
  List<int> openedListIds = [];

  @override
  void initState(){
    super.initState();

    final g = Random();
    List.generate(30, (index) {
      final f = LessonModel();
      f.title = 'عنوان درس';
      f.id = index;
      f.order = index+1;
      f.isLock = g.nextBool();

      lessons.add(f);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
      builder: (ctx, ctr, data) {
        return Column(
          children: [
            const SizedBox(height: 60),

            Expanded(
                child: CustomScrollView(
                  slivers: [
                    ExtendedSliverAppbar(
                      background: SizedBox(
                        height: 210,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Positioned(
                              bottom: 30,
                              left: 0,
                              right: 0,
                              child: Image.asset(AppImages.homeBack,
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
                      toolbarHeight: 70,
                      toolBarColor: Colors.transparent,
                      isOpacityFadeWithTitle: true,
                      isOpacityFadeWithToolbar: false,
                      actions: const SizedBox(),
                      leading: const SizedBox(),
                    ),

                    SliverToBoxAdapter(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 16),
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

                          const SizedBox(height: 5),
                        ],
                      ),
                    ),

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
                              const Text('لیست دروس', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),),
                            ],
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),


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
                        child: Text('${lesson.order}', style: const TextStyle(color: Colors.black)),
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
                              const Text('30 %', style: TextStyle(fontSize: 12),),

                              const SizedBox(height: 4),
                              SizedBox(
                                width: 70,
                                child: LinearProgressIndicator(
                                  backgroundColor: Colors.greenAccent.withAlpha(40),
                                  color: Colors.greenAccent,
                                  value: 0.3,
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
                            child: Text('${lesson.order}', style: const TextStyle(color: Colors.white)),
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
                              const Text('40 %', style: TextStyle(fontSize: 12),),

                              const SizedBox(height: 4),
                              SizedBox(
                                width: 70,
                                child: LinearProgressIndicator(
                                  backgroundColor: Colors.greenAccent.withAlpha(40),
                                  color: Colors.greenAccent,
                                  value: 0.3,
                                  minHeight: 3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text('میزان پیشرفت', style: TextStyle(fontSize: 10),),
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
                              Expanded(
                                  child: GestureDetector(
                                    onTap: (){
                                      onLessonSectionClick(lesson, 'گرامر');
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
                                                      child: Image.asset(AppImages.grammarIco)
                                                  ),

                                                  SizedBox(width: 10),

                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text('گرامر'),
                                                      SizedBox(height: 5),
                                                      Text('Grammar').alpha(alpha: 100),
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
                                                  value: 0.3,
                                                  minHeight: 3,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Positioned(
                                          bottom: 10,
                                            left: 5,
                                            child: Text('32 %'),
                                        ),
                                      ],
                                    ),
                                  )
                              ),

                              SizedBox(width: 8),

                              Expanded(
                                  child: GestureDetector(
                                    onTap: (){
                                      onLessonSectionClick(lesson, 'واژه آموزی');
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
                                                      child: Image.asset(AppImages.abc2Ico)
                                                  ),

                                                  SizedBox(width: 10),

                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text('واژه آموزی'),
                                                      SizedBox(height: 5),
                                                      Text('Vocabulary').alpha(alpha: 100),
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
                                                  value: 0.3,
                                                  minHeight: 3,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Positioned(
                                          bottom: 10,
                                          left: 5,
                                          child: Text('32 %'),
                                        ),
                                      ],
                                    ),
                                  )
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 7),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          child: Row(
                            children: [
                              Expanded(
                                  child: GestureDetector(
                                    onTap: (){
                                      onLessonSectionClick(lesson, 'خواندن');
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
                                                      child: Image.asset(AppImages.readingIco)
                                                  ),

                                                  SizedBox(width: 10),

                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text('خواندن'),
                                                      SizedBox(height: 5),
                                                      Text('Reading').alpha(alpha: 100),
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
                                                  value: 0.3,
                                                  minHeight: 3,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Positioned(
                                          bottom: 10,
                                          left: 5,
                                          child: Text('32 %'),
                                        ),
                                      ],
                                    ),
                                  )
                              ),

                              SizedBox(width: 8),

                              Expanded(
                                  child: GestureDetector(
                                    onTap: (){
                                      onLessonSectionClick(lesson, 'شنیدن');
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
                                                      child: Image.asset(AppImages.speakerIco)
                                                  ),

                                                  SizedBox(width: 10),

                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text('شنیدن'),
                                                      SizedBox(height: 5),
                                                      Text('Speaking').alpha(alpha: 100),
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
                                                  value: 0.3,
                                                  minHeight: 3,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Positioned(
                                          bottom: 10,
                                          left: 5,
                                          child: Text('32 %'),
                                        ),
                                      ],
                                    ),
                                  )
                              ),
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

  void onLessonSectionClick(LessonModel lesson, String section){
    final inject = LessonContentViewInjection();
    inject.lessonModel = lesson;
    inject.section = section;

    final view = OverlayScreenView(
      content: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          AppOverlay.hideScreen(context);
        },
        child: GestureDetector(
          onTap: (){},
          child: SizedBox.expand(
              child: LessonContentView(injection: inject)
          ),
        ),
      ),
      backgroundColor: Colors.black26,
    );
    AppOverlay.showScreen(context, view, canBack: true);
  }

  bool isOpen(LessonModel model){
    return openedListIds.contains(model.id);
  }

  void onLessonClick(LessonModel model){
    if(model.isLock){
      return;
    }

    if(openedListIds.contains(model.id)){
      openedListIds.remove(model.id);
    }
    else {
      openedListIds.add(model.id);
    }

    assistCtr.updateMain();
  }
}
///---------------------------------------------------------------------------------------
class LessonContentViewInjection {
  late LessonModel lessonModel;
  late String section;
}

class LessonContentView extends StatefulWidget {
  final LessonContentViewInjection injection;

  const LessonContentView({
    required this.injection,
    Key? key
  }) : super(key: key);

  @override
  State<LessonContentView> createState() => _LessonContentViewState();
}

class _LessonContentViewState extends State<LessonContentView> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(25)),
          child: ColoredBox(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(AppImages.lessonListIco),
                      SizedBox(width: 10),
                      Text(widget.injection.lessonModel.title).bold().fsR(3),
                    ],
                  ),

                  SizedBox(height: 10),
                  Chip(
                      label: Text(widget.injection.section).bold().color(Colors.white),
                      labelPadding: EdgeInsets.symmetric(horizontal: 10),
                      visualDensity: VisualDensity.compact
                  ),

                  SizedBox(height: 10),
                  Image.asset(AppImages.doutar),
                  SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                          child: CustomCard(
                            color: Colors.grey.shade300,
                            child: Column(
                              children: [
                                SizedBox(height: 10),
                                CustomCard(
                                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 11),
                                    radius: 14,
                                    child: Image.asset(AppImages.abcIco, width: 25)
                                ),
                                SizedBox(height: 15),
                                Text('<< بخش اول >>'),
                                SizedBox(height: 10),
                                Text('کلمات').bold(),
                                SizedBox(height: 15),
                              ],
                            ),
                          )
                      ),

                      SizedBox(width: 10),

                      Expanded(
                          child: CustomCard(
                            color: Colors.grey.shade300,
                            child: Column(
                              children: [
                                SizedBox(height: 10),
                                CustomCard(
                                  padding: EdgeInsets.all(6),
                                    radius: 14,
                                    child: Image.asset(AppImages.messageIco)
                                ),
                                SizedBox(height: 15),
                                Text('<< بخش دوم >>'),
                                SizedBox(height: 10),
                                Text('اصطلاحات').bold(),
                                SizedBox(height: 15),
                              ],
                            ),
                          )
                      ),
                    ],
                  ),

                  SizedBox(height: 15),
                  CustomCard(
                    color: Colors.grey.shade300,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        children: [
                          CustomCard(
                            padding: EdgeInsets.all(6),
                            radius: 12,
                            child: Image.asset(AppImages.exerciseIco),
                          ),

                          SizedBox(width: 10),
                          Text('<< تمرین >>')
                        ],
                      )
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

