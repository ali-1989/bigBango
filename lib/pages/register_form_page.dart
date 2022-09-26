import 'package:app/models/abstract/stateBase.dart';
import 'package:app/pages/select_language_level_page.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/dateTools.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:persian_modal_date_picker/button.dart';
import 'package:persian_modal_date_picker/persian_date_picker.dart';
import 'package:shamsi_date/shamsi_date.dart';

class RegisterFormPage extends StatefulWidget {
  final String phoneNumber;

  const RegisterFormPage({
    required this.phoneNumber,
    Key? key,
  }) : super(key: key);

  @override
  State<RegisterFormPage> createState() => _RegisterFormPageState();
}
///===================================================================================================================
class _RegisterFormPageState extends StateBase<RegisterFormPage> {
  TextEditingController nameTextCtr = TextEditingController();
  TextEditingController familyTextCtr = TextEditingController();
  TextEditingController emailTextCtr = TextEditingController();
  TextEditingController inviteCodeTextCtr = TextEditingController();
  List<DropdownMenuItem<int>> genderList = [];
  int? gender;
  DateTime? birthDate;
  String birthDateText = AppMessages.birthdate;
  late InputDecoration inputDecoration;

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
      fillColor: Colors.grey.shade100,
      hintStyle: const TextStyle(color: Colors.grey),
    );
  }

  @override
  void dispose(){
    nameTextCtr.dispose();
    familyTextCtr.dispose();
    emailTextCtr.dispose();
    inviteCodeTextCtr.dispose();

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
                    padding: const EdgeInsets.only(top: 250),
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
                                    decoration: inputDecoration.copyWith(
                                      hintText: AppMessages.registerFormEnterNameHint,
                                      prefixIcon: Image.asset(AppImages.userInputIco),
                                    ),
                                  ),

                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: nameTextCtr,
                                    decoration: inputDecoration.copyWith(
                                      hintText: AppMessages.registerFormEnterFamilyHint,
                                      prefixIcon: Image.asset(AppImages.userInputIco),
                                    ),
                                  ),

                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: nameTextCtr,
                                    decoration: inputDecoration.copyWith(
                                      hintText: AppMessages.registerFormEnterEmailHint,
                                      prefixIcon: Image.asset(AppImages.emailInputIco),
                                    ),
                                  ),

                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: ColoredBox(
                                              color: Colors.grey.shade100,
                                              child: DropdownButton2<int>(
                                                items: genderList,
                                                value: gender,
                                                hint: const Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                                  child: Text('جنسیت', style: TextStyle(color: Colors.grey)),
                                                ),
                                                itemPadding: const EdgeInsets.symmetric(horizontal: 10),
                                                dropdownPadding: const EdgeInsets.symmetric(horizontal: 10),
                                                onChanged: (value) {
                                                  gender = value;
                                                  callState();
                                                },
                                                buttonHeight: 40,
                                                buttonWidth: 140,
                                                itemHeight: 40,
                                                underline: const SizedBox(),
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
                                                    color: Colors.grey.shade100,
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
                            SizedBox(
                                height: MathHelper.minDouble(70, sh*0.14),
                                child: Image.asset(AppImages.keyboardOpacity, width: sw*0.75)
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
    );
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
      border: const BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15)),
      validate: (ctx, date) {
        return date.year < 1402;
      },
      submitButtonStyle: ButtonsStyle(
        text: AppMessages.select,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        radius: 10,
      )
    );
  }

  void sendClick(){
    final name = nameTextCtr.text.trim();
    final family = familyTextCtr.text.trim();
    final email = emailTextCtr.text.trim();
    final inviteCode = inviteCodeTextCtr.text.trim();

    AppRoute.push(context, SelectLanguageLevelPage());
  }
}
