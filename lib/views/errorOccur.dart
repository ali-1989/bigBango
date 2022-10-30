import 'package:app/tools/app/appImages.dart';
import 'package:app/views/customCard.dart';
import 'package:flutter/material.dart';


class ErrorOccur extends StatelessWidget {
  final TextStyle? textStyle;
  final VoidCallback? onRefresh;
  final bool fullScreen;

  const ErrorOccur({
    this.textStyle,
    this.fullScreen  = true,
    this.onRefresh,
    Key? key,
    }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ColoredBox(
        color: Colors.grey.shade200,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            //Image.asset(AppImages.errorTry, ),
            AspectRatio(
                aspectRatio: fullScreen? 1: 2/1,
              child: Image.asset(AppImages.errorTry),
            ),

            const SizedBox(height: 20),
            CustomCard(
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
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
