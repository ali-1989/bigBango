import 'package:app/structures/middleWare/requester.dart';
import 'package:app/structures/models/leitner/leitnerBoxModel.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:app/views/states/waitToLoad.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/models/leitner/leitnerModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appNavigator.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/views/widgets/customCard.dart';

class LightnerDetailPage extends StatefulWidget {
  final LeitnerBoxModel lightnerBox;

  const LightnerDetailPage({
    required this.lightnerBox,
    Key? key
  }) : super(key: key);

  @override
  State<LightnerDetailPage> createState() => _LightnerDetailPageState();
}
///==================================================================================================================
class _LightnerDetailPageState extends StateBase<LightnerDetailPage> {
  Requester requester = Requester();
  List<LeitnerModel> leitnerItems = [];
  bool showTranslate = false;
  int currentIdx = 0;

  @override
  void initState(){
    super.initState();

    assistCtr.addState(AssistController.state$loading);
    requestLeitner();
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
          if(assistCtr.hasState(AssistController.state$error)){
            return ErrorOccur(onTryAgain: tryAgain);
          }

          if(assistCtr.hasState(AssistController.state$loading)){
            return WaitToLoad();
          }

          return Scaffold(
            body: SafeArea(
                child: buildBody()
            ),
          );
        }
    );
  }

  Widget buildBody(){
    final current = leitnerItems[currentIdx];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),

            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              child: ColoredBox(
                color: AppColors.red,
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
                                Image.asset(AppImages.leitnerIcoRed),
                                SizedBox(width: 10),
                                Text('جعبه لایتنر').bold().fsR(3)
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
                    Text('جعبه ی ${widget.lightnerBox.getNumText(widget.lightnerBox.number)}').color(Colors.black45)
                  ],
                ),

                Row(
                  children: [
                    Text('${leitnerItems.length}').englishFont().fsR(4),

                    SizedBox(width: 10),

                    Text('/').englishFont().fsR(5),

                    SizedBox(width: 10),

                    CustomCard(
                      color: Colors.grey.shade200,
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: Text('${currentIdx+1}').englishFont().bold().fsR(4)
                    )
                  ],
                ),
              ],
            ),

            SizedBox(height: 14),

            /// progressbar
            Directionality(
                textDirection: TextDirection.ltr,
                child: LinearProgressIndicator(value: calcProgress(), backgroundColor: AppColors.red.withAlpha(50))
            ),

            SizedBox(height: 60),

            DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black45, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    children: [
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:[
                          /*CustomCard(
                            padding: EdgeInsets.all(5),
                              color: AppColors.red,
                              child: Image.asset(AppImages.lightnerIcoBlack, width: 20, color: Colors.white)
                          ),*/

                          SizedBox(width: 8),
                          CustomCard(
                            padding: EdgeInsets.all(5),
                              color: Colors.grey.shade200,
                              child: Image.asset(AppImages.speaker2Ico, width: 20,)
                          ),

                          SizedBox(width: 8),
                          Visibility(
                            visible: current.contentType == 1,
                            child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(text: '[ ', style: AppThemes.bodyTextStyle()),
                                    TextSpan(text: '${current.getPronunciation()}', style: AppThemes.bodyTextStyle()),
                                    TextSpan(text: ' ]', style: AppThemes.bodyTextStyle()),
                                  ]
                                )
                            ),
                          ),
                        ]
                      ),

                      SizedBox(height: 10),
                      Divider(color: Colors.black45,),
                      SizedBox(height: 50),

                      Text(current.getContent()).fsR(10),

                      AnimatedCrossFade(
                          firstChild: TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: (){
                                showTranslate = !showTranslate;
                                assistCtr.updateHead();
                              },
                              child: Text('نمایش معنی')
                          ),
                          secondChild: Padding(
                            padding: const EdgeInsets.only(top: 14.0),
                            child: Text(current.getTranslate()),
                          ),
                          crossFadeState: showTranslate? CrossFadeState.showSecond : CrossFadeState.showFirst,
                          duration: Duration(milliseconds: 250)
                      ),

                      SizedBox(height: 50),
                      Row(
                        children: [
                          Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green
                                ),
                                onPressed: (){
                                  showTranslate = !showTranslate;
                                  assistCtr.updateHead();
                                },
                                child: Text('بلدم'),
                              )
                          ),

                          SizedBox(width: 10),
                          Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange
                                ),
                                onPressed: (){},
                                child: Text('بازم ببینم'),
                              )
                          ),

                          SizedBox(width: 10),
                          Expanded(
                              child: ElevatedButton(
                                onPressed: (){
                                  showTranslate = !showTranslate;
                                  assistCtr.updateHead();
                                },
                                child: Text('بلد نیستم'),
                              )
                          ),
                        ],
                      ),
                      SizedBox(height: 4),

                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  double calcProgress(){
    int r = ((currentIdx+1) * 100) ~/ leitnerItems.length;
    return r/100;
  }

  void tryAgain(){
    assistCtr.addStateWithClear(AssistController.state$loading);
    assistCtr.updateHead();

    requestLeitner();
  }

  void requestLeitner() async {
    requester.httpRequestEvents.onFailState = (req, dataJs) async {
      assistCtr.addStateWithClear(AssistController.state$error);
      assistCtr.updateHead();
    };

    requester.httpRequestEvents.onStatusOk = (req, dataJs) async {
      final data = dataJs['data']?? [];

      if(data is List){
        for(final x in data){
          leitnerItems.add(LeitnerModel.fromMap(x));
        }
      }

      assistCtr.clearStates();
      assistCtr.updateHead();
    };


    requester.prepareUrl(pathUrl: '/leitner/contents?BoxNumber=${widget.lightnerBox.number}');
    requester.methodType = MethodType.get;
    requester.request(null, false);
  }
}
