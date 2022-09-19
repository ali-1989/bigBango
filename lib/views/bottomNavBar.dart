import 'package:app/tools/app/appImages.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  final int selectedItemIndex;
  final void Function(int idx) onSelectItem;

  const BottomNavBar({
    required this.selectedItemIndex,
    required this.onSelectItem,
    Key? key,
  }) : super(key: key);

  @override
  State createState() => BottomNavBarState();
}
///================================================================================================
class BottomNavBarState extends State<BottomNavBar> {
  Color selectedColor = Colors.red;
  Color unSelectedColor = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 2,
          width: double.infinity,
          child: ColoredBox(
            color: Colors.grey.withAlpha(30),
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
                child: buildItem('صفحه اصلی',
                  _isSel(0)? Image.asset(AppImages.homeIcoRed, width: 40) : Image.asset(AppImages.homeIcoBlack, width: 40),
                    0
                )
            ),

            buildSeparator(),
            Flexible(
                child: buildItem('لایتنر',
                    _isSel(1)? Image.asset(AppImages.lightnerIcoRed, width: 40) : Image.asset(AppImages.lightnerIcoBlack, width: 40),
                    1
                )
            ),

            buildSeparator(),
            Flexible(
                child: buildItem('پروفایل',
                    _isSel(2)? Image.asset(AppImages.userIcoBlack, width: 40, color: Colors.red) : Image.asset(AppImages.userIcoBlack, width: 40),
                    2
                )
            ),

            buildSeparator(),
            Flexible(
                child: buildItem('اعلانات',
                    _isSel(3)? Image.asset(AppImages.notificationIcoBlack, width: 40, color: Colors.red) : Image.asset(AppImages.notificationIcoBlack, width: 40),
                    3
                )
            ),
          ],
        ),
      ],
    );
  }

  bool _isSel(int idx){
    return widget.selectedItemIndex == idx;
  }

  Widget buildSeparator(){
    return const SizedBox(
      width: 1,
      height: 25,
      child: ColoredBox(
        color: Colors.grey,
      ),
    );
  }

  Widget buildItem(String text, Widget icon, int idx){
    return GestureDetector(
      onTap: (){
        widget.onSelectItem.call(idx);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          Text(text),

          const SizedBox(height: 5),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 3,
                width: 100,
                child: ColoredBox(
                  color: _isSel(idx)? selectedColor: unSelectedColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
///================================================================================================