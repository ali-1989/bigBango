import 'package:app/structures/models/inviteUserModel.dart';
import 'package:app/system/session.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/clipboardHelper.dart';
import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/middleWare/requester.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appToast.dart';
import 'package:app/views/states/emptyData.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:app/views/states/waitToLoad.dart';

class InvitePage extends StatefulWidget {
  const InvitePage({Key? key}) : super(key: key);

  @override
  State<InvitePage> createState() => _InvitePageState();
}
///==============================================================================================
class _InvitePageState extends StateBase<InvitePage> {
  Requester requester = Requester();
  String description = '';
  TextEditingController txtCtr = TextEditingController();
  List<InviteUserModel> userList = [];

  @override
  void initState(){
    super.initState();

    description = 'با دعوت هر یک از دوستان خود به استفاده از این اپلیکیشن شما مبلغ 20 هزار تومان تخفیف خرید '
        'دریافت می کنید. پس کد معرف خود را برای دوستان خود ارسال کنید و آنها را دعوت کنید از '
        'این اپلیکیشن استفاده کنند.';

    txtCtr.text = description;

    assistCtr.addState(AssistController.state$loading);
    requestData();
  }

  @override
  void dispose(){
    requester.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
        builder: (_, ctr, data){
          return Scaffold(
            body: buildBody(),
          );
        }
    );
  }

  Widget buildBody(){
    return Column(
      children: [
        const SizedBox(height: 30),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 10),
                Image.asset(AppImages.drawerSendIco, color: AppColors.red),
                const SizedBox(width: 8),
                Text('دعوت از دوستان', style: const TextStyle(fontSize: 17)),
              ],
            ),

            RotatedBox(
                quarterTurns: 2,
                child: BackButton()
            ),
          ],
        ),

        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(width: 10),
            SizedBox(
              height: 16,
              width: 1.5,
              child: ColoredBox(
                color: AppColors.red,
              ),
            ),
            const SizedBox(width: 8),
            Text('چرا دوستانم را دعوت کنم؟', style: const TextStyle(fontSize: 11)),
          ],
        ),

        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10)
            ),
            child: TextField(
              controller: txtCtr,
              minLines: 5,
              maxLines: 5,
              enabled: false,
              textAlign: TextAlign.justify,
              strutStyle: StrutStyle(height: 1.3),
              decoration: InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10)
              ),
            ).wrapDotBorder(padding: EdgeInsets.zero, color: Colors.black12),
          ),
        ),

        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: Text('کد معرف شما'),
              ),

              GestureDetector(
                onTap: copyCodeCall,
                child: Row(
                  children: [
                    Text('${Session.getLastLoginUser()?.mobile}').color(AppColors.red),
                    const SizedBox(width: 6),
                    Icon(AppIcons.copy,
                        size: 15,
                        color: Colors.grey.shade500
                    ).wrapBackground(
                        backColor: Colors.grey.shade100,
                        borderColor: Colors.transparent,
                        radius: 0,
                        padding: EdgeInsets.all(3)
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
            ],
          ).wrapDotBorder(padding: EdgeInsets.zero, radius: 5),
        ),

        const SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(width: 10),
            SizedBox(
              height: 16,
              width: 1.5,
              child: ColoredBox(
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            Text('کاربرانی که از کد شما استفاده کردند', style: const TextStyle(fontSize: 11)),
          ],
        ),

        const SizedBox(height: 16),
        Expanded(
          child: Builder(
            builder: (context) {

              if(assistCtr.hasState(AssistController.state$loading)){
                return WaitToLoad();
              }

              if(assistCtr.hasState(AssistController.state$error)){
                return ErrorOccur(onRefresh: onRefresh, showBackButton: false);
              }

              if(userList.isEmpty){
                return SizedBox.expand(
                  child: Center(
                    child: EmptyData(),
                  ),
                );
              }

              return ListView.builder(
                itemCount: userList.length,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemBuilder: itemBuilder
              );
            }
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }

  Widget itemBuilder(_, idx){
    final item = userList[idx];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: SizedBox(
        height: 50,
        child: ColoredBox(
          color: Colors.grey.shade200,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: ColorHelper.textToColor(item.getName()),
                      child: item.avatar == null
                      ? Text(item.getFirstChar())
                          : Image.network(item.avatar!.fileLocation!),
                    ),
                    SizedBox(width: 8),
                    Text(item.getName())
                  ],
                ),

                Text('20.000 تومان')
              ],
            ),
          ),
        ),
      ),
    );
  }

  void copyCodeCall(){
    ClipboardHelper.insert('${Session.getLastLoginUser()?.mobile}');
    AppToast.showToast(context, 'کد شما کپی شد');
  }

  void onRefresh(){
    assistCtr.clearStates();
    assistCtr.addStateAndUpdateHead(AssistController.state$loading);

    requestData();
  }

  void requestData(){
    requester.httpRequestEvents.onFailState = (requester, res) async {
      assistCtr.clearStates();
      assistCtr.addStateAndUpdateHead(AssistController.state$error);
    };

    requester.httpRequestEvents.onStatusOk = (requester, map) async {
      final data = map['data'];

      userList.clear();

      if(data is List){
        for(final x in data){
          userList.add(InviteUserModel.fromMap(x));
        }
      }

      assistCtr.clearStates();
      assistCtr.updateHead();
    };

    requester.prepareUrl(pathUrl: '/profile/introduces?Page=1&Size=100');
    requester.methodType = MethodType.get;
    requester.request(context);
  }
}
