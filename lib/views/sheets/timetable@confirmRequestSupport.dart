import 'package:app/tools/app/appRoute.dart';
import 'package:flutter/material.dart';
import 'package:app/system/extensions.dart';

class TimetableConfirmRequestSupport extends StatelessWidget {
  final String? lesson;
  final String title;
  final String day;
  final String limitTime;

  const TimetableConfirmRequestSupport({
    Key? key,
    this.lesson,
    required this.title,
    required this.day,
    required this.limitTime,
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
            Text('اطلاعات درخواست شما').bold().fsR(3),

            SizedBox(height: 30),

            Visibility(
              visible: lesson != null,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('عنوان درس').bold(),
                      Text(lesson?? ''),
                    ],
                  ),

                  SizedBox(height: 10),
                  Divider(color: Colors.black38),
                  SizedBox(height: 10),
                ],
              ),
            ),


            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('موضوع').bold(),
                Text(title),
              ],
            ),

            SizedBox(height: 10),
            Divider(color: Colors.black38),
            SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('روز').bold(),
                Text(day),
              ],
            ),

            SizedBox(height: 10),
            Divider(color: Colors.black38),
            SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('بازه زمانی').bold(),
                Text(limitTime),
              ],
            ),

            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: (){
                      AppRoute.popTopView(context, data: true);
                    },
                    child: Text('تایید')
                ),

                SizedBox(width: 30),

                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red)
                  ),
                    onPressed: (){
                      AppRoute.popTopView(context);
                    },
                    child: Text('برگشت')
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
