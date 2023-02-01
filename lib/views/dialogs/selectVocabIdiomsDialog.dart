import 'package:app/structures/injectors/vocabPagesInjector.dart';
import 'package:flutter/material.dart';

import 'package:app/pages/idioms_page.dart';
import 'package:app/pages/vocab_page.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/views/widgets/customCard.dart';


class SelectVocabIdiomsDialog extends StatefulWidget {
  final VocabIdiomsPageInjector injector;

  const SelectVocabIdiomsDialog({
    required this.injector,
    Key? key
  }) : super(key: key);

  @override
  State createState() => _SelectVocabIdiomsDialog();
}
///=================================================================================================
class _SelectVocabIdiomsDialog extends State<SelectVocabIdiomsDialog> {
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
                      Text(widget.injector.lessonModel.title).bold().fsR(3),
                    ],
                  ),

                  SizedBox(height: 10),
                  Chip(
                      label: Text(widget.injector.segment!.title).bold().color(Colors.white),
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
                              AppRoute.push(context, VocabPage(injector: widget.injector));
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
                              AppRoute.push(context, IdiomsPage(injector: widget.injector));
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
