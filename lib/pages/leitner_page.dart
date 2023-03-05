import 'package:app/managers/leitnerManager.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/leitner/leitnerBoxModel.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/pages/leitner_detail_page.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/views/states/emptyData.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:app/views/states/waitToLoad.dart';
import 'package:iris_tools/widgets/customCard.dart';

class LightnerPage extends StatefulWidget {
  const LightnerPage({Key? key}) : super(key: key);

  @override
  State createState() => _LightnerPageState();
}
///========================================================================================
class _LightnerPageState extends StateBase<LightnerPage> {
  Requester requester = Requester();
  List<LeitnerBoxModel> boxItems = [];

  @override
  void initState(){
    super.initState();

    assistCtr.addState(AssistController.state$loading);
    requestLeitner();
    LeitnerManager.requestLeitnerCount();
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
      builder: (_, ctr, data){
        if(assistCtr.hasState(AssistController.state$error)){
          return ErrorOccur(onTryAgain: tryAgain);
        }

        if(assistCtr.hasState(AssistController.state$loading)){
          return WaitToLoad();
        }

        if(boxItems.isEmpty){
          return EmptyData();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              SizedBox(height: 70),
              AspectRatio(
                  aspectRatio: 5/2.5,
                  child: Image.asset(AppImages.lightner)
              ),

              //Expanded(child: SizedBox()),
              SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('جعبه لایتنر', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  Text('${boxItems.fold<int>(0, (sum, element) => sum + element.count)}',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)
                  ),
                ],
              ),

              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                    itemCount: boxItems.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemBuilder: itemBuilder
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget itemBuilder(ctx, idx){
    final itm = boxItems[idx];

    return GestureDetector(
      onTap: (){
        onItemClick(itm, idx);
      },
      child: Padding(
        key: ValueKey(itm.number),
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black45, width: 1),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(width: 8),

                    CustomCard(
                      color: Colors.grey.shade200,
                        radius: 5,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12.0),
                        child: Text('${idx + 1}').fsR(1),
                    ),

                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: 'جعبه ی ', style: AppThemes.bodyTextStyle()),
                              TextSpan(text: itm.getNumText(idx+1),
                                  style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
                              ),
                            ]
                          ),
                        ),

                        SizedBox(height: 8),
                        Text('آماده یادگیری').color(AppColors.red).fsR(-2),
                      ],
                    ),
                  ],
                ),

                Column(
                  children: [
                    Text('${itm.count}').bold().fsR(1),
                    SizedBox(height: 8),
                    Text('${itm.readyToLearnCount}').color(AppColors.red).fsR(-2),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void tryAgain(){
    assistCtr.addStateWithClear(AssistController.state$loading);
    assistCtr.updateHead();

    requestLeitner();
  }

  void onItemClick(LeitnerBoxModel itm, idx) async {
    if(itm.readyToLearnCount == 0){
      return;
    }

    await AppRoute.pushPage(context, LightnerDetailPage(lightnerBox: itm));

    requestLeitner();
    LeitnerManager.requestLeitnerCount();
  }

  void requestLeitner() async {
    requester.httpRequestEvents.onFailState = (req, dataJs) async {
      assistCtr.addStateWithClear(AssistController.state$error);
      assistCtr.updateHead();
    };

    requester.httpRequestEvents.onStatusOk = (req, dataJs) async {
      final data = dataJs['data']?? {};
      final boxes = data['boxes']?? [];

      boxItems.clear();

      if(boxes is List){
        for(final x in boxes){
          boxItems.add(LeitnerBoxModel.fromMap(x));
        }
      }

      assistCtr.clearStates();
      assistCtr.updateHead();
    };


    requester.prepareUrl(pathUrl: '/leitner/boxes');
    requester.methodType = MethodType.get;
    requester.request(null, false);
  }
}
