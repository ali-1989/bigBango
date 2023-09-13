import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/widgets/customCard.dart';

import 'package:app/structures/models/lessonModels/storeModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/currency_tools.dart';
import 'package:app/tools/route_tools.dart';

class InvoiceSheet extends StatelessWidget {
  final List<StoreLessonModel> lessons;

  const InvoiceSheet({
    Key? key,
    required this.lessons,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('فاکتور خرید').bold().fsR(3),

                GestureDetector(
                  onTap: (){
                    RouteTools.popTopView(context: context);
                  },
                  child: CustomCard(
                      color: Colors.grey.shade200,
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
                      radius: 4,
                      child: const Icon(AppIcons.close, size: 10)
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            SizedBox(
              height: calcListHeight(),
              child: ListView.builder(
                shrinkWrap: true,
                  itemCount: lessons.length,
                  itemBuilder: itemBuilder
              ),
            ),

            const SizedBox(height: 10),
            const Divider(color: Colors.black38),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('جمع کل'),
                Text('${CurrencyTools.formatCurrency(calcPrice())} تومان'),
              ],
            ),


            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                    onPressed: (){
                      RouteTools.popTopView(context: context, data: true);
                    },
                    child: const Text('پرداخت')
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
                const Text('   تومان').alpha(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
