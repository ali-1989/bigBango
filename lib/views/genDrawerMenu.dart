import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/api/helpers/fileHelper.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/modules/stateManagers/notifyRefresh.dart';
import 'package:iris_tools/modules/stateManagers/refresh.dart';

import 'package:app/models/userModel.dart';

import 'package:app/system/enums.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appDialogIris.dart';
import 'package:app/tools/app/appDirectories.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appSizes.dart';
import 'package:app/tools/userLoginTools.dart';

class DrawerMenuBuilder {
  DrawerMenuBuilder._();

  //static Widget? _drawer;

  static Widget getDrawer(){
    return Refresh(
      controller: AppBroadcast.drawerMenuRefresher,
      builder: (ctx, ctr){
        return _buildDrawer();
      },
    );
  }

  static Widget _buildDrawer(){
    return SizedBox(
      width: MathHelper.minDouble(400, MathHelper.percent(AppSizes.instance.appWidth, 60)),
      child: Drawer(
        child: ListView(
          children: [
            SizedBox(height: 32),

            _buildProfileSection(),

            SizedBox(height: 10),

            if(Session.hasAnyLogin())
              ListTile(
                title: Text(AppMessages.logout).color(Colors.redAccent),
                leading: Icon(AppIcons.logout, size: 18, color: Colors.redAccent),
                onTap: onLogoffCall,
              ),

            /*ListTile(
              title: Text(AppMessages.favorites),
              leading: Icon(AppIcons.heart),
              onTap: gotoFavoritesPage,
            ),

            ListTile(
              title: Text(AppMessages.contactUs),
              leading: Icon(AppIcons.message),
              onTap: gotoContactUsPage,
            ),

            ListTile(
              title: Text(AppMessages.aboutUs),
              leading: Icon(AppIcons.infoCircle),
              onTap: gotoAboutUsPage,
            ),*/
          ],
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
                          backgroundColor: ColorHelper.textToColor(user.nameFamily,),
                          radius: 30,
                          child: Image.file(img),
                        );
                      }
                    }

                    checkAvatar(user);
                    return CircleAvatar(
                      backgroundColor: ColorHelper.textToColor(user.nameFamily,),
                      radius: 30,
                      child: Image.asset(AppImages.appIcon, ),
                    );
                  },
                );
              },
            ),

            SizedBox(height: 8,),
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

  static void onLogoffCall(){
    void yesFn(){
      UserLoginTools.forceLogoff(Session.getLastLoginUser()!.userId);
    }

    AppDialogIris.instance.showYesNoDialog(
      AppRoute.getContext(),
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