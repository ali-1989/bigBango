import 'package:app/managers/notificationManager.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/dateTools.dart';
import 'package:app/views/states/emptyData.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:app/views/states/waitToLoad.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State createState() => _NotificationPageState();
}
///========================================================================================
class _NotificationPageState extends StateBase<NotificationPage> {
  RefreshController refreshController = RefreshController(initialRefresh: false);

  @override
  void initState(){
    super.initState();

    AppBroadcast.notifyMessageNotifier.addListener(notifierListener);

    if(AppBroadcast.notifyMessageNotifier.states.isInRequest){
      assistCtr.addStateWithClear(AssistController.state$loading);
    }
    else if(!AppBroadcast.notifyMessageNotifier.states.isRequested){
      assistCtr.addStateWithClear(AssistController.state$loading);
      NotificationManager.requestNotification();
    }
  }

  @override
  void dispose(){
    AppBroadcast.notifyMessageNotifier.removeListener(notifierListener);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
      id: AppBroadcast.assistId$notificationPage,
      controller: assistCtr,
      builder: (_, ctr, data){
        if(assistCtr.hasState(AssistController.state$error)){
          return ErrorOccur(onTryAgain: tryLoadClick);
        }

        if(assistCtr.hasState(AssistController.state$loading)){
          return WaitToLoad();
        }

        if(NotificationManager.notificationList.isEmpty){
          return EmptyData(message: 'اعلانی وجود ندارد', onTryAgain: tryLoadClick);
        }

        return Column(
          children: [
            SizedBox(height: 80),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Image.asset(AppImages.drawerSendIco, width: 32, height: 32, color: AppColors.red),
                  SizedBox(width: 5),
                  Text('اعلانات', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                ],
              ),
            ),

            SizedBox(height: 40),

            /// list
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: RefreshConfiguration(
                  headerBuilder: () => MaterialClassicHeader(),
                  footerBuilder: () => PublicAccess.classicFooter,
                  enableScrollWhenRefreshCompleted: true,
                  enableLoadingWhenFailed : true,
                  hideFooterWhenNotFull: true,
                  enableBallisticLoad: true,
                  enableLoadingWhenNoData: false,
                  child: SmartRefresher(
                    enablePullDown: false,
                    enablePullUp: true,
                    controller: refreshController,
                    onRefresh: (){},
                    onLoading: onLoadingMoreCall,
                    child: ListView.builder(
                      itemCount: NotificationManager.notificationList.length,
                      itemBuilder: buildListItem,
                    ),
                  ),
                )
              ),
            ),
          ],
        );
      },
    );
  }

  void notifierListener(notifier){
    if(refreshController.isLoading) {
      refreshController.loadComplete();
    }

    if(!AppBroadcast.notifyMessageNotifier.states.hasNextPage){
      refreshController.loadNoData();
    }

    if(AppBroadcast.notifyMessageNotifier.states.isOk()){
      assistCtr.clearStates();
    }
    else {
      assistCtr.addStateWithClear(AssistController.state$error);
    }

    assistCtr.updateHead();
  }

  void onLoadingMoreCall(){
    NotificationManager.requestNotification();
  }

  void tryLoadClick() async {
    assistCtr.clearStates();
    assistCtr.addStateAndUpdateHead(AssistController.state$loading);

    NotificationManager.requestNotification();
  }

  Widget buildListItem(_, int idx) {
    final notify = NotificationManager.notificationList[idx];

    return IntrinsicHeight(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            width: 2,
              height: double.infinity,
              child: ColoredBox(color: AppColors.red)
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(notify.title).bold(),

                      Row(
                        children: [
                          Text(DateTools.dateAndHmRelative(notify.createAt)),
                          SizedBox(width: 5),
                          Icon(AppIcons.calendar, size: 12)
                        ],
                      ),
                    ],
                  ),

                  Text(notify.body),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
