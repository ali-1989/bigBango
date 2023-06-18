import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/pages/home_page.dart';
import 'package:app/pages/leitner_page.dart';
import 'package:app/pages/message_page.dart';
import 'package:app/pages/store_page.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/views/baseComponents/appBarBuilder.dart';
import 'package:app/views/baseComponents/bottomNavBarBuilder.dart';
import 'package:app/views/baseComponents/drawerMenuBuilder.dart';
import 'package:app/views/baseComponents/layoutComponent.dart';

class LayoutPage extends StatefulWidget {
  const LayoutPage({Key? key}) : super(key: key);

  @override
  State<LayoutPage> createState() => LayoutPageState();
}
///===================================================================================================================
class LayoutPageState extends StateBase<LayoutPage> {
  int selectedPageIndex = 0;
  PageController pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
      builder: (ctx, ctr, data) {
        return LayoutComponent(
          drawer: DrawerMenuBuilder.buildDrawer(),
          body: SafeArea(
            child: Scaffold(
              appBar: AppBarCustom(),
              extendBodyBehindAppBar: true,
              bottomNavigationBar: BottomNavBar(
                  selectedItemIndex: selectedPageIndex,
                  onSelectItem: onPageItemSelect,
              ),
              body: PageView(
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  HomePage(key: AppBroadcast.homePageKey),
                  LightnerPage(),
                  StorePage(),
                  NotificationPage(),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  void onPageItemSelect(int idx){
    selectedPageIndex = idx;
    pageController.jumpToPage(idx);
    assistCtr.updateHead();
  }

  void gotoPage(int idx){
    onPageItemSelect(idx);
  }
}
