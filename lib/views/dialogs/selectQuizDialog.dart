import 'package:app/pages/exam_page.dart';
import 'package:app/structures/injectors/examPageInjector.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/examModels/examModel.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/customCard.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/enums/appAssistKeys.dart';
import 'package:app/structures/models/lessonModels/lessonModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appDecoration.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/routeTools.dart';

class SelectQuizDialog extends StatefulWidget {
  final LessonModel lessonModel;

  const SelectQuizDialog({
    required this.lessonModel,
    Key? key
  }) : super(key: key);

  @override
  State createState() => _SelectReadingDialog();
}
///=================================================================================================
class _SelectReadingDialog extends StateBase<SelectQuizDialog> {
  Requester requester = Requester();

  @override
  void dispose(){
    requester.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
      groupIds: [AppAssistKeys.updateOnLessonChange],
      builder: (_, __, data) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(25)),
              child: ColoredBox(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(AppImages.lessonListIco),
                          const SizedBox(width: 10),
                          Text(widget.lessonModel.title).bold().fsR(3),
                        ],
                      ),

                      const SizedBox(height: 10),
                      Chip(
                          label: const Text('آزمون').bold().color(Colors.white),
                          labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                          visualDensity: VisualDensity.compact
                      ),

                      const SizedBox(height: 10),
                      Image.asset(AppImages.doutar),
                      const SizedBox(height: 10),

                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: widget.lessonModel.quizSegment!.categories.length,
                            itemBuilder: buildList
                        ),
                      ),

                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  Widget buildList(_, int idx){
    final itm = widget.lessonModel.quizSegment!.categories[idx];

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        requestExam(itm.id);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints.tightFor(width: 100),
          child: CustomCard(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SizedBox(
                width: 100,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    CustomCard(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                        radius: 12,
                        child: Image.asset(AppImages.micBlack, width: 24, height: 24, color: AppDecoration.red)
                    ),

                    const SizedBox(height: 15),
                    Text('« ${itm.title} »', maxLines: 1),

                    const SizedBox(height: 8),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.greenAccent.withAlpha(40),
                            color: Colors.greenAccent,
                            value: itm.progress /100,
                            minHeight: 3,
                          ),
                        )
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
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
}
