import 'package:flutter/material.dart';

import 'package:android_sms_retriever/android_sms_retriever.dart';
import 'package:iris_tools/api/helpers/localeHelper.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:pinput/pinput.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

import 'package:app/managers/font_manager.dart';
import 'package:app/services/login_service.dart';
import 'package:app/services/session_service.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_broadcast.dart';
import 'package:app/tools/app/app_db.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_snack.dart';
import 'package:app/tools/route_tools.dart';

class OtpPage extends StatefulWidget {
  final String phoneNumber;
  final String sign;

  const OtpPage({
    required this.phoneNumber,
    required this.sign,
    Key? key,
  }) : super(key: key);

  @override
  State<OtpPage> createState() => _OtpPageState();
}
///===================================================================================================================
class _OtpPageState extends StateSuper<OtpPage> {
  late final StopWatchTimer stopWatchTimer;
  TextEditingController pinTextCtr = TextEditingController();
  bool showResendOtpButton = false;
  String otpCode = '';

  @override
  void initState(){
    super.initState();

    stopWatchTimer = StopWatchTimer(
      mode: StopWatchMode.countDown,
      isLapHours: false,
      presetMillisecond: StopWatchTimer.getMilliSecFromMinute(1),
      onEnded: (){
        showResendOtpButton = true;
        callState();
      },
    );

    addPostOrCall(fn: () {
      stopWatchTimer.onStartTimer();
      //stopWatchTimer.onExecute.add(StopWatchExecute.start);

      AndroidSmsRetriever.listenForSms().then((value) {
        final reg = RegExp(r'(\b[0-9]+\b)', multiLine: true, unicode: true);
        final mat = reg.firstMatch(value?? '');

        otpCode = LocaleHelper.numberToEnglish(mat?.group(0))?? '';
        pinTextCtr.text = otpCode;

        callState();
      });
    });
  }

  @override
  void dispose(){
    stopWatchTimer.dispose();
    pinTextCtr.dispose();
    AndroidSmsRetriever.stopSmsListener();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF0A17D), Color(0xFFFFFFFF)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
              ),
            ),

            SingleChildScrollView(
              child: Stack(
                children: [
                  //SizedBox(height: sh/2),

                  UnconstrainedBox(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                        height: sh * calc(0.8, 660, 0.7, 580, sh, symmetry: true),
                        width: sw,
                        child: Image.asset(AppImages.otp, fit: BoxFit.fill)
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 280),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(AppImages.registerIco2),
                                  const SizedBox(width: 8),
                                  Text(AppMessages.otpDescription, style: const TextStyle(fontSize: 18)),
                                ],
                              ),

                              const SizedBox(height: 10),
                              RichText(
                                  text: TextSpan(
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: FontManager.instance.defaultFontFor('fa', FontUsage.normal).family
                                      ),
                                      children: [
                                        TextSpan(text: AppMessages.otpDescriptionMobile),
                                        TextSpan(text: ' ${widget.phoneNumber} ', style: const TextStyle(color: AppDecoration.red)),
                                        TextSpan(text: AppMessages.otpDescriptionMobile2),
                                      ]
                                  )
                              ),

                              const SizedBox(height: 30),

                              Directionality(
                                textDirection: TextDirection.ltr,
                                child: Pinput(
                                  androidSmsAutofillMethod: AndroidSmsAutofillMethod.none,
                                  closeKeyboardWhenCompleted: true,
                                  //senderPhoneNumber: ,
                                  controller: pinTextCtr,
                                  smsCodeMatcher: widget.sign,
                                  defaultPinTheme: PinTheme(
                                    width: 56,
                                    height: 56,
                                    textStyle: const TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.w600),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      //border: Border.all(color: const Color.fromRGBO(234, 239, 243, 1)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  length: 6,
                                  pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                                  showCursor: true,
                                  onChanged: (pin){
                                    otpCode = pin;
                                  },
                                  onCompleted: (pin) {
                                    otpCode = pin;
                                    callState();
                                  },
                                ),
                              ),

                              const SizedBox(height: 10),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: changeNumberClick,
                                    child: Text(AppMessages.otpDescriptionChangeNumber),
                                  ),

                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Visibility(
                                          visible: showResendOtpButton,
                                          child: ActionChip(
                                            onPressed: resetTimer,
                                            backgroundColor: Colors.white,
                                            label: Text(AppMessages.otpResend, style: const TextStyle(color: Colors.black)),
                                          )
                                      ),

                                      StreamBuilder<int>(
                                        stream: stopWatchTimer.rawTime,
                                        initialData: 0,
                                        builder: (context, snap) {
                                          final value = snap.data;
                                          final displayTime = StopWatchTimer.getDisplayTime(value!, hours: false, milliSecond: false);
                                          return Text('  $displayTime  ',);
                                        },
                                      ),

                                      Image.asset(AppImages.watchIco),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                    onPressed: otpCode.length < 6? null : sendOtpCode,
                                    child: Text(AppMessages.send)
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        SizedBox(
                            height: MathHelper.minDouble(70, sh*0.14),
                            child: Image.asset(AppImages.keyboardOpacity, width: sw*0.75)
                        ),

                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void resetTimer(){
    stopWatchTimer.setPresetTime(mSec: StopWatchTimer.getMilliSecFromMinute(1));
    stopWatchTimer.onStartTimer();
    showResendOtpButton = false;
    pinTextCtr.clear();

    resendOtpCode();
    callState();
  }

  void changeNumberClick(){
    RouteTools.popTopView(context: context);
  }

  void resendOtpCode() async {
    final httpRequester = await LoginService.requestSendOtp(phoneNumber: widget.phoneNumber, sign: widget.sign);

    if(httpRequester == null){
      if(context.mounted) {
        AppSnack.showSnack$errorCommunicatingServer(context);
      }
      return;
    }

    int statusCode = httpRequester.responseData!.statusCode?? 0;

    if(statusCode != 200){
      String? message;

      if(httpRequester.getBodyAsJson() != null) {
        message = httpRequester.getBodyAsJson()![Keys.message];
      }

      if(message == null) {
        if(context.mounted) {
          AppSnack.showSnack$serverNotRespondProperly(context);
        }
      }
      else {
        if(context.mounted) {
          AppSnack.showError(context, message);
        }
      }
    }
  }

  void sendOtpCode() async {
    showLoading();

    final twoReturn = await LoginService.requestVerifyOtp(phoneNumber: widget.phoneNumber, code: otpCode);

    if(twoReturn.isEmpty()){
      await hideLoading();
      if(context.mounted) {
        AppSnack.showSnack$errorCommunicatingServer(context);
      }
      return;
    }

    if(twoReturn.hasResult2()){
      await hideLoading();
      String? message = twoReturn.result2![Keys.message];

      if(message == null) {
        if(context.mounted) {
          AppSnack.showSnack$serverNotRespondProperly(context);
        }
      }
      else {
        if(context.mounted) {
          AppSnack.showError(context, message);
        }
      }
    }

    final dataJs = twoReturn.result1![Keys.data];

    if(dataJs == null || dataJs[Keys.token] == null) {
      await hideLoading();
      AppDB.setReplaceKv(Keys.setting$registerPhoneNumber, widget.phoneNumber);
      AppDB.setReplaceKv(Keys.setting$registerPhoneNumberTs, DateHelper.getNowTimestamp());
      AppBroadcast.reBuildMaterial();

      if(context.mounted) {
        RouteTools.backToRoot(context);
      }
    }
    else {
      if(dataJs[Keys.mobileNumber] == null){
        dataJs[Keys.mobileNumber] = widget.phoneNumber;
      }

      await SessionService.login$newProfileData(dataJs);
      await hideLoading();
      AppBroadcast.reBuildMaterial();

      if(context.mounted) {
        RouteTools.backToRoot(context);
      }
    }
  }

  double calc(double maxResult, double maxResultFor, double minResult, double minResultFor, double num, {bool symmetry = false}){
    if(symmetry){
      double temp = maxResult;
      maxResult = minResult;
      minResult = temp;
    }

    if(num >= maxResultFor){
      return maxResult;
    }

    if(num <= minResultFor){
      return minResult;
    }

    double difResult = maxResult - minResult;
    double difRange = maxResultFor - minResultFor;

    double percent = 100 * (num - minResultFor) / difRange;
    double wPer = difResult * percent / 100;
    double res = wPer + minResult;

    return res;
  }
}
