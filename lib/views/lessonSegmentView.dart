import 'package:app/models/lessonModels/iSegmentModel.dart';
import 'package:app/models/lessonModels/lessonModel.dart';
import 'package:app/models/lessonModels/lessonVocabularyModel.dart';
import 'package:app/pages/idiomsSegmentPage.dart';
import 'package:app/pages/vocabSegmentPage.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/views/customCard.dart';
import 'package:flutter/material.dart';

class LessonSegmentViewInjection {
  late LessonModel lessonModel;
  late ISegmentModel segment;
}

class LessonSegmentView extends StatefulWidget {
  final LessonSegmentViewInjection injection;

  const LessonSegmentView({
    required this.injection,
    Key? key
  }) : super(key: key);

  @override
  State<LessonSegmentView> createState() => _LessonSegmentViewState();
}

class _LessonSegmentViewState extends State<LessonSegmentView> {
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
                      label: Text(widget.injection.segment.title).bold().color(Colors.white),
                      labelPadding: EdgeInsets.symmetric(horizontal: 10),
                      visualDensity: VisualDensity.compact
                  ),

                  SizedBox(height: 10),
                  Image.asset(AppImages.doutar),
                  SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: (){
                              final inject = VocabSegmentPageInjector();
                              inject.lessonModel = widget.injection.lessonModel;
                              inject.segment = widget.injection.segment as LessonVocabularyModel;

                              AppRoute.push(context, VocabSegmentPage(injection: inject));
                            },
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
                                  Text('« بخش اول »'),
                                  SizedBox(height: 10),
                                  Text('کلمات').bold(),
                                  SizedBox(height: 15),
                                ],
                              ),
                            ),
                          )
                      ),

                      SizedBox(width: 10),

                      Expanded(
                          child: GestureDetector(
                            onTap: (){
                              final inject = IdiomsSegmentPageInjector();
                              inject.lessonModel = widget.injection.lessonModel;
                              inject.segment = widget.injection.segment;

                              AppRoute.push(context, IdiomsSegmentPage(injection: inject));
                            },
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
                                  Text('« بخش دوم »'),
                                  SizedBox(height: 10),
                                  Text('اصطلاحات').bold(),
                                  SizedBox(height: 15),
                                ],
                              ),
                            ),
                          )
                      ),
                    ],
                  ),

                  SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}