import 'package:flutter/material.dart';

import 'package:animator/animator.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/customCard.dart';

import 'package:app/services/audio_player_service.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/leitnerModels/leitnerBoxModel.dart';
import 'package:app/structures/models/leitnerModels/leitnerModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appNavigator.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/tools/app/appToast.dart';
import 'package:app/tools/routeTools.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:app/views/states/waitToLoad.dart';

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
  String assistId$player = 'assistId_player';
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
    AudioPlayerService.getPlayer().stop();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Assist(
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
      ),
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
                child: LinearProgressIndicator(
                    value: calcProgress(),
                    backgroundColor: AppColors.red.withAlpha(50)
                )
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
                      Visibility(
                        visible: current.contentType == 1,
                        child: Column(
                          children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children:[
                                  SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: (){
                                      playSound(current);
                                    },
                                    child: Assist(
                                        controller: assistCtr,
                                        id: assistId$player,
                                        builder: (_, __, data) {
                                          return AnimateWidget(
                                              resetOnRebuild: true,
                                              triggerOnRebuild: true,
                                              duration: Duration(milliseconds: 500),
                                              cycles: data == 'prepare' ? 100 : 1,
                                            builder: (_, animate) {
                                              Color color = Colors.grey.shade200;

                                              if(data == 'prepare'){
                                                color = animate.fromTween((v) => ColorTween(begin: AppColors.red, end: AppColors.red.withAlpha(50)))!;
                                              }
                                              else if(data == 'play'){
                                                color = AppColors.red;
                                              }

                                              return CustomCard(
                                                padding: EdgeInsets.all(5),
                                                color: color,//Colors.grey.shade200,
                                                child: Image.asset(AppImages.speaker2Ico, width: 20)
                                        );
                                            }
                                          );
                                      }
                                    ),
                                  ),

                                  SizedBox(width: 8),
                                  RichText(
                                      text: TextSpan(
                                          children: [
                                            TextSpan(text: '[ ', style: AppThemes.bodyTextStyle()),
                                            TextSpan(text: '${current.getPronunciation()}', style: AppThemes.bodyTextStyle()),
                                            TextSpan(text: ' ]', style: AppThemes.bodyTextStyle()),
                                          ]
                                      )
                                  ),
                                ]
                            ),

                            SizedBox(height: 10),
                            Divider(color: Colors.black45),
                            SizedBox(height: 50),
                          ],
                        ),
                      ),

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
                                  requestSetReview(current, true);
                                },
                                child: Text('بلدم'),
                              )
                          ),


                          SizedBox(width: 20),
                          Expanded(
                              child: ElevatedButton(
                                onPressed: (){
                                  requestSetReview(current, false);
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

  void playSound(LeitnerModel model){
    assistCtr.updateAssist(assistId$player, stateData: 'prepare');

    AudioPlayerService.getPlayerWithUrl(model.vocabulary?.americanVoice?.fileLocation?? '').then((twoState) async {
      if(twoState.hasResult1()){
        assistCtr.updateAssist(assistId$player, stateData: 'play');
        await twoState.result1!.play();
        assistCtr.updateAssist(assistId$player, stateData: null);
        twoState.result1!.stop();
      }
      else {
        AppToast.showToast(context, 'متاسفانه امکان پخش صدا نیست');
      }
    });
  }

  double calcProgress(){
    int r = ((currentIdx+1) * 100) ~/ leitnerItems.length;
    return r/100;
  }

  void next(){
    if(currentIdx < leitnerItems.length-1){
      currentIdx++;
    }
    else {
      /*AppSheet.showSheetOneAction(
          context,
          'تبریک شما محتوای این جعبه را تمام کردید',
          (){
            RouteTools.popTopView(context: context);
          }
      );*/
      RouteTools.popTopView(context: context);
    }
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

  void requestSetReview(LeitnerModel model, bool state) async {
    requester.httpRequestEvents.onFailState = (req, dataJs) async {
      hideLoading();
      AppSheet.showSheet$OperationFailed(context);
    };

    requester.httpRequestEvents.onStatusOk = (req, dataJs) async {
      hideLoading();

      next();
      assistCtr.updateHead();
    };

    final js = <String, dynamic>{};
    js['id'] = model.id;
    js['isCorrect'] = state;

    showLoading();
    requester.prepareUrl(pathUrl: '/leitner/review');
    requester.methodType = MethodType.put;
    requester.bodyJson = js;
    requester.request(null, false);
  }
}
