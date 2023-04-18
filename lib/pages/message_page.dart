import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:app/managers/messageManager.dart';
import 'package:app/pages/ticket_detail_page.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/enums/enums.dart';
import 'package:app/structures/enums/notificationType.dart';
import 'package:app/structures/models/messageModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/tools/app/appBadge.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/dateTools.dart';
import 'package:app/tools/routeTools.dart';
import 'package:app/views/components/fullScreenImage.dart';
import 'package:app/views/states/emptyData.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:app/views/states/waitToLoad.dart';

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

    AppBroadcast.messagePageIsOpen = true;
    AppBroadcast.messageNotifier.addListener(notifierListener);

    if(AppBroadcast.messageNotifier.states.isInRequest){
      assistCtr.addStateWithClear(AssistController.state$loading);
    }
    else if(!AppBroadcast.messageNotifier.states.isRequested){
      assistCtr.addStateWithClear(AssistController.state$loading);
      MessageManager.requestMessages();
    }
    else {
      addPostOrCall(fn: (){
        AppBadge.setMessageBadge(0);
        AppBadge.refreshViews();
      });

      MessageManager.check();
      MessageManager.requestUpdateMessageSeen(MessageManager.messageList);
    }
  }

  @override
  void dispose(){
    AppBroadcast.messagePageIsOpen = false;
    AppBroadcast.messageNotifier.removeListener(notifierListener);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
      builder: (_, ctr, data){
        if(assistCtr.hasState(AssistController.state$error)){
          return ErrorOccur(onTryAgain: tryLoadClick);
        }

        if(assistCtr.hasState(AssistController.state$loading)){
          return WaitToLoad();
        }

        if(MessageManager.messageList.isEmpty){
          return EmptyData(message: 'اعلانی وجود ندارد', onTryAgain: tryLoadClick);
        }

        return Column(
          children: [
            SizedBox(height: 80),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                children: [
                  Image.asset(AppImages.drawerSendIco, width: 32, height: 32, color: AppColors.red),
                  SizedBox(width: 5),
                  Text('اعلانات', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w200)),
                ],
              ),
            ),

            SizedBox(height: 30),

            /// list
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
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
                    child: ListView.separated(
                      itemCount: MessageManager.messageList.length,
                      itemBuilder: buildListItem,
                      separatorBuilder: (BuildContext context, int index) {
                        return Divider();
                      },
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

  void notifierListener(notifier, {dynamic data}){
    if(AppBroadcast.messageNotifier.states.receivedNewFirebaseMessage){
      AppBroadcast.messageNotifier.states.receivedNewFirebaseMessage = false;
      MessageManager.reset();

      assistCtr.addStateWithClear(AssistController.state$loading);
      assistCtr.updateHead();
      return;
    }

    if(refreshController.isLoading) {
      refreshController.loadComplete();
    }

    if(!AppBroadcast.messageNotifier.states.hasNextPage){
      refreshController.loadNoData();
    }

    if(AppBroadcast.messageNotifier.states.isOk()){
      assistCtr.clearStates();
    }
    else {
      assistCtr.addStateWithClear(AssistController.state$error);
    }

    assistCtr.updateHead();

    if(mounted){
      MessageManager.requestUpdateMessageSeen(MessageManager.messageList);
      AppBadge.setMessageBadge(0);
      AppBadge.refreshViews();
    }
  }

  void onLoadingMoreCall(){
    MessageManager.requestMessages();
  }

  void tryLoadClick() async {
    assistCtr.clearStates();
    assistCtr.addStateAndUpdateHead(AssistController.state$loading);

    MessageManager.requestMessages();
  }

  Widget buildListItem(_, int idx) {
    final notify = MessageManager.messageList[idx];

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        onItemClick(notify);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: IntrinsicHeight(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(notify.title),

                          Row(
                            children: [
                              Text(DateTools.dateAndHmRelative(notify.createAt)).alpha(alpha: 220),
                              SizedBox(width: 5),
                              Icon(AppIcons.calendar, size: 12).alpha(alpha: 220)
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 8),
                      Text(notify.body).fsR(-1).alpha(),
                      SizedBox(height: 5),

                      Visibility(
                        visible: notify.hasContent(),
                          child: InputChip(
                            visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                            backgroundColor: Colors.black26,
                            elevation: 0,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            labelPadding: EdgeInsets.symmetric(horizontal: 8, vertical: -2),
                            label: Text('نمایش محتوا').fsR(-3).color(Colors.white),
                            onPressed: (){
                              if(notify.image?.fileLocation != null){
                                final view = FullScreenImage(
                                  heroTag: '',
                                  imageObj: notify.image!.fileLocation,
                                  imageType: ImageType.network,
                                );

                                RouteTools.pushPage(context, view);
                              }
                            },
                          )
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onItemClick(MessageModel notify) async {
    if(notify.type == NotificationType.ticket){
      if(notify.data is Map) {
        await RouteTools.pushPage(context, TicketDetailPage(ticketId: notify.data!['id']));
      }
    }
  }
}
