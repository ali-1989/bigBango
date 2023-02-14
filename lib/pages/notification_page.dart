import 'package:app/managers/notificationManager.dart';
import 'package:app/structures/models/notificationModel.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/tools/app/appBroadcast.dart';
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

    if(NotificationManager.isInRequest){
      assistCtr.addStateWithClear(AssistController.state$loading);
    }
    else if(!NotificationManager.isRequested){
      assistCtr.addStateWithClear(AssistController.state$loading);
      NotificationManager.requestNotification();
    }
  }

  @override
  void dispose(){
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
          return ErrorOccur(message: 'اعلانی وجود ندارد', onTryAgain: tryLoadClick);
        }

        return Padding(
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
              child: GridView.builder(
                itemCount: NotificationManager.notificationList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisExtent: 220),
                itemBuilder: buildListItem,
              ),
            ),
          )
        );
      },
    );
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
    return SizedBox();
  }
}
