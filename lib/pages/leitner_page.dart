import 'package:flutter/material.dart';

import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/managers/storeManager.dart';
import 'package:app/pages/leitner_detail_page.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/models/lightnerModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/views/states/emptyData.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:app/views/states/waitToLoad.dart';
import 'package:app/views/widgets/customCard.dart';

class LightnerPage extends StatefulWidget {
  const LightnerPage({Key? key}) : super(key: key);

  @override
  State createState() => _LightnerPageState();
}
///========================================================================================
class _LightnerPageState extends StateBase<LightnerPage> {
  List<LightnerModel> lightnerItem = [];

  @override
  void initState(){
    super.initState();

    List.generate(5, (index) {
      final i = LightnerModel();
      i.count = Generator.getRandomInt(2, 18);

      lightnerItem.add(i);
    });
  }

  @override
  void dispose(){
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

        if(StoreManager.getStoreLessonList().isEmpty){
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
                  Text('${lightnerItem.fold<int>(0, (p, element) => p + element.count)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                ],
              ),

              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                    itemCount: lightnerItem.length,
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
    final itm = lightnerItem[idx];

    return GestureDetector(
      onTap: (){
        onItemClick(itm, idx);
      },
      child: Padding(
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
                              TextSpan(text: 'جعبه ی ', style: AppThemes.body2TextStyle()),
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
                    Text('0').color(AppColors.red).fsR(-2),
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

    //requestStores();
  }

  void onItemClick(LightnerModel itm, idx) async {
    await AppRoute.push(context, LightnerDetailPage(lightnerModel: itm, index: idx));

    assistCtr.updateHead();
  }
}
