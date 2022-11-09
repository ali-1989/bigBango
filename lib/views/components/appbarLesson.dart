import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appNavigator.dart';
import 'package:app/system/extensions.dart';
import 'package:app/views/widgets/customCard.dart';
import 'package:flutter/material.dart';

class AppbarLesson extends StatelessWidget {
  final String title;

  const AppbarLesson({
    required this.title,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      child: ColoredBox(
        color: Colors.red,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 1.5),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            child: ColoredBox(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(AppImages.lessonListIco),
                        SizedBox(width: 10),
                        Text(title).bold().fsR(3)
                      ],
                    ),

                    GestureDetector(
                      onTap: (){
                        AppNavigator.pop(context);
                      },
                      child: Row(
                        children: [
                          Text(AppMessages.back),
                          SizedBox(width: 10),
                          CustomCard(
                              color: Colors.grey.shade200,
                              padding: EdgeInsets.all(5),
                              child: Image.asset(AppImages.arrowLeftIco)
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}