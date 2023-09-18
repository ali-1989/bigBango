import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/custom_card.dart';

import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/enums/assist_groups.dart';
import 'package:app/structures/injectors/readingPagesInjector.dart';
import 'package:app/structures/models/lessonModels/lessonModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/views/pages/reading_page.dart';

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
class _SelectReadingDialog extends StateSuper<SelectReadingDialog> {

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
      groupIds: [AssistGroup.updateOnLessonChange],
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
                          label: const Text('خواندن').bold().color(Colors.white),
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
                          itemCount: widget.lessonModel.readingSegment!.categories.length,
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
    final itm = widget.lessonModel.readingSegment!.categories[idx];

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        final page = ReadingPage(injector: ReadingPageInjector(widget.lessonModel, categoryId: itm.id));

        RouteTools.pushPage(context, page);
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
                        child: Image.asset(AppImages.readingIco, width: 24, height: 24, color: AppDecoration.red,)
                    ),

                    const SizedBox(height: 15),
                    Text('« ${itm.title} »', maxLines: 2).fitWidthOverflow(minOfFontSize: 12),

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
}
