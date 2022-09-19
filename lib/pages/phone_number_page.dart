import 'package:animate_do/animate_do.dart';
import 'package:app/models/abstract/stateBase.dart';
import 'package:app/pages/otp_page.dart';
import 'package:app/system/enums.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/views/video_player.dart';
import 'package:flutter/material.dart';
import 'package:im_animations/im_animations.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';

class PhoneNumberPage extends StatefulWidget {
  const PhoneNumberPage({Key? key}) : super(key: key);

  @override
  State<PhoneNumberPage> createState() => _PhoneNumberPageState();
}
///===================================================================================================================
class _PhoneNumberPageState extends StateBase<PhoneNumberPage> {


  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: ListView(
          children: [
            const SizedBox(height: 10),

            SizedBox(
                width: double.infinity,
                height: sh*0.58,
                child: Stack(
                  fit: StackFit.passthrough,
                  children: [
                    Center(child: Image.asset(AppImages.register, width: sw*0.88, height: sh*0.58, fit: BoxFit.fill)),

                    Positioned(
                      top: 122,
                        left: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: showVideo,
                          child: Center(
                            child: ColorSonar(
                                contentAreaRadius: 20.0,
                                waveFall: 10.0,
                                waveMotionEffect: Curves.linear,
                                waveMotion: WaveMotion.synced,
                                innerWaveColor: Colors.red.withAlpha(100),
                                middleWaveColor: Colors.red.withAlpha(50),
                                outerWaveColor: Colors.transparent,
                                duration: const Duration(seconds: 2),
                                child: Image.asset(AppImages.playIcon, width: 40)
                            ),
                          ),
                        )
                    ),

                    Positioned(
                        top: 182,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Pulse(
                            delay: const Duration(seconds: 2),
                            child: Text(AppMessages.loginDescription3)
                                .wrapBoxBorder(
                                alpha: 100,
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5)
                            ),
                          ),
                        )
                    ),
                  ],
                )
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(AppImages.registerIco2),
                      const SizedBox(width: 8),
                      Text(AppMessages.loginDescription, style: const TextStyle(fontSize: 18)),
                    ],
                  ),

                  const SizedBox(height: 10),
                  Text(AppMessages.loginDescription2),

                  const SizedBox(height: 20),

                  TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: onGoClick,
                        child: Text(AppMessages.checkAndContinue)
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
                height: MathHelper.minDouble(70, sh*0.14),
                child: Image.asset(AppImages.keyboardOpacity, width: sw*0.75)
            ),

            const SizedBox(height: 7),
          ],
        ),
      ),
    );
  }

  void onGoClick(){
    AppRoute.push(context, const OtpPage(phoneNumber: '09336044375',));
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
              srcAddress: 'http://techslides.com/demos/sample-videos/small.mp4',
            ),
          );
        }
    );
  }
}
