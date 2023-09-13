import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/widgets/customCard.dart';

import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/route_tools.dart';

class WalletWithdrawalSheet extends StatefulWidget {
  final int maxAmount;

  WalletWithdrawalSheet({
    Key? key,
   required this.maxAmount,
  }) : super(key: key);

  @override
  State<WalletWithdrawalSheet> createState() => _WalletWithdrawalSheetState();
}
///============================================================================================================================
class _WalletWithdrawalSheetState extends State<WalletWithdrawalSheet> {
  final TextEditingController txtCtr = TextEditingController();

  @override
  void dispose(){
    txtCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(AppImages.withdrawalIco, height: 18),
                SizedBox(width: 8),
                Text('بازگشت اعتبار').bold().fsR(2),
              ],
            ),
            SizedBox(height: 20),
            Text('شما می توانید در صورت تمایل مبلغ قابل برداشت کیف پول خود را دریافت کنید', style: TextStyle(height: 1.4)).fsR(1),
            SizedBox(height: 20),
            Text('مبلغ قابل برداشت: ${widget.maxAmount}').fsR(-1).alpha(),

            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      maxLines: 1,
                      controller: txtCtr,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(),
                        disabledBorder: OutlineInputBorder(),
                        suffixText: 'تومان',
                        isDense: true,
                        contentPadding: EdgeInsets.all(12)
                      ),
                    ),
                ),
              ],
            ),

            SizedBox(height: 10),
            Text('پس از بررسی مبلغ مورد نظر به شماره شبای زیر واریز می شود').alpha(),
            CustomCard(
              color: Colors.grey.shade200,
                padding: EdgeInsets.all(5),
                child: Text('1255565544654654646464').alpha()
            ),
            SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: (){
                      RouteTools.popTopView(context: context, data: MathHelper.clearToInt(txtCtr.text.trim()));
                    },
                    child: Text('تایید'),
                  ),
                ),

                SizedBox(width: 15),

                SizedBox(
                  width: 100,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red),
                      foregroundColor: Colors.red,
                    ),
                    onPressed: (){
                      RouteTools.popTopView(context: context);
                    },
                    child: Text('لغو'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
