import 'package:app/managers/storeManager.dart';
import 'package:app/services/event_dispatcher_service.dart';
import 'package:app/structures/models/lessonModels/storeModel.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/tools/app/appSnack.dart';
import 'package:app/tools/currencyTools.dart';
import 'package:app/views/sheets/store@invoiceSheet.dart';
import 'package:app/views/sheets/support@selectBuyMethodSheet.dart';
import 'package:app/views/states/emptyData.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:app/views/states/waitToLoad.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:iris_tools/widgets/optionsRow/checkRow.dart';

class StorePage extends StatefulWidget {
  const StorePage({Key? key}) : super(key: key);

  @override
  State createState() => _StorePageState();
}
///========================================================================================
class _StorePageState extends StateBase<StorePage> with TickerProviderStateMixin {
  late TabController tabCtr;
  int tabIdx = 0;
  bool selectAllState = false;
  bool isInGetWay = false;
  List<String> tabNames = [];
  List<StoreLessonModel> lessonList = [];
  List<StoreLessonModel> selectedLessons = [];
  late StoreModel currentStore;

  @override
  void initState(){
    super.initState();

    EventDispatcherService.attachFunction(EventDispatcher.appResume, onBackOfBankGetWay);

    tabCtr = TabController(length: 1, vsync: this);
    assistCtr.addState(AssistController.state$loading);
    requestStores();
  }

  @override
  void dispose(){
    EventDispatcherService.deAttachFunction(EventDispatcher.appResume, onBackOfBankGetWay);

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
            crossAxisAlignment: CrossAxisAlignment.start,
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

                  Visibility(
                    visible: selectedLessons.isNotEmpty,
                    child: SizedBox(
                      height: 28,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                          onPressed: prepareBuy,
                          child: Text('ثبت سفارش')
                      ),
                    ),
                  )
                ],
              ),

              SizedBox(height: 20),
              Text('سطوح:').alpha(),

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

              CheckBoxRow(
                  value: selectAllState,
                  description: Text('  انتخاب همه'),
                  checkbox: Checkbox(
                    value: selectAllState,
                    side: BorderSide(width: 0.5, color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    visualDensity: VisualDensity(horizontal: -4),
                    onChanged: onSelectAllValueChange,
                  ),
                  onChanged: (v){
                    selectAllState = !selectAllState;
                    assistCtr.updateHead();
                  }
              ),

              SizedBox(height: 10),
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
        onChangeState(itm);
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: ColoredBox(
            color: Colors.grey.withAlpha(50),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ColoredBox(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 3),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 1.5,
                          height: 20,
                          child: ColoredBox(
                            color: AppColors.red,
                          ),
                        ),

                        const SizedBox(width: 12),
                        Checkbox(
                            value: itm.isSelected,
                            side: BorderSide(width: 0.5, color: Colors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                            visualDensity: VisualDensity(horizontal: -4),
                            onChanged: (v){
                              onChangeState(itm);
                            }
                        ),

                        const SizedBox(width: 12),

                        Card(
                            elevation: 0,
                            color: Colors.grey.shade100,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              child: Text('${itm.number}', style: const TextStyle(color: Colors.black)),
                            )
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 5),
                            child: Text(itm.title),
                          ),
                        ),

                        Text(CurrencyTools.formatCurrency(itm.amount)).alpha(),

                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void tryAgain(){
    assistCtr.addStateWithClear(AssistController.state$loading);
    assistCtr.updateHead();

    requestStores();
  }

  void checkSelectedState(){
    if(selectedLessons.isEmpty){
      selectAllState = false;
    }

    if(selectedLessons.length == lessonList.length) {
      selectAllState = true;
    }
  }

  void onChangeState(StoreLessonModel itm){
    if(itm.isSelected){
      itm.isSelected = false;
      selectedLessons.remove(itm);
    }
    else {
      itm.isSelected = true;
      selectedLessons.add(itm);
    }

    checkSelectedState();
    assistCtr.updateHead();
  }

  void onSelectAllValueChange(bool? value) {
    if(selectAllState){
      selectAllState = false;

      for (final element in currentStore.lessons) {
        element.isSelected = false;
        selectedLessons.remove(element);
      }
    }
    else {
      selectAllState = true;

      for (final element in currentStore.lessons) {
        element.isSelected = true;
        selectedLessons.add(element);
      }
    }

    assistCtr.updateHead();
  }

  void onTabClick(int value) {
    selectedLessons.clear();
    selectAllState = false;

    for (var element in currentStore.lessons) {
      element.isSelected = false;
    }

    tabIdx = value;
    prepareLessonList();

    assistCtr.updateHead();
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

    if(StoreManager.getStoreLessonList().isEmpty){
      return;
    }

    currentStore = StoreManager.getStoreLessonList()[tabIdx];

    lessonList.addAll(currentStore.lessons);
  }

  void prepareBuy() async {
    final ok = await showInvoiceSheet();

    if(ok is bool && ok){
      showLoading();
      final balance = await PublicAccess.requestUserBalance();
      await hideLoading();

      if(balance == null){
        AppSnack.showError(context, 'متاسفانه خطایی رخ داده است');
        return;
      }

      await showSelectMethodSheet(balance);
      isInGetWay = true;
    }
  }

  Future showInvoiceSheet() {
    return AppSheet.showSheetCustom(
        context,
        contentColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_){
          return InvoiceSheet(lessons: selectedLessons);
        },
        routeName: 'showInvoiceSheet'
    );
  }

  Future showSelectMethodSheet(int balance) {
    return AppSheet.showSheetCustom(
        context,
        contentColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_){
          return SelectBuyMethodSheet(
              amount: calcPrice(),
              lessonIds: selectedLessons.map((e) => e.id).toList(),
              userBalance: balance
          );
        },
        routeName: 'showSelectMethodSheet'
    );
  }

  void onBackOfBankGetWay({data}) {
    if(isInGetWay){
      isInGetWay = false;
      StoreManager.setUnUpdate();
      AppBroadcast.layoutPageKey.currentState!.gotoPage(0);
    }
  }

  int calcPrice(){
    int all = 0;

    for(final x in selectedLessons){
      all += x.amount;
    }

    return all;
  }

  void requestStores() async {
    var res = true;

    if(!StoreManager.isUpdated()) {
      res = await StoreManager.requestLessonStores(state: this);
      StoreManager.setUpdate();
    }

    prepareTabs();
    assistCtr.clearStates();

    if(StoreManager.getStoreLessonList().isNotEmpty){
      final level = Session.getLastLoginUser()!.courseLevel;

      for(int i = 0; i < StoreManager.getStoreLessonList().length; i++){
        final x = StoreManager.getStoreLessonList()[i];

        if(x.id == level?.id){
          tabCtr.animateTo(i);
          tabIdx = i;
          break;
        }
      }
    }

    prepareLessonList();

    if(!res) {
      assistCtr.addState(AssistController.state$error);
    }

    assistCtr.updateHead();
  }
}
