import 'package:flutter/material.dart';

import 'package:app/tools/app/appImages.dart';
import 'package:app/views/widgets/customCard.dart';

class ErrorOccur extends StatelessWidget {
  final TextStyle? textStyle;
  final VoidCallback? onRefresh;
  final Color? backgroundColor;
  final bool showBackButton;

  ErrorOccur({
    this.textStyle,
    this.backgroundColor,
    this.onRefresh,
    this.showBackButton = true,
    Key? key,
    }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor?? Colors.grey.shade200,
      child: SafeArea(
        child: Column(
          children: [
            Visibility(
              visible: showBackButton,
              child: Align(
                  alignment: Alignment.topRight,
                  child: BackButton()
              ),
            ),
            Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      Flexible(
                          flex: 2,
                          child: AspectRatio(
                              aspectRatio: 3/5,
                              child: Image.asset(AppImages.errorTry)
                          )
                      ),


                      Flexible(
                        child: Center(
                          child: CustomCard(
                            color: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(AppImages.closeIco),
                                const SizedBox(width: 10),
                                Text('خطایی رخ داد، دوباره تلاش کنید',
                                  style: textStyle?? const TextStyle(fontWeight: FontWeight.bold),
                                ),

                                Visibility(
                                    visible: onRefresh != null,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const SizedBox(width: 10),
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          iconSize: 23,
                                          constraints: BoxConstraints.tightFor(),
                                          onPressed: (){
                                            onRefresh?.call();
                                          },
                                          icon: Icon(Icons.refresh, color: Colors.blue),
                                        )
                                      ],
                                    )
                                )
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                    ],
                  ),
                )
            ),
          ],
        ),
      ),
    );
  }
}
