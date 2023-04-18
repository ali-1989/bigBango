import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/customCard.dart';

import 'package:app/pages/reading_page.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/enums/appAssistKeys.dart';
import 'package:app/structures/injectors/readingPagesInjector.dart';
import 'package:app/structures/models/lessonModels/lessonModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/routeTools.dart';

class SelectReadingDialog extends StatefulWidget {
  final LessonModel lessonModel;

  const SelectReadingDialog({
    required this.lessonModel,
    Key? key
  }) : super(key: key);

  @override
  State createState() => _SelectReadingDialog();
}
///=================================================================================================
class _SelectReadingDialog extends StateBase<SelectReadingDialog> {

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
      groupIds: [AppAssistKeys.updateOnLessonChange],
      builder: (_, __, data) {
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
                          Text(widget.lessonModel.title).bold().fsR(3),
                        ],
                      ),

                      SizedBox(height: 10),
                      Chip(
                          label: Text('خواندن').bold().color(Colors.white),
                          labelPadding: EdgeInsets.symmetric(horizontal: 10),
                          visualDensity: VisualDensity.compact
                      ),

                      SizedBox(height: 10),
                      Image.asset(AppImages.doutar),
                      SizedBox(height: 10),

                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: widget.lessonModel.readingModel!.readingList.length,
                            itemBuilder: buildList
                        ),
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
    );
  }

  Widget buildList(_, int idx){
    final itm = widget.lessonModel.readingModel!.readingList[idx];

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        RouteTools.pushPage(context, ReadingPage(injector: ReadingPageInjector(widget.lessonModel, index: idx)));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ConstrainedBox(
          constraints: BoxConstraints.tightFor(width: 100),
          child: CustomCard(
            color: Colors.grey.shade300,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SizedBox(
                width: 92,
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    CustomCard(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 11),
                        radius: 14,
                        child: Image.asset(AppImages.speakerIco, width: 25, color: AppColors.red,)
                    ),
                    SizedBox(height: 15),
                    Text('« ${itm.title} »', maxLines: 2,),

                    SizedBox(height: 8),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.greenAccent.withAlpha(40),
                            color: Colors.greenAccent,
                            value: itm.progress/100,
                            minHeight: 3,
                          ),
                        )
                    ),
                    SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
