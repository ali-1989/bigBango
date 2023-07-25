import 'package:flutter/material.dart';

import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/widgets/irisImageView.dart';

import 'package:app/managers/settings_manager.dart';
import 'package:app/services/session_service.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/enums/appEvents.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/tools/app/appSizes.dart';
import 'package:app/views/baseComponents/layoutComponent.dart';
import 'package:app/views/sheets/changeLanguageLevelSheet.dart';

/*class AppBarCustom2 extends AppBar {

  AppBarCustom2({
    super.key,
    super.leading,
    super.automaticallyImplyLeading = true,
    super.title,
    super.actions,
    super.flexibleSpace,
    super.bottom,
    super.elevation,
    super.scrolledUnderElevation,
    super.shadowColor,
    super.surfaceTintColor,
    super.backgroundColor,
    super.foregroundColor,
    super.iconTheme,
    super.actionsIconTheme,
    super.primary = true,
    super.centerTitle,
    super.excludeHeaderSemantics = false,
    super.titleSpacing,
    super.toolbarOpacity = 1.0,
    super.bottomOpacity = 1.0,
    super.toolbarHeight,
    super.leadingWidth,
    super.toolbarTextStyle,
    super.titleTextStyle,
    super.systemOverlayStyle,
    //super.shape,
  }) : super();

  @override
  Size get preferredSize {
    //MediaQuery.of(context).padding.top + kToolbarHeight;
    // AppBar().preferredSize.height;

    if(isWeb()){
      return Size.zero;
    }

    return const Size.fromHeight(kToolbarHeight);
  }

  bool isWeb(){
    return kIsWeb;
  }
}*/
///=====================================================================================================================
class AppBarCustom extends StatefulWidget implements PreferredSizeWidget {

  const AppBarCustom({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AppBarCustomState();
  }

  @override
  Size get preferredSize {
    return Size.fromHeight((kToolbarHeight + 40) * AppSizes.instance.powerHeight);
  }
}
///=====================================================================================================================
class AppBarCustomState extends StateBase<AppBarCustom> {

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage(AppImages.statusbar),
              fit: BoxFit.fill,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 14 *pw/*22*/, 15, 0),
                  child: GestureDetector(
                    onTap: () async {
                      LayoutComponentState.toggleDrawer();
                    },
                    child: Row(
                      children: [
                        Image.asset(AppImages.menuIco),
                        const SizedBox(width: 10),
                        Image.asset(AppImages.bigbangoSmallText),
                      ],
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: onLevelClick,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(10, 8*pw, 0, 0),
                    child: Row(
                      children: [
                        const Icon(AppIcons.arrowDropDown),

                        TextButton(
                          onPressed: onLevelClick,
                          style: TextButton.styleFrom(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: const VisualDensity(horizontal: -4, vertical: -2),
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                            minimumSize: Size.zero,
                            foregroundColor: Colors.black,
                          ),
                          child: Text(SettingsManager.getCourseLevelById(SessionService.getLastLoginUser()?.courseLevel?.id?? 1)?.name?? '-'),
                        ),

                        Image.asset(AppImages.levelBadgeIco),
                      ],
                    ),
                  ),
                )
              ],
            ),

           Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                StreamBuilder(
                  stream: EventNotifierService.getStream(AppEvents.userProfileChange),
                  builder: (_, data) {
                      final user = SessionService.getLastLoginUser();

                      if(user != null && user.hasAvatar()){
                        return CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.transparent,
                          child: IrisImageView(
                            height: 40*pw,
                            width: 40*pw,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            beforeLoadWidget: const CircularProgressIndicator(),
                            bytes: user.avatarModel?.bytes,
                            url: user.avatarModel?.fileLocation,
                            onDownloadFn: (bytes, path){
                              user.avatarModel?.bytes = bytes;
                            },
                          ),
                        );
                      }

                      return const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.transparent,
                        backgroundImage: AssetImage(AppImages.profile),
                        //child: Image.asset(AppImages.profile, fit: BoxFit.fill),
                      );
                    },
                  ),

                SizedBox(height: 20*pw),
                //SizedBox(height: 8),
                //Text('علی باقری'),
              ],
            )
          ],
        ),
      ),
    );
  }

  void onLevelClick(){
    AppSheet.showSheetCustom(
      context,
        builder: (_){
          return SizedBox(
            height: MathHelper.percent(sh, 80),
            child: const ChangeLanguageLevelSheet(),
          );
        },
        routeName: 'ChangeLanguageLevelSheet',
      contentColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20)
          )
      )
    );
  }
}
