import 'package:app/models/abstract/stateBase.dart';
import 'package:app/models/lessonModels/iSegmentModel.dart';
import 'package:app/models/lessonModels/lessonModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/requester.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appNavigator.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/views/customCard.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:simple_html_css/simple_html_css.dart';

class VocabSegmentPageInjector {
  late LessonModel lessonModel;
  late ISegmentModel segment;
}
///-----------------------------------------------------
class VocabSegmentPage extends StatefulWidget {
  final VocabSegmentPageInjector injection;

  const VocabSegmentPage({
    required this.injection,
    Key? key
  }) : super(key: key);

  @override
  State<VocabSegmentPage> createState() => _VocabSegmentPageState();
}
///======================================================================================================================
class _VocabSegmentPageState extends StateBase<VocabSegmentPage> {
  String htmlText = '';
  bool showTranslate = false;
  Requester requester = Requester();
  String state$loading = 'state_loading';
  String state$error = 'state_error';

  @override
  void initState(){
    super.initState();

    requesVocabs();

    htmlText = '''
    <body>
    <p>verb (used with object)</p>
    <p><strong>1 ali bagheri is very good:</strong></p>
    <p><span style="color: #ff0000;">&nbsp; &nbsp; she is not good</span></p>
    <p>noun</p>
    <p><strong>2 ali bagheri is very good ali bagheri is very good ali bagheri is very good:</strong></p>
    <p><span style="color: #ff0000;">&nbsp; &nbsp; she is not good</span></p>
    <p><strong>&nbsp;&nbsp;</strong></p>
    </body>
''';
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
        builder: (ctx, ctr, data){
          return Scaffold(
            //appBar: buildAppbar(),
            body: SafeArea(
                child: buildBody()
            ),
          );
        }
    );
  }

  Widget buildBody(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),

            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              child: ColoredBox(
                color: Colors.red,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1.5),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    child: ColoredBox(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.asset(AppImages.lessonListIco),
                                SizedBox(width: 10),
                                Text(widget.injection.lessonModel.title).bold().fsR(3)
                              ],
                            ),

                            GestureDetector(
                              onTap: (){
                                AppNavigator.pop(context);
                              },
                              child: Row(
                                children: [
                                  Text(AppMessages.back),
                                  SizedBox(width: 10),
                                  CustomCard(
                                    color: Colors.grey.shade200,
                                      padding: EdgeInsets.all(5),
                                      child: Image.asset(AppImages.arrowLeftIco)
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),


            SizedBox(height: 14),
            /// 7/20
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Chip(
                      label: Text(widget.injection.segment.title).bold().color(Colors.white),
                      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                      visualDensity: VisualDensity.compact,
                    ),

                    SizedBox(width: 10),

                    SizedBox(
                      height: 15,
                      width: 2,
                      child: ColoredBox(
                        color: Colors.black45,
                      ),
                    ),

                    SizedBox(width: 10),

                    Text('بخش اول').color(Colors.black45)
                  ],
                ),

                Row(
                  children: [
                    Text('20').englishFont().fsR(4),

                    SizedBox(width: 10),

                    Text('/').englishFont().fsR(5),

                    SizedBox(width: 10),

                    CustomCard(
                      color: Colors.grey.shade200,
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: Text('7').englishFont().bold().fsR(4)
                    )
                  ],
                ),
              ],
            ),

            SizedBox(height: 14),
            /// progressbar
            Directionality(
                textDirection: TextDirection.ltr,
                child: LinearProgressIndicator(value: 0.3, backgroundColor: Colors.red.shade50)
            ),

            SizedBox(height: 14),
            Image.asset(AppImages.noImage),

            SizedBox(height: 14),
            DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black, width: 1, style: BorderStyle.solid)
                ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CustomCard(
                              padding: EdgeInsets.all(5),
                                color: Colors.grey.shade200,
                                child: Image.asset(AppImages.lightnerIcoBlack),
                            ),

                            SizedBox(width: 10),

                            CustomCard(
                              padding: EdgeInsets.all(5),
                              color: Colors.grey.shade200,
                              child: Image.asset(AppImages.speaker2Ico),
                            ),

                            SizedBox(width: 10),

                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(text: '[ ', style: TextStyle(fontSize: 16, color: Colors.black)),
                                  TextSpan(text: 'thanks', style: TextStyle(fontSize: 12, color: Colors.black)),
                                  TextSpan(text: ' ]', style: TextStyle(fontSize: 16, color: Colors.black))
                                ]
                              ),
                            ),
                          ],
                        ),

                        Text('Thanks').bold().fsR(4),
                      ],
                    ),

                    Padding(
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 1,
                        child: ColoredBox(color: Colors.grey),
                      ),
                    ),

                    AnimatedCrossFade(
                        firstChild: InputChip(
                          onPressed: (){
                            showTranslate = !showTranslate;
                            assistCtr.updateMain();
                          },
                          label: Text('مشاهده ترجمه'),
                        ),
                        secondChild: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text('تشکر / سپاس'),
                        ),
                        crossFadeState: showTranslate? CrossFadeState.showSecond : CrossFadeState.showFirst,
                        duration: Duration(milliseconds: 300)
                    ),


                    SizedBox(height: 10),

                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: HTML.toRichText(context, htmlText, defaultTextStyle: AppThemes.body2TextStyle())
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  void requesVocabs(){

    requester.httpRequestEvents.onFailState = (req, res) async {
      assistCtr.removeState(state$loading);
      assistCtr.addStateAndUpdate(state$error);
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      assistCtr.removeState(state$loading);
      assistCtr.removeState(state$error);

      final List? data = res['data'];
print(res);
      /*if(data is List){
        for(final k in data){
          final les = LessonModel.fromMap(k);
          lessons.add(les);
        }
      }*/

      assistCtr.updateMain();
    };

    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: '/vocabularies?LessonId=${widget.injection.lessonModel.id}');
    requester.request(context);
  }
}
