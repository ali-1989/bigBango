import 'package:app/models/abstract/stateBase.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/views/changeLevel.dart';
import 'package:app/views/drawerMenuBuilder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class AppBarCustom2 extends AppBar {

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
}
///=========================================================================================================================
class AppBarCustom extends StatefulWidget implements PreferredSizeWidget {

  const AppBarCustom({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AppBarCustomState();
  }

  @override
  Size get preferredSize {
    return const Size.fromHeight(kToolbarHeight + 40);
  }
}
///=========================================================================================================================
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
                  padding: const EdgeInsets.fromLTRB(0, 22, 15, 0),
                  child: GestureDetector(
                    onTap: () async {
                      DrawerMenuBuilder.toggleDrawer(context);
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
                    padding: const EdgeInsets.fromLTRB(10, 16, 0, 0),
                    child: Row(
                      children: [
                        Icon(AppIcons.arrowDropDown),

                        TextButton(
                          onPressed: onLevelClick,
                          style: TextButton.styleFrom(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero
                          ),
                          child: const Text('سطح مبتدی'),
                        ),
                        const SizedBox(width: 5),
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
              children: const [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.transparent,
                  backgroundImage: AssetImage(AppImages.profile),
                  //child: Image.asset(AppImages.profile, fit: BoxFit.fill),
                ),
                SizedBox(height: 20),
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
    showMaterialModalBottomSheet(
      context: context,
      isDismissible: true,
      bounce: true,
      expand: false,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft:Radius.circular(20),
              topRight: Radius.circular(20))
      ),
      builder: (context) {
        return SizedBox(
          height: MathHelper.percent(sh, 85),
          //child: const SelectSupportTime(),
          child: const ChangeLevel(),
        );
      },
    );
  }
}