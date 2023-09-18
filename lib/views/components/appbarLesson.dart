import 'package:flutter/material.dart';

import 'package:iris_tools/widgets/custom_card.dart';

import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_navigator.dart';

class AppbarLesson extends StatelessWidget {
  final String title;

  const AppbarLesson({
    required this.title,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      child: ColoredBox(
        color: AppDecoration.red,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 1.5),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
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
                        const SizedBox(width: 10),
                        Text(title).bold().fsR(3),
                      ],
                    ),

                    GestureDetector(
                      onTap: (){
                        AppNavigator.pop(context);
                      },
                      child: Row(
                        children: [
                          Text(AppMessages.back),
                          const SizedBox(width: 10),
                          CustomCard(
                              color: Colors.grey.shade200,
                              padding: const EdgeInsets.all(6),
                              child: Image.asset(AppImages.arrowLeftIco, width: 13, height: 13)
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
