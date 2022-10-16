import 'package:app/models/abstract/stateBase.dart';
import 'package:app/models/lightnerModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appNavigator.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/views/customCard.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';


class LightnerDetailPage extends StatefulWidget {
  final LightnerModel lightnerModel;
  final int index;

  const LightnerDetailPage({
    required this.lightnerModel,
    required this.index,
    Key? key
  }) : super(key: key);

  @override
  State<LightnerDetailPage> createState() => _LightnerDetailPageState();
}
///======================================================================================================================
class _LightnerDetailPageState extends StateBase<LightnerDetailPage> {
  bool showTranslate = false;

  @override
  void initState(){
    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
        builder: (ctx, ctr, data){
          return Scaffold(
            //appBar: buildAppbar(),
            body: SafeArea(
                child: buildBody()
            ),
          );
        }
    );
  }

  Widget buildBody(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),

            ClipRRect(
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
                                Image.asset(AppImages.lightnerIcoRed),
                                SizedBox(width: 10),
                                Text('جعبه لایتنر').bold().fsR(3)
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
            ),


            SizedBox(height: 14),
            /// 7/20
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('جعبه ی ${widget.lightnerModel.getNumText(widget.index)}').color(Colors.black45)
                  ],
                ),

                Row(
                  children: [
                    Text('20').englishFont().fsR(4),

                    SizedBox(width: 10),

                    Text('/').englishFont().fsR(5),

                    SizedBox(width: 10),

                    CustomCard(
                      color: Colors.grey.shade200,
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: Text('7').englishFont().bold().fsR(4)
                    )
                  ],
                ),
              ],
            ),

            SizedBox(height: 14),
            /// progressbar
            Directionality(
                textDirection: TextDirection.ltr,
                child: LinearProgressIndicator(value: 0.3, backgroundColor: Colors.red.shade50)
            ),

            SizedBox(height: 14),

            DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black45, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    children: [
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:[
                          CustomCard(
                            padding: EdgeInsets.all(5),
                              color: Colors.red,
                              child: Image.asset(AppImages.lightnerIcoBlack, width: 20, color: Colors.white)
                          ),

                          SizedBox(width: 8),
                          CustomCard(
                            padding: EdgeInsets.all(5),
                              color: Colors.grey.shade200,
                              child: Image.asset(AppImages.speaker2Ico, width: 20,)
                          ),

                          SizedBox(width: 8),
                          RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(text: '[ ', style: AppThemes.body2TextStyle()),
                                  TextSpan(text: 'thangk', style: AppThemes.body2TextStyle()),
                                  TextSpan(text: ' ]', style: AppThemes.body2TextStyle()),
                                ]
                              )
                          ),
                        ]
                      ),

                      SizedBox(height: 10),
                      Divider(color: Colors.black45,),
                      SizedBox(height: 50),

                      Text('thank').fsR(10),

                      AnimatedCrossFade(
                          firstChild: TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: (){
                                showTranslate = !showTranslate;
                                assistCtr.updateMain();
                              },
                              child: Text('نمایش معنی')
                          ),
                          secondChild: Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Text('تشکر / سپاس'),
                          ),
                          crossFadeState: showTranslate? CrossFadeState.showSecond : CrossFadeState.showFirst,
                          duration: Duration(milliseconds: 250)
                      ),

                      SizedBox(height: 50),
                      Row(
                        children: [
                          Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green
                                ),
                                onPressed: (){
                                  showTranslate = !showTranslate;
                                  assistCtr.updateMain();
                                },
                                child: Text('بلدم'),
                              )
                          ),

                          SizedBox(width: 10),
                          Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange
                                ),
                                onPressed: (){},
                                child: Text('بازم ببینم'),
                              )
                          ),

                          SizedBox(width: 10),
                          Expanded(
                              child: ElevatedButton(
                                onPressed: (){
                                  showTranslate = !showTranslate;
                                  assistCtr.updateMain();
                                },
                                child: Text('بلد نیستم'),
                              )
                          ),
                        ],
                      ),
                      SizedBox(height: 4),

                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}
