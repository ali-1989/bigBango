import 'package:app/structures/models/lessonModels/storeModel.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/currencyTools.dart';
import 'package:app/views/widgets/customCard.dart';
import 'package:flutter/material.dart';
import 'package:app/system/extensions.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';

class InvoiceSheet extends StatelessWidget {
  final List<StoreLessonModel> lessons;

  const InvoiceSheet({
    Key? key,
    required this.lessons,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          children: [
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('فاکتور خرید').bold().fsR(3),

                GestureDetector(
                  onTap: (){
                    AppRoute.popTopView(context);
                  },
                  child: CustomCard(
                      color: Colors.grey.shade200,
                      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 6),
                      radius: 4,
                      child: Icon(AppIcons.close, size: 10)
                  ),
                ),
              ],
            ),

            SizedBox(height: 30),

            SizedBox(
              height: calcListHeight(),
              child: ListView.builder(
                shrinkWrap: true,
                  itemCount: lessons.length,
                  itemBuilder: itemBuilder
              ),
            ),

            SizedBox(height: 10),
            Divider(color: Colors.black38),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('جمع کل'),
                Text('${CurrencyTools.formatCurrency(calcPrice())} تومان'),
              ],
            ),


            SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                    onPressed: (){
                      AppRoute.popTopView(context, data: true);
                    },
                    child: Text('پرداخت')
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int calcPrice(){
    int all = 0;

    for(final x in lessons){
      all += x.amount;
    }

    return all;
  }

  double calcListHeight(){
    double all = 70;

    if(lessons.length > 2){
      all += (lessons.length -2) * 34;
    }

    return MathHelper.minDouble(all, 300);
  }

  Widget itemBuilder(BuildContext context, int index) {
    final itm = lessons[index];

    return CustomCard(
      color: index % 2 == 0 ? Colors.grey.shade200 : Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(itm.title),

            Row(
              children: [
                Text(CurrencyTools.formatCurrency(itm.amount)),
                Text('   تومان').alpha(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
