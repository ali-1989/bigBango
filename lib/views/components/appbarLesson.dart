import 'package:flutter/material.dart';

import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appNavigator.dart';
import 'package:app/views/widgets/customCard.dart';

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
        color: AppColors.red,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 1.5),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            child: ColoredBox(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(5),
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
                              padding: EdgeInsets.all(4),
                              child: Image.asset(AppImages.arrowLeftIco, width: 12, height: 12)
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
