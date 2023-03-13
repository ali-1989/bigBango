import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/keepAliveWrap.dart';
import 'package:switch_tab/switch_tab.dart';

import 'package:app/managers/systemParameterManager.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/models/supportModels/supportPlanModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/tools/currencyTools.dart';
import 'package:iris_tools/widgets/customCard.dart';

class SupportPlanSheet extends StatefulWidget {
  final List<SupportPlanModel> planList;

  const SupportPlanSheet({
    Key? key,
    required this.planList,
  }) : super(key: key);

  @override
  State<SupportPlanSheet> createState() => _SupportPlanSheetState();
}
///==================================================================================================
class _SupportPlanSheetState extends StateBase<SupportPlanSheet> {
  PageController pageCtr = PageController(keepPage: true);
  late ScrollController srcCtr;
  int optionSelectedIdx = -1;
  int timeScrollSelectedIdx = 0;
  int minutes = 0;

  @override
  void dispose(){
    super.dispose();
  }

  @override
  void initState(){
    super.initState();

    srcCtr = ScrollController();
    srcCtr.addListener(scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
        controller: assistCtr,
        builder: (_, ctr, data) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 14),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(AppImages.selectLevelIco2, width: 18),
                          SizedBox(width: 8),
                          Text('خرید زمان', style: TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                      SizedBox(height: 10),

                      SizedBox(
                        height: 60,
                        child: SwitchTab(
                          shape: SwitchTabShape.rectangle,
                          backgroundColour: AppColors.red,
                          thumbColor: Colors.white,
                          onValueChanged: (idx){
                            pageCtr.animateToPage(idx, duration: Duration(milliseconds: 500), curve: Curves.linear);
                          }, text: [
                          'طرح تشویقی',
                          'زمان دلخواه',
                          ],
                        ),
                      ),

                      SizedBox(height: 10),

                      SizedBox(
                        height: 150,
                          child: PageView(
                            controller: pageCtr,
                            physics: NeverScrollableScrollPhysics(),
                            children: [
                              getPage1(),
                              getPage2(),
                            ],
                          )
                      ),

                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: onBuyClick,
                              child: Text('ادامه خرید')
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        }
    );
  }

  Widget getPage1(){
    if(widget.planList.isEmpty){
      return Center(
        child: Text('طرحی یافت نشد'),
      );
    }

    return Padding(
        padding: EdgeInsets.all(2),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text('لطفا یکی از طرح های زیر را انتخاب کنید ',
                style: TextStyle(fontSize: 12)
            ),
          ),

          SizedBox(height: 15),

          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.planList.length,
                itemBuilder: itemBuilder
            ),
          ),
        ],
      ),
    );
  }

  Widget getPage2(){
    return KeepAliveWrap(
      child: Padding(
          padding: EdgeInsets.all(2),
        child: Column(
          children: [
            SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(width: 6),
                    Image.asset(AppImages.watchIco, width: 14),
                    SizedBox(width: 6),
                    Text('زمان مورد نظر خود را انتخاب کنید', style: TextStyle(fontSize: 12)),
                  ],
                ),

                Row(
                  children: [
                    SizedBox(
                      width: 40,
                      height: 50,
                      child: Stack(
                        children: [
                          Center(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                  color: AppColors.red.withAlpha(50),
                                  borderRadius: BorderRadius.circular(4)
                              ),
                              child: SizedBox(
                                width: 50,
                                height: 20,
                              ),
                            ),
                          ),
                          ListWheelScrollView.useDelegate(
                            controller: srcCtr,
                            useMagnifier: true,
                            magnification: 1.4,
                            itemExtent: 18,
                            onSelectedItemChanged: (x){
                              //timeSelectedIdx = x;

                              //assistCtr.updateHead();
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              childCount: 12,
                              builder: (_, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Text('${(index+1)*5}',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: timeScrollSelectedIdx == index? AppColors.red : Colors.black
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 4),
                    Text('دقیقه'),

                    SizedBox(width: 10),
                  ],
                ),
              ],
            ),

            SizedBox(height: 20),

            Row(
              textDirection: TextDirection.ltr,
              children: [
                CustomCard(
                color: AppColors.greenTint,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    child: Text('${calcAmount()} تومان')
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget itemBuilder(BuildContext _, int idx){
    final itm = widget.planList[idx];

    return GestureDetector(
      onTap: (){
        onOptionClick(idx, itm);
      },
      child: Card(
        color: Colors.grey.shade100,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    Builder(
                        builder: (ctx){
                          if(optionSelectedIdx == idx){
                            return getSelectedBox();
                          }

                          return getEmptyBox();
                        }
                    ),

                    const SizedBox(width: 18),
                    Flexible(child: Text('${itm.title}  (${itm.minutes} دقیقه)')),
                  ],
                ),
              ),

              Row(
                children: [
                  Text(CurrencyTools.formatCurrency(itm.amount)),
                  Text('  تومان').fsR(-4),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getEmptyBox(){
    return Image.asset(AppImages.emptyBoxIco, height: 15);
  }

  Widget getSelectedBox(){
    return Image.asset(AppImages.selectLevelIco, height: 15);
  }

  int calcAmount(){
    if(timeScrollSelectedIdx < 0){
      return 0;
    }

    return (SystemParameterManager.getAmountOf1Minutes() * minutes).toInt();
  }

  void scrollListener() {
    optionSelectedIdx = -1;

    final a2 = srcCtr.offset / 18;  //18 is height

    if(a2.round() <= (a2+ 0.15).round()){
      timeScrollSelectedIdx = a2.round();
      minutes = (timeScrollSelectedIdx+1) * 5;
    }
    /*else {
      timeSelectedIdx = -1;
      minutes = 0;
    }*/

    assistCtr.updateHead();
  }

  void onOptionClick(int idx, SupportPlanModel model) {
    minutes = model.minutes;
    optionSelectedIdx = idx;
    timeScrollSelectedIdx = -1;

    assistCtr.updateHead();
  }

  void onBuyClick(){
    if(minutes < 1){
      AppSheet.showSheetOk(context, 'لطفا یکی از طرح ها یا زمان مورد نظر را انتخاب کنید');
      return;
    }

    final map = {};
    map['minutes'] = minutes;
    map['amount'] = optionSelectedIdx < 0 ? calcAmount() : widget.planList[optionSelectedIdx].amount;

    if(optionSelectedIdx > -1) {
      map['planId'] = widget.planList[optionSelectedIdx].id;
    }

    AppRoute.popTopView(context: context, data: map);
  }
}
