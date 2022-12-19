import 'dart:math';

import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/urlHelper.dart';
import 'package:iris_tools/api/system.dart';
import 'package:simple_html_css/simple_html_css.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/models/versionModel.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appNavigator.dart';
import 'package:app/tools/app/appThemes.dart';

/*
'''
<body>
<span>\u2705</span><p><strong> اضافه شدن درباره ما</strong></p>
<span>\u2705</span><p><strong> تکمیل دروس</strong></p>
</body>
''';
 */

class NewVersionPage extends StatefulWidget {
  final VersionModel versionModel;

  const NewVersionPage({
    Key? key,
    required this.versionModel,
  }) : super(key: key);

  @override
  State<NewVersionPage> createState() => _NewVersionPageState();
}
///================================================================================================
class _NewVersionPageState extends StateBase<NewVersionPage> {
  String html = '';

  @override
  void initState(){
    super.initState();

    html = widget.versionModel.description?? '--';
  }

  Future<bool> onBack(){
    if(widget.versionModel.restricted){
      System.exitApp();
    }
    else {
      return Future.value(true);
    }

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => onBack(),
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              bottom: 0,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: sh * .24,
                  child: CustomPaint(
                    painter: MyCustomPainter(),
                    child: SizedBox(),
                  ),
                )
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30),

                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: AspectRatio(
                      aspectRatio: 10/7,
                        child: Image.asset(AppImages.newVersion)
                    ),
                  ),

                  SizedBox(height: sh *.04),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset(AppImages.newVersionIco, width: 26,),
                          SizedBox(width: 10),
                          Text('تغییرات نسخه جدید', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900))
                        ],
                      ),

                      Text('v ${widget.versionModel.newVersionName}', style: TextStyle(fontSize: 14))
                    ],
                  ),

                  SizedBox(height: 30),

                  Expanded(
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Scrollbar(
                          thumbVisibility: true,
                          trackVisibility: false,
                          child: SingleChildScrollView(
                            child: HTML.toRichText(context, html, defaultTextStyle: AppThemes.body2TextStyle()),
                          ),
                        ),
                      ),
                  ),

                  SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: onUpdateClick,
                          child: Text('بروز رسانی')
                      ),
                    ),
                  ),

                  Visibility(
                    visible: widget.versionModel.directLink != null,
                      child: Center(
                        child: TextButton(
                          onPressed: onDirectLinkClick,
                          child: Text('لینک مستقیم'),
                        ),
                      )
                  ),

                  Visibility(
                    visible: !widget.versionModel.restricted,
                      child: Center(
                        child: TextButton(
                          onPressed: (){
                            AppNavigator.pop(context);
                          },
                          child: Text('بعدا'),
                        ),
                      )
                  ),

                  SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onDirectLinkClick(){
    UrlHelper.launchLink(widget.versionModel.directLink!);

    /*if(widget.versionModel.restricted){
      System.exitApp();
    }
    else {
      AppNavigator.pop(context);
    }*/
  }

  void onUpdateClick(){
    UrlHelper.launchLink(widget.versionModel.storeLink?? '');
  }
}
///===============================================================================================
class MyCustomPainter extends CustomPainter {

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.color = AppColors.red;

    canvas.drawRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height), paint);

    paint.color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(size.width/2, -2, size.width, size.height+2), paint);

    paint.color = Colors.white;
    canvas.drawArc(Rect.fromLTWH(0.0, -size.height-2, size.width, size.height*2 +2), 0.5 * pi, 0.5 * pi, true, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
   return true;
  }

}
