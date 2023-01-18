import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/currencyTools.dart';
import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';

class IncreaseAmountSheet extends StatefulWidget {
  final int? amount;

  const IncreaseAmountSheet({
    Key? key,
    this.amount,
  }) : super(key: key);

  @override
  State<IncreaseAmountSheet> createState() => _IncreaseAmountSheetState();
}
///============================================================================================
class _IncreaseAmountSheetState extends StateBase<IncreaseAmountSheet> {
  late ButtonStyle style;
  int amount = 10000;
  int selectedKeyIndex = 1;

  @override
  void initState(){
    super.initState();

    if(widget.amount != null){
      amount = widget.amount!;
    }

    style = ElevatedButton.styleFrom(
      visualDensity: VisualDensity(vertical: -2, horizontal: -4),
    );
  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(AppIcons.addCircle, color: Colors.red, size: 17),
                SizedBox(width: 5),
                Text('افزایش اعتبار'),
              ],
            ),

            SizedBox(height: 15),

            Image.asset(AppImages.examManMen, height: 150,),

            SizedBox(height: 10),
            Text('میزان اعتبار خود را وارد کنید'),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: style,
                    onPressed: clickOnOne,
                    child: Text('1,000')
                ),

                SizedBox(width: 4,),
                ElevatedButton(
                    style: style,
                    onPressed: clickOnFive,
                    child: Text('5,000')
                ),

                SizedBox(width: 4,),
                ElevatedButton(
                    style: style,
                    onPressed: clickOnTwenty,
                    child: Text('20,000')
                ),

                SizedBox(width: 4,),
                ElevatedButton(
                    style: style,
                    onPressed: clickOnFifty,
                    child: Text('50,000')
                ),
              ],
            ),

            Directionality(
              textDirection: TextDirection.ltr,
              child: SizedBox(
                height: 25,
                child: ToggleSwitch(
                  initialLabelIndex: selectedKeyIndex,
                  totalSwitches: 2,
                  customIcons: [Icon(Icons.remove, color: Colors.white,), Icon(Icons.add, color: Colors.white)],
                  labels: ['', ''],
                  onToggle: (index) {
                    selectedKeyIndex = index?? 0;
                  },
                ),
              ),
            ),

            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black38)
                  ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: SizedBox()),
                      Expanded(child: Center(child: Text(CurrencyTools.formatCurrency(amount)).bold())),
                      Expanded(child: Align(alignment: Alignment.centerLeft, child: Text('تومان').fsR(-1))),
                    ],
                  ),
                ),
              ),
            ),


            /// button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  visualDensity: VisualDensity(vertical: -2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                  onPressed: onPayClick,
                  child: Text('پرداخت')
              ),
            ),
          ],
        ),
      ),
    );
  }

  void clickOnOne(){
    if(selectedKeyIndex == 0){
      if(amount < 1000){
        return;
      }

      amount -= 1000;
    }
    else {
      amount += 1000;
    }

    callState();
  }

  void clickOnFive(){
    if(selectedKeyIndex == 0){
      if(amount < 5000){
        return;
      }

      amount -= 5000;
    }
    else {
      amount += 5000;
    }

    callState();
  }

  void clickOnTwenty(){
    if(selectedKeyIndex == 0){
      if(amount < 20000){
        return;
      }

      amount -= 20000;
    }
    else {
      amount += 20000;
    }

    callState();
  }

  void clickOnFifty(){
    if(selectedKeyIndex == 0){
      if(amount < 50000){
        return;
      }

      amount -= 50000;
    }
    else {
      amount += 50000;
    }

    callState();
  }

  void onPayClick(){
    AppRoute.popTopView(context, data: amount);
  }
}
