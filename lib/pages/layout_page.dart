import 'package:app/models/abstract/stateBase.dart';
import 'package:app/pages/home_page.dart';
import 'package:app/pages/lightner_page.dart';
import 'package:app/views/homeComponents/appBarBuilder.dart';
import 'package:app/views/homeComponents/bottomNavBar.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

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
        return SafeArea(
          top: true,
          child: Scaffold(
            appBar: const AppBarCustom(),
            extendBodyBehindAppBar: true,
            bottomNavigationBar: BottomNavBar(
                selectedItemIndex: selectedPageIndex,
                onSelectItem: onPageItemSelect,
            ),
            body: PageView(
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                HomePage(),
                LightnerPage(),
                HomePage(),
                HomePage(),
              ],
            ),
          ),
        );
      }
    );
  }

  void onPageItemSelect(int idx){
    selectedPageIndex = idx;
    pageController.jumpToPage(idx);
    assistCtr.updateMain();
  }
}
