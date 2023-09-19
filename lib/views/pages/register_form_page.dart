import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:iris_tools/api/checker.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/api/helpers/textHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:persian_modal_date_picker/button.dart';
import 'package:persian_modal_date_picker/persian_date_picker.dart';
import 'package:shamsi_date/shamsi_date.dart';

import 'package:app/services/session_service.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/cityModel.dart';
import 'package:app/structures/models/provinceModel.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_broadcast.dart';
import 'package:app/tools/app/app_db.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_sheet.dart';
import 'package:app/tools/app/app_snack.dart';
import 'package:app/tools/app/app_themes.dart';
import 'package:app/tools/app/app_toast.dart';
import 'package:app/tools/date_tools.dart';
import 'package:app/tools/device_info_tools.dart';

class RegisterFormPage extends StatefulWidget {
  final String phoneNumber;

  RegisterFormPage({
    required this.phoneNumber,
    Key? key,
  }) : super(key: key);

  @override
  State<RegisterFormPage> createState() => _RegisterFormPageState();
}
///===================================================================================================================
class _RegisterFormPageState extends StateSuper<RegisterFormPage> {
  TextEditingController nameTextCtr = TextEditingController();
  TextEditingController familyTextCtr = TextEditingController();
  TextEditingController emailTextCtr = TextEditingController();
  TextEditingController inviteCodeTextCtr = TextEditingController();
  List<DropdownMenuItem<int>> genderList = [];
  List<DropdownMenuItem<ProvinceModel>> provinceDropDownList = [];
  List<DropdownMenuItem<CityModel>> cityDropDownList = [];
  List<ProvinceModel> provinceList = [];
  List<CityModel> cityList = [];
  int? gender;
  CityModel? city;
  ProvinceModel? province;
  Requester requester = Requester();
  DateTime? birthDate;
  String birthDateText = AppMessages.birthdate;
  late InputDecoration inputDecoration;
  String assistId$city = 'assistId_city';

  @override
  void initState(){
    super.initState();

    Map<String, int> genderText = {
      'مرد' : 1,
      'زن' : 0,
    };

    genderList.addAll(genderText.map((k, v){
      return MapEntry<int, DropdownMenuItem<int>>(v, DropdownMenuItem<int>(value: v, child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(k),
      )));
    }).values.toList());

    inputDecoration =  InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      filled: true,
      fillColor: Colors.grey.shade200,
      hintStyle: const TextStyle(color: Colors.grey),
    );

    requestProvinces();
  }

  @override
  void dispose(){
    nameTextCtr.dispose();
    familyTextCtr.dispose();
    emailTextCtr.dispose();
    inviteCodeTextCtr.dispose();
    requester.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
      builder: (_, ctr, data) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SizedBox.expand(
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
                        SizedBox(height: hs/2),

                        UnconstrainedBox(
                          alignment: Alignment.topCenter,
                          child: SizedBox(
                              height: hs * 0.60,
                              width: ws,
                              child: Image.asset(AppImages.otp, fit: BoxFit.fill)
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(top: hs * 0.35),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                                child: Card(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18),
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
                                        Text(AppMessages.registerFormDescription),

                                        const SizedBox(height: 30),
                                        TextField(
                                          controller: nameTextCtr,
                                          textInputAction: TextInputAction.next,
                                          decoration: inputDecoration.copyWith(
                                            hintText: AppMessages.registerFormEnterNameHint,
                                            prefixIcon: Image.asset(AppImages.userInputIco),
                                          ),
                                        ),

                                        const SizedBox(height: 10),
                                        TextField(
                                          controller: familyTextCtr,
                                          decoration: inputDecoration.copyWith(
                                            hintText: AppMessages.registerFormEnterFamilyHint,
                                            prefixIcon: Image.asset(AppImages.userInputIco),
                                          ),
                                        ),

                                        const SizedBox(height: 10),
                                        TextField(
                                          controller: emailTextCtr,
                                          decoration: inputDecoration.copyWith(
                                            hintText: AppMessages.registerFormEnterEmailHint,
                                            prefixIcon: Image.asset(AppImages.emailInputIco),
                                          ),
                                        ),

                                        const SizedBox(height: 10),
                                        Assist(
                                          controller: assistCtr,
                                            id: assistId$city,
                                            builder: (_, ctr, data){
                                              return Row(
                                                children: [
                                                  Expanded(
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(8),
                                                        child: ColoredBox(
                                                          color: Colors.grey.shade200,
                                                          child: DropdownButton2<ProvinceModel>(
                                                            items: provinceDropDownList,
                                                            value: province,
                                                            underline: const SizedBox(),
                                                            dropdownStyleData: DropdownStyleData(
                                                              //width: 200,
                                                              elevation: 8,
                                                              maxHeight: 400,
                                                              isOverButton: false,
                                                              padding: const EdgeInsets.symmetric(horizontal: 5),
                                                              scrollbarTheme: ScrollbarThemeData(
                                                                  radius: const Radius.circular(20),
                                                                  thickness: MaterialStateProperty.all<double>(4)
                                                              ),
                                                              decoration:BoxDecoration(
                                                                borderRadius: BorderRadius.circular(10),
                                                              ),
                                                            ),
                                                            hint: const Padding(
                                                              padding: EdgeInsets.symmetric(horizontal: 10),
                                                              child: Text('استان', style: TextStyle(color: Colors.grey)),
                                                            ),
                                                            menuItemStyleData: const MenuItemStyleData(
                                                              height: 40,
                                                              padding: EdgeInsets.symmetric(horizontal: 5),
                                                            ),
                                                            buttonStyleData: const ButtonStyleData(
                                                              padding: EdgeInsets.symmetric(horizontal: 5),
                                                              width: double.infinity,
                                                            ),
                                                            onChanged: (value) {
                                                              province = value;
                                                              city = null;
                                                              generateCity();

                                                              assistCtr.updateAssist(assistId$city);
                                                            },
                                                          ),
                                                        ),
                                                      )
                                                  ),

                                                  const SizedBox(width: 10),

                                                  Expanded(
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(8),
                                                        child: ColoredBox(
                                                          color: Colors.grey.shade200,
                                                          child: DropdownButton2<CityModel>(
                                                            items: cityDropDownList,
                                                            value: city,
                                                            underline: const SizedBox(),
                                                            dropdownStyleData: DropdownStyleData(
                                                              //width: 200,
                                                              elevation: 8,
                                                              maxHeight: 400,
                                                              isOverButton: false,
                                                              padding: const EdgeInsets.symmetric(horizontal: 5),
                                                              scrollbarTheme: ScrollbarThemeData(
                                                                  radius: const Radius.circular(20),
                                                                  thickness: MaterialStateProperty.all<double>(4)
                                                              ),
                                                              decoration:BoxDecoration(
                                                                borderRadius: BorderRadius.circular(10),
                                                              ),
                                                            ),
                                                            hint: const Padding(
                                                              padding: EdgeInsets.symmetric(horizontal: 10),
                                                              child: Text('شهر', style: TextStyle(color: Colors.grey)),
                                                            ),
                                                            menuItemStyleData: const MenuItemStyleData(
                                                              height: 40,
                                                              padding: EdgeInsets.symmetric(horizontal: 5),
                                                            ),
                                                            buttonStyleData: const ButtonStyleData(
                                                                padding: EdgeInsets.symmetric(horizontal: 5),
                                                                width: double.infinity,
                                                            ),
                                                            onChanged: (value) {
                                                              city = value;
                                                              assistCtr.updateAssist(assistId$city);
                                                            },
                                                          ),
                                                        ),
                                                      )
                                                  ),
                                                ],
                                              );

                                            }
                                        ),


                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Expanded(
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(8),
                                                  child: ColoredBox(
                                                    color: Colors.grey.shade200,
                                                    child: DropdownButton2<int>(
                                                      items: genderList,
                                                      value: gender,
                                                      underline: const SizedBox(),
                                                      dropdownStyleData: DropdownStyleData(
                                                        //width: 200,
                                                        elevation: 8,
                                                        maxHeight: 400,
                                                        isOverButton: false,
                                                        padding: const EdgeInsets.symmetric(horizontal: 5),
                                                        scrollbarTheme: ScrollbarThemeData(
                                                            radius: const Radius.circular(20),
                                                            thickness: MaterialStateProperty.all<double>(4)
                                                        ),
                                                        decoration:BoxDecoration(
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                      ),
                                                      hint: const Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 10),
                                                        child: Text('جنسیت', style: TextStyle(color: Colors.grey)),
                                                      ),
                                                      menuItemStyleData: const MenuItemStyleData(
                                                        height: 40,
                                                        padding: EdgeInsets.symmetric(horizontal: 5),
                                                      ),
                                                      buttonStyleData: const ButtonStyleData(
                                                        padding: EdgeInsets.symmetric(horizontal: 5),
                                                        width: double.infinity,
                                                      ),
                                                      onChanged: (value) {
                                                        gender = value;
                                                        assistCtr.updateHead();
                                                      },
                                                    ),
                                                  ),
                                                )
                                            ),

                                            const SizedBox(width: 10),

                                            Expanded(
                                                child: InkWell(
                                                  onTap: changeBirthdate,
                                                  child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(8),
                                                      child: ColoredBox(
                                                          color: Colors.grey.shade200,
                                                          child: SizedBox(
                                                            height: 40,
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                              children: [
                                                                Text(birthDateText, style: const TextStyle(color: Colors.grey)),
                                                                Image.asset(AppImages.calendarIco)
                                                              ],
                                                            ),
                                                          )
                                                      )
                                                  ),
                                                )
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 10),
                                        TextField(
                                          controller: inviteCodeTextCtr,
                                          keyboardType: TextInputType.phone,
                                          decoration: inputDecoration.copyWith(
                                            hintText: AppMessages.registerFormEnterInviteHint,
                                            prefixIcon: Image.asset(AppImages.inviteCodeInputIco),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 30),

                              RichText(
                                  text: TextSpan(
                                      style: AppThemes.baseTextStyle().copyWith(fontSize: 14),
                                      children: [
                                        const TextSpan(
                                            text: 'شما با ثبت نام در بیگ بنگو  '
                                        ),

                                        TextSpan(
                                            style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                                            text: 'قوانین',
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = gotoTermPage
                                        ),

                                        const TextSpan(
                                            text: '  ما را می پذیرید'
                                        ),
                                      ]
                                  )
                              ),

                              const SizedBox(height: 30),

                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                          onPressed: sendClick,
                                          child: Text(AppMessages.send)
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 10),
                                  TextButton(
                                    onPressed: backToPhoneNumber,
                                    child: const Text('برگشت'),
                                  ),

                                  const SizedBox(height: 10),
                                  SizedBox(
                                      height: MathHelper.minDouble(70, hs * 0.14),
                                      child: Image.asset(AppImages.keyboardOpacity, width: ws * 0.75)
                                  ),
                                ],
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
          ),
        );
      }
    );
  }

  void generateProvince(){
    provinceDropDownList.clear();

    provinceDropDownList.addAll(provinceList.map((k){
      return DropdownMenuItem<ProvinceModel>(
          value: k,
          child: Text(TextHelper.subByCharCountSafe(k.name.trim(), 19), maxLines: 1, softWrap: false)
      );
    }).toList());
  }

  void generateCity(){
    cityDropDownList.clear();

    cityDropDownList.addAll(cityList.where((element) => element.provinceId == province?.id).map((k){
      return DropdownMenuItem<CityModel>(
          value: k,
          child: Text(TextHelper.subByCharCountSafe(k.name.trim(), 19), maxLines: 1, softWrap: false)
      );
    }).toList());
  }

  void changeBirthdate() async {
    Jalali? curBirthdate;

    if(birthDate != null){
      curBirthdate = Jalali.fromDateTime(birthDate!);
    }

    await showPersianDatePicker(
        context,
            (context, Date date) async {
              birthDate = date.toDateTime();
            birthDateText = DateTools.dateOnlyRelative(birthDate!);

            setState(() {});
            Navigator.of(context).pop();
        },
        initDay: curBirthdate?.day,
        initMonth: curBirthdate?.month,
        initYear: curBirthdate?.year,
        margin: const EdgeInsets.only(bottom: 50),
        border: const BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15)),
        validate: (ctx, date) {
          return date.year < 1400;
        },
        submitButtonStyle: ButtonsStyle(
          text: AppMessages.select,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          radius: 10,
        ),
    );
  }

  void sendClick(){
    final name = nameTextCtr.text.trim();
    final family = familyTextCtr.text.trim();
    final email = emailTextCtr.text.trim();
    final inviteCode = inviteCodeTextCtr.text.trim();

    if(name.isEmpty){
      AppSnack.showError(context, AppMessages.enterYourName);
      return;
    }

    if(name.length < 3){
      AppSnack.showError(context, AppMessages.yourNameIsLittle);
      return;
    }

    if(family.isEmpty){
      AppSnack.showError(context, AppMessages.enterYourFamily);
      return;
    }

    if(family.length < 3){
      AppSnack.showError(context, AppMessages.yourFamilyIsLittle);
      return;
    }

    if(email.isNotEmpty){
      if(!Checker.isValidEmail(email)){
        AppSnack.showError(context, AppMessages.emailFormatInCorrect);
        return;
      }
    }

    if(birthDate == null){
      AppSnack.showError(context, AppMessages.birthdateNotDefined);
      return;
    }

    if(gender == null){
      AppSnack.showError(context, AppMessages.genderNotDefined);
      return;
    }

    if(city == null){
      AppSnack.showError(context, AppMessages.cityNotDefined);
      return;
    }

    if(inviteCode.isNotEmpty){
      if(!Checker.validateMobile(inviteCode)){
        AppSnack.showError(context, AppMessages.inviteCodeInCorrect);
        return;
      }
    }

    requestRegister();
  }

  void gotoTermPage() {
  }

  void backToPhoneNumber() {
    AppDB.deleteKv(Keys.setting$registerPhoneNumber);
    AppBroadcast.reBuildMaterial();
  }

  void requestProvinces(){
    requester.httpRequestEvents.onFailState = (requester, res) async {
    };

    requester.httpRequestEvents.onStatusOk = (requester, js) async {
      final data = js[Keys.data];

      if(data is List){
        for(final x in data){
          provinceList.add(ProvinceModel.fromMap(x));
        }

        generateProvince();
        province = provinceList.first;

        if(cityList.isNotEmpty){
          generateCity();
          assistCtr.updateAssist(assistId$city);
        }
        else {
          requestCities();
        }
      }
    };

    requester.prepareUrl(pathUrl: '/provinces');
    requester.methodType = MethodType.get;
    requester.request(context);
  }

  void requestCities(){
    requester.httpRequestEvents.onFailState = (requester, res) async {
    };

    requester.httpRequestEvents.onStatusOk = (requester, js) async {
      final data = js[Keys.data];

      if(data is List){
        for(final x in data){
          cityList.add(CityModel.fromMap(x));
        }

        generateCity();
        assistCtr.updateAssist(assistId$city);
      }
    };

    requester.prepareUrl(pathUrl: '/cities');
    requester.methodType = MethodType.get;
    requester.request(context);
  }

  void requestRegister(){
    final name = nameTextCtr.text.trim();
    final family = familyTextCtr.text.trim();
    final email = emailTextCtr.text.trim();
    final inviteCode = inviteCodeTextCtr.text.trim();

    final js = <String, dynamic>{};
    js['phoneNumber'] = widget.phoneNumber;
    js['firstName'] = name;
    js['lastName'] = family;
    js['gender'] = gender;
    js['birthDate'] = DateHelper.dateOnlyToStamp(birthDate!);
    js['clientSecret'] = DeviceInfoTools.deviceId;
    js['cityId'] = city!.id;

    if(email.isNotEmpty){
      js['email'] = email;
    }

    if(inviteCode.isNotEmpty){
      js['introducerCode'] = inviteCode;
    }

    requester.httpRequestEvents.onAnyState = (requester) async {
      hideLoading();
    };

    requester.httpRequestEvents.onFailState = (requester, res) async {
      if(res != null){
        final js = JsonHelper.jsonToMap(res.data)!;
        final message = js['message'];

        if(res.statusCode == 307){
          // not defined
        }

        // timeout
        if(res.statusCode == 403){
          AppDB.deleteKv(Keys.setting$registerPhoneNumber);

          AppSheet.showSheetOneAction(context, message, onButton: (){
            AppBroadcast.reBuildMaterial();
          });

          return false;
        }

        // this user exist
        if(res.statusCode == 422){
          await AppDB.deleteKv(Keys.setting$registerPhoneNumber);
          AppSnack.showInfo(context, message);
          AppBroadcast.reBuildMaterial();
          return false;
        }
      }

      AppSnack.showInfo(context, AppMessages.serverNotRespondProperly);
    };

    requester.httpRequestEvents.onStatusOk = (requester, js) async {
      final data = js[Keys.data];
      final message = js[Keys.message];

      await SessionService.login$newProfileData(data);
      await AppDB.deleteKv(Keys.setting$registerPhoneNumber);

      AppToast.showToast(context, message);
      AppBroadcast.reBuildMaterial();
    };

    showLoading();
    requester.prepareUrl(pathUrl: '/register');
    requester.methodType = MethodType.post;
    requester.bodyJson = js;
    requester.request(context);
  }
}
