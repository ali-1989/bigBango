import 'package:app/managers/storeManager.dart';
import 'package:app/pages/about_page.dart';
import 'package:app/structures/models/lessonModels/storeModel.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/views/states/emptyData.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:app/views/states/waitToLoad.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/views/widgets/customCard.dart';

class StorePage extends StatefulWidget {
  const StorePage({Key? key}) : super(key: key);

  @override
  State createState() => _StorePageState();
}
///========================================================================================
class _StorePageState extends StateBase<StorePage> with TickerProviderStateMixin {
  late TabController tabCtr;
  int tabIdx = 0;
  List<String> tabNames = [];
  List<StoreLessonModel> lessonList = [];
  late StoreModel currentStore;

  @override
  void initState(){
    super.initState();

    tabCtr = TabController(length: 1, vsync: this);
    assistCtr.addState(AssistController.state$loading);
    requestStores();
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
              SizedBox(height: 80),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(AppImages.marketBasket, width: 32, height: 32),
                      SizedBox(width: 5),
                      Text('فروشگاه', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                    ],
                  ),

                  SizedBox(
                    height: 28,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                        onPressed: prepareBuy,
                        child: Text('ثبت سفارش')
                    ),
                  )
                ],
              ),

              SizedBox(height: 20),
              TabBar(
                controller: tabCtr,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelPadding: EdgeInsets.symmetric(vertical: 8),
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  labelColor: Colors.red,
                  unselectedLabelColor: Colors.black,
                  onTap: onTabClick,
                  tabs: tabNames.map((e) => Text(e)).toList()
              ),

              Expanded(
                child: ListView.builder(
                    itemCount: lessonList.length,
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
    final itm = lessonList[idx];

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
                              //TextSpan(text: itm.getNumText(idx+1), style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),),
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
                    //Text('${itm.count}').bold().fsR(1),
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

  void onItemClick(StoreLessonModel itm, idx) async {

  }

  void tryAgain(){
    assistCtr.addStateWithClear(AssistController.state$loading);
    assistCtr.updateHead();

    requestStores();
  }

  void onTabClick(int value) {
    tabIdx = value;
    prepareLessonList();
  }

  void prepareTabs() {
    tabCtr = TabController(length: StoreManager.getStoreLessonList().length, vsync: this);

    tabNames.clear();

    StoreManager.getStoreLessonList().forEach((element) {
      tabNames.add(element.name);
    });
  }

  void prepareLessonList() {
    lessonList.clear();
    currentStore = StoreManager.getStoreLessonList()[tabIdx];

    lessonList.addAll(currentStore.lessons);
  }

  void prepareBuy() {
  }

  void requestStores() async {
    var res = true;

    if(!StoreManager.isUpdated()) {
      //showLoading();


      Future.delayed(Duration(milliseconds: 50), (){
        showDialog(
          context: AppRoute.materialContext!,
          useSafeArea: false,
          useRootNavigator: false, // if true:error in internal Navigator
          barrierDismissible: true,
          barrierColor: Colors.yellow.shade300.withAlpha(100),
          builder: (BuildContext context) {
            return SizedBox(
              child: Text('gfds'),
            );
          },
        );
      });
      res = await StoreManager.requestLessonStores(state: this);
      //hideLoading();
    }

    prepareTabs();
    prepareLessonList();
    assistCtr.clearStates();

    if(!res) {
      assistCtr.addState(AssistController.state$error);
    }

    assistCtr.updateHead();
  }
}
