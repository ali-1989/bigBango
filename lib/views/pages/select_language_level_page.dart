import 'package:flutter/material.dart';

import 'package:im_animations/im_animations.dart';
import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/managers/api_manager.dart';
import 'package:app/managers/settings_manager.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/enums/enums.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/tools/app/app_broadcast.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_sheet.dart';
import 'package:app/views/components/selectLevelOnline.dart';
import 'package:app/views/components/selectSupportTime.dart';
import 'package:app/views/components/video_player.dart';

class SelectLanguageLevelPage extends StatefulWidget {

  const SelectLanguageLevelPage({
    Key? key,
  }) : super(key: key);

  @override
  State<SelectLanguageLevelPage> createState() => _SelectLanguageLevelPageState();
}
///===================================================================================================================
class _SelectLanguageLevelPageState extends StateSuper<SelectLanguageLevelPage> {
  int selectValue = 0;
  Requester requester = Requester();

  @override
  void initState(){
    super.initState();
  }

  @override
  void dispose(){
    requester.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
      builder: (ctx, ctr, data){
        return Scaffold(
          backgroundColor: Colors.white,
          body: SizedBox.expand(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  SizedBox(
                      width: double.infinity,
                      //height: sh * 0.58,
                      child: Stack(
                        fit: StackFit.passthrough,
                        children: [
                          Center(
                              child: Image.asset(AppImages.selectLevelBack, height: hs*0.3),
                          ),

                          Positioned(
                              top: ((hs*0.3)/2)-70,
                              left: -60,
                              right: 0,
                              child: GestureDetector(
                                onTap: showVideo,
                                child: Center(
                                  child: ColorSonar(
                                      contentAreaRadius: 20.0,
                                      waveFall: 10.0,
                                      waveMotionEffect: Curves.linear,
                                      waveMotion: WaveMotion.synced,
                                      innerWaveColor: AppDecoration.red.withAlpha(100),
                                      middleWaveColor: AppDecoration.red.withAlpha(50),
                                      outerWaveColor: Colors.transparent,
                                      duration: const Duration(seconds: 2),
                                      child: Image.asset(AppImages.playIcon, width: 40)
                                  ),
                                ),
                              )
                          ),
                        ],
                      )
                  ),


                  const SizedBox(height: 15),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(AppImages.selectLevelIco2),
                      const SizedBox(width: 8),
                      Text(AppMessages.selectLevelTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Text(AppMessages.selectLevelDescription, textAlign: TextAlign.center, style: const TextStyle(height: 1.4)),
                  ),

                  const SizedBox(height: 25),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 17),
                      child: ListView(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: Card(
                              color: ColorHelper.getColorFromHex('#FEEFE9'),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 13),
                                child: Row(
                                  children: [
                                    Image.asset(AppImages.atentionIco),
                                    const SizedBox(width: 12),
                                    Text(AppMessages.selectLevelTerm1, style: const TextStyle(color: AppDecoration.red),),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          GestureDetector(
                            onTap: (){
                              selectValue = 0;
                              assistCtr.updateHead();
                            },
                            child: Card(
                              color: Colors.grey.shade100,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 13),
                                child: Row(
                                  children: [
                                    Builder(
                                        builder: (ctx){
                                          if(selectValue == 0){
                                            return getSelectedBox();
                                          }

                                          return getEmptyBox();
                                        }
                                    ),
                                    const SizedBox(width: 18),
                                    const Text.rich(
                                      TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'شروع از ',
                                              style: TextStyle(color: Colors.black),
                                            ),

                                            TextSpan(
                                              text: 'سطح پایه',
                                              style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
                                            ),
                                          ]
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                            ),
                          ),

                         /* GestureDetector(
                            onTap: (){
                              selectValue = 1;
                              assistCtr.updateHead();
                            },
                            child: Card(
                              color: Colors.grey.shade100,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 13),
                                child: Row(
                                  children: [
                                    Builder(
                                        builder: (ctx){
                                          if(selectValue == 1){
                                            return getSelectedBox();
                                          }

                                          return getEmptyBox();
                                        }
                                    ),

                                    const SizedBox(width: 18),
                                    RichText(
                                      text: const TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'تعیین سطح ',
                                              style: TextStyle(color: Colors.black),
                                            ),

                                            TextSpan(
                                              text: 'آنلاین',
                                              style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
                                            ),
                                          ]
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),*/

                          GestureDetector(
                            onTap: (){
                              selectValue = 2;
                              assistCtr.updateHead();
                            },
                            child: Card(
                              color: Colors.grey.shade100,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 13),
                                child: Row(
                                  children: [
                                    Builder(
                                        builder: (ctx){
                                          if(selectValue == 2){
                                            return getSelectedBox();
                                          }

                                          return getEmptyBox();
                                        }
                                    ),

                                    const SizedBox(width: 18),
                                    const Text.rich(
                                       TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'تعیین سطح ',
                                              style: TextStyle(color: Colors.black),
                                            ),

                                            TextSpan(
                                              text: 'توسط پشتیبان',
                                              style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
                                            ),
                                          ]
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                onPressed: sendClick,
                                child: Text(AppMessages.register)
                            ),
                          ),

                          const SizedBox(height: 10),
                          SizedBox(
                              height: MathHelper.minDouble(70, hs*0.14),
                              child: Image.asset(AppImages.keyboardOpacity, width: ws*0.75)
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              )
          ),
        );
      },
    );
  }

  Widget getEmptyBox(){
    return Image.asset(AppImages.emptyBoxIco);
  }

  Widget getSelectedBox(){
    return Image.asset(AppImages.selectLevelIco);
  }

  void showVideo(){
    showDialog(
        context: context,
        builder: (ctx){
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              iconTheme: const IconThemeData(color: Colors.white),
              elevation: 0,
            ),
            backgroundColor: Colors.black,
            body: VideoPlayerView(
              videoSourceType: VideoSourceType.network,
              autoPlay: true,
              srcAddress: SettingsManager.globalSettings.advertisingVideos['determiningCourseLevel']?? '',
            ),
          );
        }
    );
  }

  void sendClick() async {
    if(selectValue == 0) {
      showLoading();
      final res = await ApiManager.requestSetLevel(SettingsManager.getCourseLevelById(1));
      await hideLoading();

      if(res){
        AppBroadcast.reBuildMaterial();
      }

      return;
    }

    if(selectValue == 1){
      AppSheet.showSheetCustom(
        context,
        routeName: 'SelectLevelOnline',
        isDismissible: true,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft:Radius.circular(20), topRight: Radius.circular(20))),
        builder: (context) {
          return SizedBox(
            height: MathHelper.percent(hs, 85),
            child: const SelectLevelOnline(),
          );
        },
      );

      /*final page = SelectLevelOnline();
      RouteTools.pushPage(context, page);*/
      return;
    }


    AppSheet.showSheetCustom(
      context,
      routeName: 'SelectSupportTime',
      isDismissible: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft:Radius.circular(20), topRight: Radius.circular(20))),
      builder: (context) {
        return SizedBox(
          height: MathHelper.percent(hs, 85),
          child: const SelectSupportTime(),
        );
      },
    );

    /*final page = SelectSupportTime();
    RouteTools.pushPage(context, page);*/
  }
}
