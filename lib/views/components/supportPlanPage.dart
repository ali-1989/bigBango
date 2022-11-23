import 'package:app/models/abstract/stateBase.dart';
import 'package:app/system/requester.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

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
      srcCtr.jumpTo(timeSelectedIdx * 18);
      optionSelectedIdx = 0;
      assistCtr.updateMain();
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
                          srcCtr.jumpTo(1*18);
                          optionSelectedIdx = 0;
                          assistCtr.updateMain();
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
                          srcCtr.jumpTo(3*18);
                          optionSelectedIdx = 1;
                          assistCtr.updateMain();
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
                          srcCtr.jumpTo(5*18);
                          optionSelectedIdx = 2;
                          assistCtr.updateMain();
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

                                        assistCtr.updateMain();
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
                              onPressed: (){},
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

  void requestSendTicket(){
    FocusHelper.hideKeyboardByUnFocusRoot();

    requester.httpRequestEvents.onFailState = (req, res) async {
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
    };

    showLoading();
    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: '/tickets/add');
    requester.debug = true;
    requester.request(context);
  }

  void scrollListener() {
    optionSelectedIdx = -1;
    final a2 = srcCtr.offset / 18;

    if(a2.round() <= (a2+0.15).round()){
      timeSelectedIdx = a2.round();
    }
    else {
      timeSelectedIdx = -1;
    }

    assistCtr.updateMain();
  }
}
