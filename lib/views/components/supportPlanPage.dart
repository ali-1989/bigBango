import 'package:app/structures/models/hoursOfSupportModel.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appSnack.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/middleWare/requester.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appImages.dart';

// todo.im
// باید دو درخواست جدید اضافه شود

class SupportPlanPage extends StatefulWidget {

  const SupportPlanPage({
    Key? key,
  }) : super(key: key);

  @override
  State<SupportPlanPage> createState() => _SupportPlanPageState();
}
///==================================================================================================
class _SupportPlanPageState extends StateBase<SupportPlanPage> {
  Requester requester = Requester();
  int optionSelectedIdx = 0;
  int timeSelectedIdx = 1;
  int minutes = 10;
  late ScrollController srcCtr;

  @override
  void dispose(){
    requester.dispose();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();

    srcCtr = ScrollController();
    srcCtr.addListener(scrollListener);

    addPostOrCall(fn: (){
      srcCtr.jumpTo(timeSelectedIdx * 18); // 18 is height
      optionSelectedIdx = 0;
      assistCtr.updateHead();
    });
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
                          Text('پنل\u200cهای پشتیبانی', style: TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text('لطفا یکی از پنل های زیر را انتخاب کنید یا مدت زمان مورد نیاز خود را جهت خرید انتخاب کنید',
                            style: TextStyle(fontSize: 12, height: 1.4)),
                      ),

                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: (){
                          onOptionClick(0, 1);
                        },
                        child: Card(
                          color: Colors.grey.shade100,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
                            child: Row(
                              children: [
                                Builder(
                                    builder: (ctx){
                                      if(optionSelectedIdx == 0){
                                        return getSelectedBox();
                                      }

                                      return getEmptyBox();
                                    }
                                ),

                                const SizedBox(width: 18),
                                Text('پلن 10 دقیقه ای'),
                              ],
                            ),
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: (){
                          onOptionClick(1, 3);
                        },
                        child: Card(
                          color: Colors.grey.shade100,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
                            child: Row(
                              children: [
                                Builder(
                                    builder: (ctx){
                                      if(optionSelectedIdx == 1){
                                        return getSelectedBox();
                                      }

                                      return getEmptyBox();
                                    }
                                ),

                                const SizedBox(width: 18),
                                Text('پلن 20 دقیقه ای'),
                              ],
                            ),
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: (){
                          onOptionClick(2, 5);
                        },
                        child: Card(
                          color: Colors.grey.shade100,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
                            child: Row(
                              children: [
                                Builder(
                                    builder: (ctx){
                                      if(optionSelectedIdx == 2){
                                        return getSelectedBox();
                                      }

                                      return getEmptyBox();
                                    }
                                ),

                                const SizedBox(width: 18),
                                Text('پلن 30 دقیقه ای'),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 10),
                      Row(
                        children: [
                          Text('  یا  ').color(AppColors.red),
                          Expanded(child: Divider(endIndent: 6, color: Colors.black)),
                        ],
                      ),

                      SizedBox(height: 10),
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
                                        timeSelectedIdx = x;
                                        optionSelectedIdx = -1;

                                        assistCtr.updateHead();
                                      },
                                      childDelegate: ListWheelChildBuilderDelegate(
                                        childCount: 12,
                                        builder: (_, index) {
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 3),
                                            child: Text('${(index+1)*5}',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: timeSelectedIdx == index? AppColors.red : Colors.black
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

                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: requestFreeTimes,
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

  Widget getEmptyBox(){
    return Image.asset(AppImages.emptyBoxIco, height: 15);
  }

  Widget getSelectedBox(){
    return Image.asset(AppImages.selectLevelIco, height: 15);
  }

  void scrollListener() {
    optionSelectedIdx = -1;
    final a2 = srcCtr.offset / 18;  //18 is height

    if(a2.round() <= (a2+ 0.15).round()){
      timeSelectedIdx = a2.round();
      minutes = (timeSelectedIdx+1) * 5;
    }
    else {
      timeSelectedIdx = -1;
      minutes = 0;
    }

    assistCtr.updateHead();
  }

  void onOptionClick(int idx, int num) {
    srcCtr.jumpTo(num*18);
    minutes = (num+1) * 5;

    optionSelectedIdx = idx;
    assistCtr.updateHead();
  }

  void requestFreeTimes(){
    requester.httpRequestEvents.onAnyState = (req) async {
      await hideLoading();
    };

    requester.httpRequestEvents.onFailState = (req, res) async {
      String msg = 'خطایی رخ داده است';

      if(res != null && res.data != null){
        final js = JsonHelper.jsonToMap(res.data)?? {};

        msg = js['message']?? msg;
      }

      AppSnack.showInfo(context, msg);
    };

    requester.httpRequestEvents.onStatusOk = (req, jsData) async {
      final data = jsData[Keys.data];

      final List<HoursOfSupportModel> list = [];

      if(data is List){
        for(final k in data){
          final g = HoursOfSupportModel.fromMap(k);
          list.add(g);
        }
      }

      AppRoute.popTopView(context, data: list);
    };

    showLoading();
    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: '/supprtTimes?RequiredMinutes=$minutes');
    requester.request(context);
  }
}
