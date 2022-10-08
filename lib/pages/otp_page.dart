import 'package:app/managers/fontManager.dart';
import 'package:app/models/abstract/stateBase.dart';
import 'package:app/services/login_service.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appDb.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appSnack.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/api/tools.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:pinput/pinput.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';


class OtpPage extends StatefulWidget {
  final String phoneNumber;

  const OtpPage({
    required this.phoneNumber,
    Key? key,
  }) : super(key: key);

  @override
  State<OtpPage> createState() => _OtpPageState();
}
///===================================================================================================================
class _OtpPageState extends StateBase<OtpPage> {
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

    addPostOrCall(() {
      stopWatchTimer.onExecute.add(StopWatchExecute.start);
    });
  }

  @override
  void dispose(){
    stopWatchTimer.dispose();
    pinTextCtr.dispose();
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
                  SizedBox(height: sh/2),

                  UnconstrainedBox(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                        height: sh * 0.50,
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
                                        TextSpan(text: ' ${widget.phoneNumber} ', style: const TextStyle(color: Colors.red)),
                                        TextSpan(text: AppMessages.otpDescriptionMobile2),
                                      ]
                                  )
                              ),

                              const SizedBox(height: 30),

                              Directionality(
                                textDirection: TextDirection.ltr,
                                child: Pinput(
                                  androidSmsAutofillMethod: AndroidSmsAutofillMethod.smsRetrieverApi,
                                  closeKeyboardWhenCompleted: true,
                                  //senderPhoneNumber: ,
                                  controller: pinTextCtr,
                                  smsCodeMatcher: 'xkij3pr8Ot',
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
    stopWatchTimer.onExecute.add(StopWatchExecute.start);
    showResendOtpButton = false;
    pinTextCtr.clear();

    resendOtpCode();
    callState();
  }

  void changeNumberClick(){
    AppRoute.pop(context);
  }

  void resendOtpCode() async {
    final httpRequester = await LoginService.requestSendOtp(phoneNumber: widget.phoneNumber);

    if(httpRequester == null){
      AppSnack.showSnack$errorCommunicatingServer(context);
      return;
    }

    int statusCode = httpRequester.responseData!.statusCode?? 0;

    if(statusCode != 200){
      String? message = httpRequester.getBodyAsJson()![Keys.message];

      if(message == null) {
        AppSnack.showSnack$serverNotRespondProperly(context);
      }
      else {
        AppSnack.showError(context, message);
      }
    }
  }

  void sendOtpCode() async {
    showLoading();
    final httpRequester = await LoginService.requestVerifyOtp(phoneNumber: widget.phoneNumber, code: otpCode);

    if(httpRequester == null){
      await hideLoading();
      AppSnack.showSnack$errorCommunicatingServer(context);
      return;
    }

    int statusCode = httpRequester.responseData!.statusCode?? 200;

    //422 : timeout
    if(statusCode != 200){
      await hideLoading();
      String? message = httpRequester.getBodyAsJson()![Keys.message];

      if(message == null) {
        AppSnack.showSnack$serverNotRespondProperly(context);
      }
      else {
        AppSnack.showError(context, message);
      }

      return;
    }


    final dataJs = httpRequester.getBodyAsJson()![Keys.data];

    if(dataJs == null || dataJs[Keys.token] == null) {
      await hideLoading();
      AppDB.setReplaceKv(Keys.setting$registerPhoneNumber, widget.phoneNumber);
      AppDB.setReplaceKv(Keys.setting$registerPhoneNumberTs, DateHelper.getNowTimestamp());
      AppBroadcast.reBuildMaterial();
      AppRoute.backToRoot(context);
    }
    else {
      print('///////////////////////////////////////////////');
      Tools.verbosePrint(dataJs);//todo
      print('///////////////////////////////////////////////');
      await Session.login$newProfileData(dataJs);
      await hideLoading();
      AppBroadcast.reBuildMaterial();
      AppRoute.backToRoot(context);
    }
  }
}
