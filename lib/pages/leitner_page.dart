import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/urlHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/customCard.dart';
import 'package:iris_tools/widgets/icon/circularIcon.dart';

import 'package:app/managers/leitnerManager.dart';
import 'package:app/pages/leitner_detail_page.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/leitnerModels/leitnerBoxModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appDecoration.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/tools/routeTools.dart';
import 'package:app/views/states/emptyData.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:app/views/states/waitToLoad.dart';

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
          return const WaitToLoad();
        }

        if(boxItems.isEmpty){
          return const EmptyData();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 70),
              AspectRatio(
                  aspectRatio: 5/2.5,
                  child: Image.asset(AppImages.lightner)
              ),

              //Expanded(child: SizedBox()),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('جعبه لایتنر ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      GestureDetector(
                        onTap: (){
                          UrlHelper.launchWeb('https://fa.wikipedia.org/wiki/%D8%AC%D8%B9%D8%A8%D9%87_%D9%84%D8%A7%DB%8C%D8%AA%D9%86%D8%B1');
                        },
                          child: const CircularIcon(icon: AppIcons.questionMark, size: 17)
                      ),
                    ],
                  ),

                  Text('${boxItems.fold<int>(0, (sum, element) => sum + element.count)}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)
                  ),
                ],
              ),

              const SizedBox(height: 20),
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 8),

                    CustomCard(
                      color: Colors.grey.shade200,
                        radius: 5,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12.0),
                        child: Text('${idx + 1}').fsR(1),
                    ),

                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: 'جعبه  ', style: AppThemes.baseTextStyle()),
                              TextSpan(text: itm.getNumText(idx+1),
                                  style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
                              ),
                            ]
                          ),
                        ),

                        const SizedBox(height: 8),
                        const Text('آماده یادگیری').color(AppDecoration.red).fsR(-2),
                      ],
                    ),
                  ],
                ),

                Column(
                  children: [
                    Text('${itm.count}').bold().fsR(1),
                    const SizedBox(height: 8),
                    Text('${itm.readyToLearnCount}').color(AppDecoration.red).fsR(-2),
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

    await RouteTools.pushPage(context, LightnerDetailPage(lightnerBox: itm));

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
