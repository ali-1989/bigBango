import 'package:flutter/material.dart';

import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/api/helpers/fileHelper.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/widgets/irisImageView.dart';

import 'package:app/services/login_service.dart';
import 'package:app/services/session_service.dart';
import 'package:app/structures/enums/appEvents.dart';
import 'package:app/structures/enums/enums.dart';
import 'package:app/structures/models/userModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appDialogIris.dart';
import 'package:app/tools/app/appDirectories.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appSizes.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/tools/routeTools.dart';
import 'package:app/views/baseComponents/layoutComponent.dart';
import 'package:app/views/pages/about_page.dart';
import 'package:app/views/pages/invite_page.dart';
import 'package:app/views/pages/logs_page.dart';
import 'package:app/views/pages/profile_page.dart';
import 'package:app/views/pages/support_page.dart';
import 'package:app/views/pages/transaction_page.dart';
import 'package:app/views/pages/wallet_page.dart';

class DrawerMenuBuilder {

  DrawerMenuBuilder._();

  static void toggleDrawer(){
    LayoutComponentState.toggleDrawer();
  }

  static Widget buildDrawer(){
    return SizedBox(
      width: MathHelper.minDouble(250, MathHelper.percent(AppSizes.instance.appWidth, 60)),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
           borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15))
        ),

        child: Builder(
          builder: (context) {
            return ListTileTheme(
              data: ListTileTheme.of(context).copyWith(
                style: ListTileStyle.drawer,
                titleTextStyle: AppThemes.baseTextStyle(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              ),
              child: ListView(
                children: [
                  //SizedBox(height: 30),

                  Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        onPressed: (){
                          LayoutComponentState.toggleDrawer();
                        },
                        icon: Image.asset(AppImages.arrowRightIco, color: Colors.black),
                      )
                  ),

                  _buildProfileSection(),

                  const SizedBox(height: 30),

                  ListTile(
                    title: const Text('پروفایل و اطلاعات'),
                    leading: Image.asset(AppImages.drawerProfileIco, width: 20, height: 20),
                    onTap: gotoProfilePage,
                    dense: true,
                    horizontalTitleGap: 0,
                    visualDensity: const VisualDensity(horizontal: 0, vertical: -3.0),
                  ),

                  ListTile(
                    title: const Text('کیف پول'),
                    leading: Image.asset(AppImages.drawerWalletIco, width: 20, height: 20),
                    onTap: gotoWalletPage,
                    dense: true,
                    horizontalTitleGap: 0,
                    visualDensity: const VisualDensity(horizontal: 0, vertical: -3.0),
                  ),

                  ListTile(
                    title: const Text('تراکنش ها'),
                    leading: Image.asset(AppImages.transactionMenuIco, width: 20, height: 20),
                    onTap: gotoTransactionPage,
                    dense: true,
                    horizontalTitleGap: 0,
                    visualDensity: const VisualDensity(horizontal: 0, vertical: -3.0),
                  ),

                  ListTile(
                    title: const Text('پشتیبانی'),
                    leading: Image.asset(AppImages.drawerSupportIco, width: 20, height: 20),
                    onTap: gotoSupportPage,
                    dense: true,
                    horizontalTitleGap: 0,
                    visualDensity: const VisualDensity(horizontal: 0, vertical: -3.0),
                  ),

                  ListTile(
                    title: const Text('دعوت از دوستان'),
                    leading: Image.asset(AppImages.drawerSendIco, width: 20, height: 20),
                    onTap: gotoInvitePage,
                    dense: true,
                    horizontalTitleGap: 0,
                    visualDensity: const VisualDensity(horizontal: 0, vertical: -3.0),
                  ),

                  /*ListTile(
                    title: Text('گزارشات و آزمون ها'),
                    leading: Image.asset(AppImages.drawerLogIco, width: 20, height: 20),
                    onTap: gotoLogsPage,
                    dense: true,
                    horizontalTitleGap: 0,
                    visualDensity: VisualDensity(horizontal: 0, vertical: -3.0),
                  ),*/

                  ListTile(
                    title: Text(AppMessages.aboutUs),
                    leading: Image.asset(AppImages.drawerAboutIco, width: 20, height: 20),
                    onTap: gotoAboutPage,
                    dense: true,
                    horizontalTitleGap: 0,
                    visualDensity: const VisualDensity(horizontal: 0, vertical: -3.0),
                  ),

                  /*ListTile(
                    title: Text('تنظیمات'),
                    leading: Image.asset(AppImages.drawerSettingIco, width: 20, height: 20),
                    onTap: gotoProfilePage,
                    dense: true,
                    horizontalTitleGap: 0,
                    visualDensity: VisualDensity(horizontal: 0, vertical: -3.0),
                  ),*/

                  if(SessionService.hasAnyLogin())
                    ListTile(
                      title: Text(AppMessages.logout),/*.color(Colors.redAccent),*/
                      //leading: Icon(AppIcons.logout, size: 18, color: Colors.redAccent),
                      leading: Image.asset(AppImages.drawerExitIco, width: 20, height: 20),
                      onTap: onLogoffCall,
                      dense: true,
                      horizontalTitleGap: 0,
                      visualDensity: const VisualDensity(horizontal: 0, vertical: -3.0),
                    ),
                ],
              ),
            );
          }
        ),
      ),
    );
  }

  static Widget _buildProfileSection(){
    return StreamBuilder(
      stream: EventNotifierService.getStream(AppEvents.userProfileChange),
      builder: (_, data){
        if(SessionService.hasAnyLogin()){
          final user = SessionService.getLastLoginUser()!;
          return GestureDetector(
            onTap: (){
              gotoProfilePage();
            },
            child: Column(
              children: [
                Builder(
                  builder: (ctx) {
                    return Builder(
                      builder: (ctx){
                        if(user.hasAvatar()){
                          //final path = AppDirectories.getSavePathUri(user.avatarModel!.fileLocation?? '', SavePathType.userProfile, user.avatarFileName);
                          //final img = FileHelper.getFile(path);
                          //if(img.existsSync() && img.lengthSync() == (user.avatarModel!.volume?? 0)){

                          return CircleAvatar(
                              backgroundColor: ColorHelper.textToColor(user.nameFamily),
                              radius: 35,
                              child: IrisImageView(
                                height: 70,
                                width: 70,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                                beforeLoadWidget: const CircularProgressIndicator(),
                                bytes: user.avatarModel?.bytes,
                                url: user.avatarModel?.fileLocation,
                                onDownloadFn: (bytes, path){
                                  user.avatarModel?.bytes = bytes;
                                },
                              ),
                            );
                        }

                        //checkAvatar(user);
                        return CircleAvatar(
                          backgroundColor: ColorHelper.textToColor(user.nameFamily),
                          radius: 35,
                          child: Image.asset(AppImages.profileBig),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 10),
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
      },
    );
  }

  /*static void shareAppCall() {
    AppBroadcast.homeScreenKey.currentState?.scaffoldState.currentState?.closeDrawer();
    ShareExtend.share('https://cafebazaar.ir/app/ir.vosatezehn.com', 'text');
  }*/

  static void gotoProfilePage() async {
    await LayoutComponentState.toggleDrawer();
    RouteTools.pushPage(RouteTools.getTopContext()!, ProfilePage(userModel: SessionService.getLastLoginUser()!));
  }

  static void gotoAboutPage() async {
    await LayoutComponentState.toggleDrawer();
    RouteTools.pushPage(RouteTools.getTopContext()!, const AboutPage());
  }

  static void gotoWalletPage() async {
    await LayoutComponentState.toggleDrawer();
    RouteTools.pushPage(RouteTools.getTopContext()!, const WalletPage());
  }

  static void gotoTransactionPage() async {
    await LayoutComponentState.toggleDrawer();
    RouteTools.pushPage(RouteTools.getTopContext()!, const TransactionsPage());
  }

  static void gotoSupportPage() async {
    await LayoutComponentState.toggleDrawer();
    RouteTools.pushPage(RouteTools.getTopContext()!, const SupportPage());
  }

  static void gotoLogsPage() async {
    await LayoutComponentState.toggleDrawer();
    RouteTools.pushPage(RouteTools.getTopContext()!, const LogsPage());
  }

  static void gotoInvitePage() async {
    await LayoutComponentState.toggleDrawer();
    RouteTools.pushPage(RouteTools.getTopContext()!, const InvitePage());
  }

  static void onLogoffCall() async {
    await LayoutComponentState.hideDrawer(millSec: 100);

    bool yesFn(ctx){
      LoginService.forceLogoff(SessionService.getLastLoginUser()!.userId);
      return false;
    }

    AppDialogIris.instance.showYesNoDialog(
      RouteTools.getBaseContext()!,
      desc: AppMessages.doYouWantLogoutYourAccount,
      dismissOnButtons: true,
      yesText: AppMessages.yes,
      noText: AppMessages.no,
      yesFn: yesFn,
      decoration: AppDialogIris.instance.dialogDecoration.copy()..positiveButtonBackColor = Colors.green,
    );
  }

  static void checkAvatar(UserModel user) async {
    if(user.avatarModel?.fileLocation == null){
      return;
    }

    final path = AppDirectories.getSavePathUri(user.avatarModel!.fileLocation!, SavePathType.userProfile, user.avatarFileName);
    final img = FileHelper.getFile(path);

    if(img.existsSync() && img.lengthSync() == user.avatarModel!.volume!){
      return;
    }

    /*final dItm = DownloadUploadService.downloadManager.createDownloadItem(user.profileModel!.url!, tag: '${user.profileModel!.id!}');
    dItm.savePath = path;
    dItm.category = DownloadCategory.userProfile;

    DownloadUploadService.downloadManager.enqueue(dItm);*/
  }
}
