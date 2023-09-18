import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/customCard.dart';
import 'package:slide_switcher/slide_switcher.dart';

import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/enums/assist_groups.dart';
import 'package:app/structures/injectors/vocabPagesInjector.dart';
import 'package:app/structures/models/lessonModels/lessonModel.dart';
import 'package:app/structures/models/lessonModels/vocabSegmentModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/views/pages/idioms_page.dart';
import 'package:app/views/pages/vocab_page.dart';

class SelectVocabIdiomsDialog extends StatefulWidget {
  final LessonModel lessonModel;
  final VocabularySegmentModel segmentModel;

  const SelectVocabIdiomsDialog({
    required this.lessonModel,
    required this.segmentModel,
    Key? key
  }) : super(key: key);

  @override
  State createState() => _SelectVocabIdiomsDialog();
}
///=================================================================================================
class _SelectVocabIdiomsDialog extends StateSuper<SelectVocabIdiomsDialog> {
  List<Widget> items = [];
  int currentTabIndex = 0;

  @override
  void initState(){
    super.initState();

    genListItems();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
        controller: assistCtr,
        isHead: true,
        groupIds: const [AssistGroup.updateOnLessonChange],
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

                      /// tab section
                      const SizedBox(height: 10),
                      buildSelectorTab(),

                      const SizedBox(height: 10),
                      Image.asset(AppImages.doutar),
                      const SizedBox(height: 10),

                      /// content
                      SizedBox(
                        height: 110,
                        child: ListView(
                          key: ValueKey('$currentTabIndex'),
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          children: items,
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

  Widget buildSelectorTab() {
    if(widget.segmentModel.idiomCategories.isEmpty){
      return Chip(
          label: Text(widget.segmentModel.title).bold().color(Colors.white),
          labelPadding: const EdgeInsets.symmetric(horizontal: 10),
          visualDensity: VisualDensity.compact
      );
    }

    if(widget.segmentModel.vocabularyCategories.isEmpty){
      return Chip(
          label: const Text('اصطلاحات').bold().color(Colors.white),
          labelPadding: const EdgeInsets.symmetric(horizontal: 10),
          visualDensity: VisualDensity.compact
      );
    }

    return SizedBox(
      width: 200,
      child: SlideSwitcher(
        onSelect: (index) {
          currentTabIndex = index;
          genListItems();
          assistCtr.updateHead();
        },
        containerColor: AppDecoration.mainColor,
        slidersColors: [Colors.grey.shade400],
        containerHeight: 34,
        containerWight: 200,
        indents: 0,
        children: [
          const Text('واژه آموزی').bold().color(Colors.white),
          const Text('اصطلاحات').bold().color(Colors.white),
        ],

      ),
    );
  }

  void genListItems(){
    items.clear();
    List list = currentTabIndex == 0? widget.segmentModel.vocabularyCategories : widget.segmentModel.idiomCategories;

    for(final itm in list){
      final w = GestureDetector(
        onTap: (){
          final injector = VocabIdiomsPageInjector(widget.lessonModel, itm.id);

          Widget page;

          if(currentTabIndex == 1){
            page = IdiomsPage(injector: injector);
          }
          else {
            page = VocabPage(injector: injector);
          }

          RouteTools.pushPage(context, page);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: SizedBox(
            width: 120,
            child: CustomCard(
              color: Colors.grey.shade300,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 30,
                    width: 32,
                    child: CustomCard(
                        padding: const EdgeInsets.all(6),
                        radius: 12,
                        child: Image.asset(currentTabIndex == 0? AppImages.abcIco : AppImages.messageIco)
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text('« ${itm.title} »', maxLines: 2).fitWidthOverflow(minOfFontSize: 12),
                  /*const SizedBox(height: 10),
                  const Text('اصطلاحات').bold(),*/

                  const SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.greenAccent.withAlpha(40),
                        color: Colors.greenAccent,
                        value: itm.progress.toDouble(),
                        minHeight: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      );

      items.add(w);
    }
  }
}
