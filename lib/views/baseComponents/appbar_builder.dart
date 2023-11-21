import 'package:flutter/material.dart';

import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/widgets/iris_image_view.dart';

import 'package:app/managers/settings_manager.dart';
import 'package:app/services/session_service.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/enums/app_events.dart';
import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_sheet.dart';
import 'package:app/tools/app/app_sizes.dart';
import 'package:app/views/baseComponents/layoutComponent.dart';
import 'package:app/views/sheets/changeLanguageLevelSheet.dart';

class AppBarCustom extends StatefulWidget implements PreferredSizeWidget {

  // ignore: use_super_parameters
  const AppBarCustom({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AppBarCustomState();
  }

  @override
  Size get preferredSize {
    //return Size.fromHeight(kToolbarHeight + 15 * AppSizes.instance.heightRelative);
    return Size.fromHeight(55 * AppSizes.instance.heightRelative);
  }
}
//------------------------------------------------------------------------------
class AppBarCustomState extends StateSuper<AppBarCustom> {

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
                  padding: EdgeInsets.fromLTRB(0, 14 *wRel, 15, 0),
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
                    padding: EdgeInsets.fromLTRB(10, 8*hRel, 0, 0),
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

                        Image.asset(AppImages.levelBadgeIco, scale: 2),
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
                          radius: 15 * wRel,
                          backgroundColor: Colors.transparent,
                          child: IrisImageView(
                            height: 30 * wRel,
                            width: 30 * wRel,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            beforeLoadWidget: const CircularProgressIndicator(),
                            bytes: user.avatarModel?.bytes,
                            url: user.avatarModel?.fileLocation,
                            onDownloadFn: (bytes, path){
                              user.avatarModel?.bytes = bytes;
                            },
                          ),
                        );
                      }

                      return CircleAvatar(
                        radius: 15 * hRel,
                        backgroundColor: Colors.transparent,
                        backgroundImage: AssetImage(AppImages.profile),
                        //child: Image.asset(AppImages.profile, fit: BoxFit.fill),
                      );
                    },
                  ),

                SizedBox(height: 8 * hRel),
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
            height: MathHelper.percent(hs, 80),
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
