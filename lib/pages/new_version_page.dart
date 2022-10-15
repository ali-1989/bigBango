import 'package:app/models/abstract/stateBase.dart';
import 'package:app/models/versionModel.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appNavigator.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/api/system.dart';
import 'package:simple_html_css/simple_html_css.dart';

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
  ScrollController sc = ScrollController();
  @override
  void initState(){
    super.initState();

    html = '''
<body>
<span>\u2705</span><p><strong> اضافه شدن لایتنر</strong></p>
<span>\u2705</span><p><strong> دریافت دروس از سرور</strong></p>
    </body>
''';
  }

  Future<bool> onBack(){
    if(widget.versionModel.restricted){
      System.exitApp();
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
                          controller: sc,
                          child: SingleChildScrollView(
                            controller: sc,
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
                          onPressed: (){},
                          child: Text('بروز رسانی')
                      ),
                    ),
                  ),

                  Visibility(
                    visible: !widget.versionModel.restricted,
                      child: Center(
                        child: TextButton(
                          onPressed: (){
                            AppNavigator.pop(context);
                          },
                          child: Text('انصراف'),
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


}


class MyCustomPainter extends CustomPainter {

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.color = Colors.red;

    canvas.drawRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height), paint);

    paint.color = Colors.yellow;
    canvas.drawArc(Rect.fromLTWH(0.0, 0.0, size.width *3 /2, size.height), 0.0, 3.0, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
   return true;
  }

}