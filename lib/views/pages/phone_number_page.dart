import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:android_sms_retriever/android_sms_retriever.dart';
import 'package:animate_do/animate_do.dart';
import 'package:im_animations/im_animations.dart';
import 'package:iris_tools/api/checker.dart';
import 'package:iris_tools/api/helpers/inputFormatter.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/attribute.dart';

import 'package:app/managers/settings_manager.dart';
import 'package:app/services/login_service.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/enums/enums.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/appDecoration.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appSnack.dart';
import 'package:app/tools/routeTools.dart';
import 'package:app/views/components/videoPlayer.dart';
import 'package:app/views/pages/otp_page.dart';

class PhoneNumberPage extends StatefulWidget {
  PhoneNumberPage({Key? key}) : super(key: key);

  @override
  State<PhoneNumberPage> createState() => _PhoneNumberPageState();
}
///===================================================================================================================
class _PhoneNumberPageState extends StateBase<PhoneNumberPage> {
  TextEditingController phoneCtr = TextEditingController();
  AttributeController atrCtr = AttributeController();
  double regulator = 12;

  @override
  void initState(){
    super.initState();

    addPostOrCall(fn: () {
      if(atrCtr.getHeight()! < sh){
        regulator = sh - atrCtr.getHeight()!;
        assistCtr.updateHead();
      }
    });
  }

  @override
  void dispose(){
    phoneCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
      builder: (_, ctr, data) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Attribute(
              controller: atrCtr,
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  /// background
                  SizedBox(
                      width: double.infinity,
                      height: sh * 0.53,
                      child: Stack(
                        fit: StackFit.passthrough,
                        children: [
                          Center(
                              child: AspectRatio(
                                aspectRatio: 3/3.4,
                                  child: Image.asset(AppImages.register, width: sw*0.8, height: sh*0.5, fit: BoxFit.fill))
                          ),

                          /// play icon
                          Positioned(
                            top: sh* 0.18,
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
                                      innerWaveColor: AppDecoration.red.withAlpha(100),
                                      middleWaveColor: AppDecoration.red.withAlpha(50),
                                      outerWaveColor: Colors.transparent,
                                      duration: const Duration(seconds: 2),
                                      child: Image.asset(AppImages.playIcon, width: 40)
                                  ),
                                ),
                              )
                          ),

                          /// why bigbango text
                          Positioned(
                              top: sh *.27,
                              left: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: showVideo,
                                child: Center(
                                  child: Pulse(
                                    delay: const Duration(seconds: 2),
                                    child: Text(AppMessages.loginDescription3).bold()
                                        /*.wrapBoxBorder(
                                        alpha: 100,
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5)
                                    ),*/
                                  ),
                                ),
                              )
                          ),
                        ],
                      )
                  ),

                  SizedBox(height: regulator),

                  /// input-button
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

                        const SizedBox(height: 10),

                        TextField(
                          controller: phoneCtr,
                          keyboardType: TextInputType.phone,
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            InputFormatter.filterInputFormatterDeny(RegExp(r'(\+)|(-)')),
                          ],
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(width: 0.7)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(width: 0.7)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(width: 0.7)),
                            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(width: 0.7)),
                          ),
                        ),

                        const SizedBox(height: 14),

                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                              onPressed: onContinueClick,
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
          ),
        );
      }
    );
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
              srcAddress: SettingsManager.globalSettings.advertisingVideos['login']?? '',
            ),
          );
        }
    );
  }

  void onContinueClick(){
    final phoneNumber = phoneCtr.text.trim();

    if(phoneNumber.isEmpty || phoneNumber.length < 11){
      AppSnack.showError(context, AppMessages.mustEnterMobileNumber);
      return;
    }

    if(!Checker.validateMobile(phoneNumber)){
      AppSnack.showError(context, AppMessages.mustEnterMobileNumber);
      return;
    }

    requestSendOtp(phoneNumber);
  }

  void requestSendOtp(String phoneNumber) async {
    showLoading();

    var sign = '';

    if(!kIsWeb) {
      sign = (await AndroidSmsRetriever.getAppSignature()) ?? '';
    }

    final httpRequester = await LoginService.requestSendOtp(phoneNumber: phoneNumber, sign: sign);
    await hideLoading();

    if(httpRequester == null){
      AppSnack.showSnack$errorCommunicatingServer(context);
      return;
    }

    int statusCode = httpRequester.responseData?.statusCode?? 0;

    if(statusCode != 200){
      String? message;

      if(httpRequester.getBodyAsJson() != null) {
        message = httpRequester.getBodyAsJson()![Keys.message];
      }

      if(message == null) {
        AppSnack.showSnack$serverNotRespondProperly(context);
      }
      else {
        AppSnack.showError(context, message);
      }

      return;
    }

    RouteTools.pushPage(context, OtpPage(phoneNumber: phoneNumber, sign: sign));
  }
}
