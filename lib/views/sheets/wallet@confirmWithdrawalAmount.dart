import 'package:app/tools/app/appRoute.dart';
import 'package:flutter/material.dart';
import 'package:app/system/extensions.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';

class WalletConfirmWithdrawalAmount extends StatelessWidget {
  final TextEditingController txtCtr = TextEditingController();

  WalletConfirmWithdrawalAmount({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          children: [
            SizedBox(height: 20),
            Text('شما می توانید در صورت تمایل مبلغ قابل برداشت کیف پول خود را دریافت کنید', textAlign: TextAlign.center,).fsR(1),
            SizedBox(height: 20),
            Text('برای این منظور مبلغ مورد نظر خود را وارد کنید'),

            SizedBox(height: 20),
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
                      ),
                    ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: (){
                      AppRoute.popTopView(context, data: MathHelper.clearToInt(txtCtr.text.trim()));
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
                      AppRoute.popTopView(context);
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
