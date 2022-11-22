import 'dart:async';

import 'package:app/models/abstract/stateBase.dart';
import 'package:app/system/requester.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/views/widgets/customCard.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:app/system/extensions.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({Key? key}) : super(key: key);

  @override
  State<SupportPage> createState() => _SupportPageState();
}
///========================================================================================
class _SupportPageState extends StateBase<SupportPage> with SingleTickerProviderStateMixin {
  late TabController tabCtr;
  late TextStyle tabBarStyle;
  int optionSelectedIdx = 0;
  int timeSelectedIdx = 0;
  late ScrollController srcCtr;
  String buySheetId = 'buySheetId';
  String addTicketSheetId = 'addTicketSheetId';
  final List<DropdownMenuItem<String>> dropList = [];
  String dropSelectedValue = '';
  Requester requester = Requester();

  @override
  void initState(){
    super.initState();

    tabCtr = TabController(length: 2, vsync: this);
    srcCtr = ScrollController();
    srcCtr.addListener(scrollListener);

    tabBarStyle = TextStyle(
      color: Colors.red,
      fontWeight: FontWeight.w900
    );

    final dList = {};
    dList['0'] = 'مدیریت';
    dList['1'] = 'فنی';

    dropSelectedValue = '1';

    for (final element in dList.entries) {
      final h = DropdownMenuItem<String>(value: element.key, child: Text(element.value));

      dropList.add(h);
    }
  }

  @override
  void dispose(){
    requester.dispose();
    super.dispose();
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
              onPressed: showAddTicketSheet,
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
    builder(sheetContext){
      return Assist(
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
                            srcCtr.jumpTo(1*18);
                            optionSelectedIdx = 0;
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
                                  width: 40,
                                  height: 50,
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                              color: Colors.red.withAlpha(50),
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

                                          assistCtr.update(buySheetId);
                                        },
                                        childDelegate: ListWheelChildBuilderDelegate(
                                          childCount: 12,
                                          builder: (_, index) {
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 3),
                                              child: Text('${(index+1)*5}',
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: timeSelectedIdx == index? Colors.red : Colors.black
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

    AppSheet.showSheetCustom(
        context,
        builder: builder,
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

  void scrollListener() {
    optionSelectedIdx = -1;
    final a2 = srcCtr.offset / 18;

    if(a2.round() <= (a2+0.15).round()){
        timeSelectedIdx = a2.round();
      }
      else {
        timeSelectedIdx = -1;
      }

    assistCtr.update(buySheetId);
  }

  void showAddTicketSheet() async {
    builder(sheetContext){
      return Assist(
          controller: assistCtr,
          id: addTicketSheetId,
          builder: (_, ctr, data) {
            final boldStyle = TextStyle(fontWeight: FontWeight.w700, fontSize: 11);
            final inputDecoration = InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              isDense: true,
              filled: true,
              fillColor: Colors.grey.shade100,
            );


            final x = MediaQuery.of(sheetContext).viewInsets;

            return SizedBox(
              width: double.infinity,
              height: x.collapsedSize.height < 10 ? sh *3/4 : sh - x.collapsedSize.height,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 14),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(AppIcons.addCircle, color: Colors.red,),
                                SizedBox(width: 6),
                                Text('ایجاد تیکت', style: TextStyle(fontWeight: FontWeight.w700)),
                              ],
                            ),

                            GestureDetector(
                              onTap: (){
                                AppRoute.popTopView(context);
                              },
                              child: CustomCard(
                                  color: Colors.grey.shade200,
                                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                                  radius: 4,
                                  child: Icon(AppIcons.close, size: 10,)
                              ),
                            ),
                          ],
                        ),

                        Expanded(
                            child: ListView(
                              shrinkWrap: true,
                              children: [
                                SizedBox(height: 20),
                                Text('موضوع', style: boldStyle),
                                TextField(
                                  decoration: inputDecoration,
                                ),

                                SizedBox(height: 10),
                                Text('بخش مربوطه', style: boldStyle),

                                DecoratedBox(
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(6)
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton2<String>(
                                      items: dropList,
                                      value: dropSelectedValue,
                                      offset: Offset(0,0),
                                      buttonPadding: EdgeInsets.symmetric(horizontal: 5),
                                      itemHeight: 30,
                                      buttonHeight: 50,
                                      onChanged: (value) {
                                        setState(() {
                                          dropSelectedValue = value as String;
                                          assistCtr.update(addTicketSheetId);
                                        });
                                      },
                                    ),
                                  ),
                                ),

                                SizedBox(height: 10),
                                Text('توضیحات', style: boldStyle),
                                TextField(
                                  minLines: 5,
                                  maxLines: 5,
                                  decoration: inputDecoration,
                                ),

                                SizedBox(height: 15),
                                ElevatedButton(
                                    onPressed: requestSendTicket,
                                    child: Text('ارسال')
                                )
                              ],
                            )
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

    showLoading();
    await requestRoles();
    await hideLoading();

    AppSheet.showSheetCustom(
      context,
      builder: builder,
      routeName: 'showAddTicketSheet',
      isDismissible: true,
      isScrollControlled: true,
      contentColor: Colors.transparent,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> requestRoles() async {
    Completer co = Completer();

    requester.httpRequestEvents.onFailState = (req, res) async {
      co.complete(null);
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      print(res);

      co.complete(null);
      assistCtr.clearStates();
      assistCtr.updateMain();
    };

    requester.methodType = MethodType.get;
    requester.prepareUrl(pathUrl: '/roles');
    requester.request(context);

    return co.future;
  }

  void requestSendTicket(){
    FocusHelper.hideKeyboardByUnFocus(context);
  }
}
