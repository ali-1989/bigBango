import 'package:flutter/material.dart';

import 'package:animator/animator.dart';
import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/api/helpers/fileHelper.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/features/overlayDialog.dart';
import 'package:iris_tools/modules/stateManagers/notifyRefresh.dart';
import 'package:iris_tools/modules/stateManagers/refresh.dart';

import 'package:app/pages/invite_page.dart';
import 'package:app/pages/profile_page.dart';
import 'package:app/pages/support_page.dart';
import 'package:app/structures/models/userModel.dart';
import 'package:app/system/enums.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appDialogIris.dart';
import 'package:app/tools/app/appDirectories.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appOverlay.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appSizes.dart';
import 'package:app/tools/userLoginTools.dart';

class DrawerMenuBuilder {
  static bool _isOpen = false;
  static int _drawerTime = 400;

  DrawerMenuBuilder._();

  static Future<void> toggleDrawer(BuildContext context){
    if(_isOpen){
      return hideDrawer(context);
    }
    else {
      return showDrawer(context);
    }
  }

  static Future<void> showDrawer(BuildContext context) async {
    if(_isOpen){
      return;
    }

    _isOpen = true;
    final content = OverlayScreenView(content: buildDrawer());
    final view = OverlayScreenView(content: content, backgroundColor: Colors.black45);

    AppOverlay.showScreen(context, view, canBack: true);
    await Future.delayed(Duration(milliseconds: _drawerTime), (){});
    return;
  }

  static Future<void> hideDrawer(BuildContext context, {int? millSec}) async {
    if(!_isOpen){
      return;
    }

    _isOpen = false;
    AppBroadcast.drawerMenuRefresher.update();
    final old = _drawerTime;
    _drawerTime = millSec?? _drawerTime;
    await Future.delayed(Duration(milliseconds: _drawerTime), (){
      AppOverlay.hideScreen(context);
    });

    if(millSec != null) {
      _drawerTime = old;
    }

    return;
  }

  static Widget buildDrawer({int? openMillSec}){
    final siz = MathHelper.minDouble(250, MathHelper.percent(AppSizes.instance.appWidth, 60));
    final child = WillPopScope(
      onWillPop: () async {
        DrawerMenuBuilder.toggleDrawer(AppRoute.getLastContext()!);
        return false;
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          DrawerMenuBuilder.toggleDrawer(AppRoute.getLastContext()!);
        },
          child: _buildDrawer()
      ),
    );

    return Refresh(
        controller: AppBroadcast.drawerMenuRefresher,
        builder: (_, ctr) {
        return AnimateWidget(
          resetOnRebuild: false,
          triggerOnInit: true,
          triggerOnRebuild: true,
          lowerBound: 0,
          upperBound: 1,
          repeats: 1,
          cycles: 1,
          duration: Duration(milliseconds: openMillSec?? _drawerTime),
          builder: (_, animate){
            double d;

            if(_isOpen){
              d = animate.fromTween((v) => Tween(begin: siz, end: 0.0))!;
            }
            else {
              d = animate.fromTween((v) => Tween(begin: 0.0, end: siz))!;
            }

            return Transform.translate(
                offset: Offset(d, 0),
                child: child
            );
          },
        );
      }
    );
  }

  static Widget _buildDrawer(){
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){/*ignore willPop() */},
        child: SizedBox(
          width: MathHelper.minDouble(250, MathHelper.percent(AppSizes.instance.appWidth, 60)),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
               borderRadius: BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15))
            ),

            child: ListView(
              children: [
                //SizedBox(height: 30),

                Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: (){
                        DrawerMenuBuilder.toggleDrawer(AppRoute.getLastContext()!);
                      },
                      icon: Image.asset(AppImages.arrowRightIco, color: Colors.black),
                    )
                ),

                _buildProfileSection(),

                SizedBox(height: 30),

                ListTile(
                  title: Text('پروفایل و اطلاعات'),
                  leading: Image.asset(AppImages.drawerProfileIco, width: 16, height: 16),
                  onTap: gotoProfilePage,
                  dense: true,
                  horizontalTitleGap: 0,
                  visualDensity: VisualDensity(horizontal: 0, vertical: -3.0),
                ),

                ListTile(
                  title: Text('کیف پول'),
                  leading: Image.asset(AppImages.drawerWalletIco, width: 16, height: 16),
                  onTap: gotoProfilePage,
                  dense: true,
                  horizontalTitleGap: 0,
                  visualDensity: VisualDensity(horizontal: 0, vertical: -3.0),
                ),

                ListTile(
                  title: Text('دعوت از دوستان'),
                  leading: Image.asset(AppImages.drawerSendIco, width: 16, height: 16),
                  onTap: gotoInvitePage,
                  dense: true,
                  horizontalTitleGap: 0,
                  visualDensity: VisualDensity(horizontal: 0, vertical: -3.0),
                ),

                ListTile(
                  title: Text('پشتیبانی'),
                  leading: Image.asset(AppImages.drawerSupportIco, width: 16, height: 16),
                  onTap: gotoSupportPage,
                  dense: true,
                  horizontalTitleGap: 0,
                  visualDensity: VisualDensity(horizontal: 0, vertical: -3.0),
                ),

                ListTile(
                  title: Text('گزارشات و آزمون ها'),
                  leading: Image.asset(AppImages.drawerLogIco, width: 16, height: 16),
                  onTap: gotoProfilePage,
                  dense: true,
                  horizontalTitleGap: 0,
                  visualDensity: VisualDensity(horizontal: 0, vertical: -3.0),
                ),

                ListTile(
                  title: Text(AppMessages.aboutUs),
                  leading: Image.asset(AppImages.drawerAboutIco, width: 16, height: 16),
                  onTap: gotoProfilePage,
                  dense: true,
                  horizontalTitleGap: 0,
                  visualDensity: VisualDensity(horizontal: 0, vertical: -3.0),
                ),

                ListTile(
                  title: Text('تنظیمات'),
                  leading: Image.asset(AppImages.drawerSettingIco, width: 16, height: 16),
                  onTap: gotoProfilePage,
                  dense: true,
                  horizontalTitleGap: 0,
                  visualDensity: VisualDensity(horizontal: 0, vertical: -3.0),
                ),

                if(Session.hasAnyLogin())
                  ListTile(
                    title: Text(AppMessages.logout).color(Colors.redAccent),
                    //leading: Icon(AppIcons.logout, size: 18, color: Colors.redAccent),
                    leading: Image.asset(AppImages.drawerExitIco, width: 16, height: 16),
                    onTap: onLogoffCall,
                    dense: true,
                    horizontalTitleGap: 0,
                    visualDensity: VisualDensity(horizontal: 0, vertical: -3.0),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildProfileSection(){
    if(Session.hasAnyLogin()){
      final user = Session.getLastLoginUser()!;

      return GestureDetector(
        onTap: (){},
        child: Column(
          children: [
            NotifyRefresh(
              notifier: AppBroadcast.avatarNotifier,
              builder: (ctx, data) {
                return Builder(
                  builder: (ctx){
                    if(user.profileModel != null){
                      final path = AppDirectories.getSavePathUri(user.profileModel!.url?? '', SavePathType.userProfile, user.avatarFileName);
                      final img = FileHelper.getFile(path);

                      if(img.existsSync() && img.lengthSync() == (user.profileModel!.volume?? 0)){
                        return CircleAvatar(
                          backgroundColor: ColorHelper.textToColor(user.nameFamily),
                          radius: 30,
                          child: Image.file(img),
                        );
                      }
                    }

                    checkAvatar(user);
                    return CircleAvatar(
                      backgroundColor: ColorHelper.textToColor(user.nameFamily),
                      radius: 30,
                      child: Image.asset(AppImages.profileBig),
                    );
                  },
                );
              },
            ),

            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                      Flexible(
                          child: Text(user.nameFamily,
                          maxLines: 1, overflow: TextOverflow.clip,
                          ).bold()
                      ),

                    /*IconButton(
                        onPressed: gotoProfilePage,
                        icon: Icon(AppIcons.report2, size: 18,).alpha()
                    ),*/
                ],
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 140,
      child: Center(
        child: Image.asset(AppImages.appIcon, height: 90,),
      ),
    );
  }

  /*static void shareAppCall() {
    AppBroadcast.homeScreenKey.currentState?.scaffoldState.currentState?.closeDrawer();
    ShareExtend.share('https://cafebazaar.ir/app/ir.vosatezehn.com', 'text');
  }*/

  static void gotoProfilePage() async {
    await DrawerMenuBuilder.toggleDrawer(AppRoute.getLastContext()!);
    AppRoute.push(AppRoute.getLastContext()!, ProfilePage(userModel: Session.getLastLoginUser()!));
  }

  static void gotoSupportPage() async {
    await DrawerMenuBuilder.toggleDrawer(AppRoute.getLastContext()!);
    AppRoute.push(AppRoute.getLastContext()!, SupportPage());
  }

  static void gotoInvitePage() async {
    await DrawerMenuBuilder.toggleDrawer(AppRoute.getLastContext()!);
    AppRoute.push(AppRoute.getLastContext()!, InvitePage());
  }

  static void onLogoffCall() async {
    await DrawerMenuBuilder.hideDrawer(AppRoute.getLastContext()!, millSec: 100);

    void yesFn(){
      UserLoginTools.forceLogoff(Session.getLastLoginUser()!.userId);
    }

    AppDialogIris.instance.showYesNoDialog(
      AppRoute.getBaseContext()!,
      desc: AppMessages.doYouWantLogoutYourAccount,
      dismissOnButtons: true,
      yesText: AppMessages.yes,
      noText: AppMessages.no,
      yesFn: yesFn,
      decoration: AppDialogIris.instance.dialogDecoration.copy()..positiveButtonBackColor = Colors.green,
    );
  }

  static void checkAvatar(UserModel user) async {
    if(user.profileModel?.url == null){
      return;
    }

    final path = AppDirectories.getSavePathUri(user.profileModel!.url!, SavePathType.userProfile, user.avatarFileName);
    final img = FileHelper.getFile(path);

    if(img.existsSync() && img.lengthSync() == user.profileModel!.volume!){
      return;
    }

    /*final dItm = DownloadUploadService.downloadManager.createDownloadItem(user.profileModel!.url!, tag: '${user.profileModel!.id!}');
    dItm.savePath = path;
    dItm.category = DownloadCategory.userProfile;

    DownloadUploadService.downloadManager.enqueue(dItm);*/
  }
}
