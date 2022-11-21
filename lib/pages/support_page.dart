import 'package:app/models/abstract/stateBase.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:app/system/extensions.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({Key? key}) : super(key: key);

  @override
  State<SupportPage> createState() => _SupportPageState();
}
///========================================================================================
class _SupportPageState extends StateBase<SupportPage> with SingleTickerProviderStateMixin {
  late TabController tabCtr;
  late TextStyle tabBarStyle;
  int selectValue = 0;
  String buySheetId = 'sheet';

  @override
  void initState(){
    super.initState();

    tabCtr = TabController(length: 2, vsync: this);
    tabBarStyle = TextStyle(
      color: Colors.red,
      fontWeight: FontWeight.w900
    );
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
        builder: (_, ctr, data){
          return Scaffold(
            body: SafeArea(
                child: buildBody()
            ),
          );
        }
    );
  }

  Widget buildBody(){
    return Column(
      children: [
        Row(
          children: [
            BackButton(),
          ],
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: Stack(
            children: [
              Positioned(
                left:0,
                  right:0,
                  bottom: 0,
                  child: SizedBox(
                    height: 1,
                    child: ColoredBox(color: Colors.grey),
                  ),
              ),

              TabBar(
                controller: tabCtr,
                  indicatorColor: Colors.red,
                  labelColor: Colors.yellow,
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  tabs: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Text('جلسات', style: tabBarStyle),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Text('تیکت ها', style: tabBarStyle),
                    ),
                  ]),
            ],
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: TabBarView(
                controller: tabCtr,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  buildSessionPart(),
                  buildTicketPart(),
                ]
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSessionPart(){
    return LayoutBuilder(
      builder: (_, siz) {
        return SingleChildScrollView(
          child: SizedBox(
            height: siz.maxHeight,
            child: Column(
              children: [
                SizedBox(height: 30),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal:8.0, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset(AppImages.watchIco),
                            SizedBox(width: 8),
                            Text('زمان باقی مانده\u200cی پشتیبانی')
                          ],
                        ),

                        Row(
                          children: [
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                              ),
                              child: Text('20')
                                  .wrapBoxBorder(
                                    radius: 2,
                                    padding: EdgeInsets.symmetric(horizontal:6, vertical: 4),
                                    color: Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(' دقیقه'),
                            SizedBox(
                              height: 30,
                              child: FloatingActionButton(
                                onPressed: showBuySessionTimeSheet,
                                backgroundColor: Colors.red,
                                elevation: 0,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                child: Icon(AppIcons.add, size: 15, color: Colors.white),
                              ),
                            ),

                          ],
                        ),
                      ],
                    ),
                  ).wrapDotBorder(
                      radius: 0,
                      stroke: 1.5,
                      color: Colors.grey,
                      padding: EdgeInsets.zero
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                      itemCount: 15,
                      shrinkWrap: true,
                      itemBuilder: listBuilderForSession
                  ),
                )
              ],
            ),
          ),
        );
      }
    );
  }

  Widget listBuilderForSession(_, idx){
    return Padding(
        padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('عنوان درس'),

              Row(
                children: [
                  Text('2020/10/10'),
                  SizedBox(width: 5),
                  Icon(AppIcons.calendar, size: 14, color: Colors.grey.shade700),
                ],
              ),
            ],
          ),

          SizedBox(height: 6),
          Divider(color: Colors.grey.shade700),
          SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('موضوع'),

              DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withAlpha(40),
                    borderRadius: BorderRadius.circular(4)
                  ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2),
                  child: Text('10', style: TextStyle(color: Color(0xFF0ECF73), fontSize: 10)),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
  ///----------------------------------------------------
  Widget buildTicketPart(){
    return Column(
      children: [
        Expanded(
            child: ListView.builder(
              itemCount: 20,
                itemBuilder: listBuilderForTicket
            )
        ),

        Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (){},
              child: Text('ایجاد تیکت'),
            ),
          ),
        ),
      ],
    );
  }

  Widget listBuilderForTicket(_, idx){
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('عنوان درس'),

              Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                        color: Colors.greenAccent.withAlpha(40),
                        borderRadius: BorderRadius.circular(4)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2),
                      child: Text('باز', style: TextStyle(color: Color(0xFF0ECF73), fontSize: 10)),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text('2020/10/10'),
                  SizedBox(width: 5),
                  Icon(AppIcons.calendar, size: 14, color: Colors.grey.shade700),
                ],
              ),
            ],
          ),

          SizedBox(height: 6),
          Divider(color: Colors.grey.shade700),
          SizedBox(height: 2),
        ],
      ),
    );
  }

  void showBuySessionTimeSheet(){
    final content = Assist(
      controller: assistCtr,
      id: buySheetId,
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
                        selectValue = 0;
                        assistCtr.update(buySheetId);
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
                                    if(selectValue == 0){
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
                        selectValue = 1;
                        assistCtr.update(buySheetId);
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
                                    if(selectValue == 1){
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
                        selectValue = 2;
                        assistCtr.update(buySheetId);
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
                                    if(selectValue == 2){
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
                        Text('  یا  ').color(Colors.red),
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
                              width: 50,
                              child: CupertinoPicker(
                                useMagnifier: false,
                                looping: true,
                                onSelectedItemChanged: (x){},
                                itemExtent: 20,

                                children: [
                                  Text('a'),
                                  Text('b'),
                                ],
                              ),
                            ),
                            Text('دقیقه'),
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



    AppSheet.showSheetCustom(
        context,
        content,
        routeName: 'showBuySessionTimeSheet',
      isDismissible: true,
      isScrollControlled: true,
      contentColor: Colors.transparent,
      backgroundColor: Colors.transparent,
    );
  }

  Widget getEmptyBox(){
    return Image.asset(AppImages.emptyBoxIco, height: 15);
  }

  Widget getSelectedBox(){
    return Image.asset(AppImages.selectLevelIco, height: 15);
  }
}
