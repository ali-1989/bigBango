import 'dart:async';
import 'dart:io';

import 'package:app/services/file_upload_service.dart';
import 'package:app/structures/enums/fileUploadType.dart';
import 'package:app/structures/models/mediaModel.dart';
import 'package:app/tools/deviceInfoTools.dart';
import 'package:flutter/material.dart';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iris_pic_editor/pic_editor.dart';
import 'package:iris_tools/api/checker.dart';
import 'package:iris_tools/api/helpers/fileHelper.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/features/overlayDialog.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/irisImageView.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:persian_modal_date_picker/button.dart';
import 'package:persian_modal_date_picker/persian_date_picker.dart';
import 'package:shamsi_date/shamsi_date.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/middleWare/requester.dart';
import 'package:app/structures/models/userModel.dart';
import 'package:app/structures/enums/enums.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appDirectories.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/tools/app/appSnack.dart';
import 'package:app/tools/dateTools.dart';
import 'package:app/tools/permissionTools.dart';

class ProfilePage extends StatefulWidget {
  final UserModel userModel;

  ProfilePage({
    required this.userModel,
    Key? key,
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}
///===================================================================================================================
class _ProfilePageState extends StateBase<ProfilePage> {
  TextEditingController nameTextCtr = TextEditingController();
  TextEditingController familyTextCtr = TextEditingController();
  TextEditingController emailTextCtr = TextEditingController();
  TextEditingController mobileTextCtr = TextEditingController();
  late UserModel user;
  List<DropdownMenuItem<int>> genderList = [];
  int? currentGender;
  Requester requester = Requester();
  DateTime? birthDate;
  String birthDateText = '';
  late InputDecoration inputDecoration;
  bool hasChanges = false;
  Map<String, dynamic> userFixInfo = {};
  Map<String, dynamic> userChangeInfo = {};

  @override
  void initState(){
    super.initState();

    user = widget.userModel;

    Map<String, int> genderText = {
      'مرد' : 1,
      'زن' : 0,
    };

    final temp = genderText.map((k, v){
      return MapEntry<int, DropdownMenuItem<int>>(v, DropdownMenuItem<int>(value: v, child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(k),
      )));
    }).values.toList();

    genderList.addAll(temp);

    inputDecoration = InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      filled: true,
      fillColor: Colors.grey.shade100,
      hintStyle: const TextStyle(color: Colors.grey),
      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      isDense: true,
    );

    prepare();
    requestProfile();
  }

  @override
  void dispose(){
    nameTextCtr.dispose();
    familyTextCtr.dispose();
    emailTextCtr.dispose();
    mobileTextCtr.dispose();
    requester.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
      builder: (_, ctr, data) {
        print('^^^^^^^^^^^^^^^^^^^^^^^  ${user.avatarModel?.fileLocation}, ${user.avatarModel}');//todo
        print('^^^^^^^^^^^^^^^^^^^^^^^  ${user.token}');//todo
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SizedBox.expand(
              child: Scaffold(
                body: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    const SizedBox(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 10),
                            Image.asset(AppImages.changeImage, color: AppColors.red),
                            const SizedBox(width: 8),
                            Text('پروفایل و اطلاعات', style: const TextStyle(fontSize: 17)),
                          ],
                        ),

                        RotatedBox(
                          quarterTurns: 2,
                            child: BackButton()
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    IrisImageView(
                      height: 70,
                      beforeLoadWidget: Image.asset(AppImages.profileBig, height: 70),
                      url: user.avatarModel?.fileLocation,
                    ),

                    const SizedBox(height: 10),
                    Center(
                      child: IntrinsicWidth(
                        child: Column(
                          children: [
                            Divider(color: Colors.black54),
                            SizedBox(height: 5),

                            GestureDetector(
                              onTap: changeAvatarClick,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(AppImages.changeImage, width: 20),
                                  SizedBox(width: 10),
                                  Text('تغییر تصویر پروفایل')
                                ],
                              ),
                            ),

                            SizedBox(height: 5),
                            Divider(color: Colors.black54),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('نام').color(Colors.grey),
                              const SizedBox(height: 6),

                              TextField(
                                controller: nameTextCtr,
                                onChanged: (t){
                                  userChangeInfo[Keys.firstName] = t;
                                  compareChanges();
                                },
                                textInputAction: TextInputAction.next,
                                decoration: inputDecoration
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('نام خانوادگی').color(Colors.grey),
                              const SizedBox(height: 6),

                              TextField(
                                controller: familyTextCtr,
                                textInputAction: TextInputAction.next,
                                onChanged: (t){
                                  userChangeInfo[Keys.lastName] = t;
                                  compareChanges();
                                },
                                decoration: inputDecoration
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('شماره موبایل').color(Colors.grey),
                        const SizedBox(height: 6),

                        TextField(
                          controller: mobileTextCtr,
                          enabled: false,
                          decoration: inputDecoration
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ایمیل').color(Colors.grey),
                        const SizedBox(height: 6),

                        TextField(
                          controller: emailTextCtr,
                          onChanged: (t){
                            userChangeInfo['email'] = t;
                            compareChanges();
                          },
                          decoration: inputDecoration
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('جنسیت', style: TextStyle(color: Colors.grey)),
                                const SizedBox(height: 6),

                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: ColoredBox(
                                    color: Colors.grey.shade100,
                                    child: DropdownButton2<int>(
                                      items: genderList,
                                      value: currentGender,
                                      hint: const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 10),
                                        child: Text('جنسیت', style: TextStyle(color: Colors.grey)),
                                      ),
                                      itemPadding: const EdgeInsets.symmetric(horizontal: 10),
                                      dropdownPadding: const EdgeInsets.symmetric(horizontal: 10),
                                      onChanged: (value) {
                                        currentGender = value;
                                        userChangeInfo[Keys.gender] = currentGender;
                                        compareChanges();
                                      },
                                      buttonHeight: 40,
                                      buttonWidth: 140,
                                      itemHeight: 40,
                                      underline: const SizedBox(),
                                    ),
                                  ),
                                ),
                              ],
                            )
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('تاریخ تولد', style: const TextStyle(color: Colors.grey)),
                                const SizedBox(height: 6),

                                InkWell(
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
                                                Text(birthDateText),
                                                Image.asset(AppImages.calendarIco)
                                              ],
                                            ),
                                          )
                                      )
                                  ),
                                ),
                              ],
                            )
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    ElevatedButton(
                        onPressed: hasChanges? sendChanges : null,
                        child: Text('ثبت تغییرات')
                    ),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  void prepare(){
    nameTextCtr.text = user.name?? '';
    familyTextCtr.text = user.lastName?? '';
    emailTextCtr.text = user.email?? '';
    mobileTextCtr.text = user.mobile?? '';

    currentGender = user.gender;
    birthDate = user.birthDate;

    if(birthDate != null) {
      birthDateText = DateTools.dateOnlyRelative(birthDate!);
    }

    userFixInfo[Keys.firstName] = nameTextCtr.text;
    userFixInfo[Keys.lastName] = familyTextCtr.text;
    userFixInfo[Keys.mobileNumber] = mobileTextCtr.text;
    userFixInfo['email'] = emailTextCtr.text;
    userFixInfo[Keys.gender] = currentGender;

    if(birthDate != null) {
      userFixInfo[Keys.birthdate] = DateHelper.dateOnlyToStamp(birthDate!);
    }

    /// create a copy of user for compare changes
    userChangeInfo = JsonHelper.clone(userFixInfo);
  }

  void compareChanges(){
    hasChanges = !JsonHelper.deepEquals(userChangeInfo, userFixInfo);
    callState();
  }

  void changeBirthdate() async {
    Jalali? curBirthdate;

    if(birthDate != null){
      curBirthdate = Jalali.fromDateTime(birthDate!);
    }

    await showPersianDatePicker(
      context,
       margin: EdgeInsets.only(bottom: 50),
      (context, Date date) async {
        birthDate = date.toDateTime();
        birthDateText = DateTools.dateOnlyRelative(birthDate!);

        userChangeInfo[Keys.birthdate] = DateHelper.dateOnlyToStamp(birthDate!);
        compareChanges();
        Navigator.of(context).pop();
      },
        initDay: curBirthdate?.day,
        initMonth: curBirthdate?.month,
        initYear: curBirthdate?.year,
      border: const BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15)),
      validate: (ctx, date) {
        return date.year < 1398;
      },
      submitButtonStyle: ButtonsStyle(
        text: AppMessages.select,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        radius: 10,
      )
    );
  }

  void changeAvatarClick() async {
    List<Widget> widgets = [];
    widgets.add(
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: (){
            onSelectAvatar(1);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(AppIcons.camera, size: 20),
                SizedBox(width: 12),
                Text('دوربین').bold(),
              ],
            ),
          ),
        ));

    widgets.add(
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: (){
            onSelectAvatar(2);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(AppIcons.picture, size:20),
                SizedBox(width: 12),
                Text('گالری').bold(),
              ],
            ),
          ),
        ));

    if(user.avatarModel != null){
      widgets.add(
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: deleteAvatar,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(AppIcons.delete, size: 20),
                  SizedBox(width: 12),
                  Text('حذف').bold(),
                ],
              ),
            ),
          ));
    }

    AppSheet.showSheetMenu(
      context,
      widgets,
      'changeAvatar',

    );
  }

  void onSelectAvatar(int state) async {
    AppSheet.closeSheet(context);

    XFile? image;

    if(state == 1){
      image = await selectImageFromCamera();
    }
    else {
      image = await selectImageFromGallery();
    }

    if(image == null){
      return;
    }

    String? path = await editImage(image.path);

    if(path != null){
      uploadAvatar(path);
    }
  }

  Future<XFile?> selectImageFromCamera() async {
    final hasPermission = await PermissionTools.requestStoragePermission();

    if(hasPermission != PermissionStatus.granted) {
      return null;
    }

    final pick = await ImagePicker().pickImage(source: ImageSource.camera);

    if(pick == null) {
      return null;
    }

    return pick;
  }

  Future<XFile?> selectImageFromGallery() async {
    final hasPermission = await PermissionTools.requestStoragePermission();

    if(hasPermission != PermissionStatus.granted) {
      return null;
    }

    final pick = await ImagePicker().pickImage(source: ImageSource.gallery);

    if(pick == null) {
      return null;
    }

    return pick;
  }

  Future<String?> editImage(String imgPath) async {
    final comp = Completer<String?>();

    final editOptions = EditOptions.byPath(imgPath);
    editOptions.cropBoxInitSize = const Size(200, 170);

    void onOk(EditOptions op) async {
      final pat = AppDirectories.getSavePathByPath(SavePathType.userProfile, imgPath)!;

      FileHelper.createNewFileSync(pat);
      FileHelper.writeBytesSync(pat, editOptions.imageBytes!);

      comp.complete(pat);
    }

    editOptions.callOnResult = onOk;
    final ov = OverlayScreenView(content: PicEditor(editOptions), backgroundColor: Colors.black);
    OverlayDialog().show(context, ov).then((value){
      if(!comp.isCompleted){
        comp.complete(null/*imgPath*/);
      }
    });

    return comp.future;
  }

  void uploadAvatar(String filePath) async {
    showLoading(canBack: false);
    final uploadRes = await FileUploadService.uploadFiles([File(filePath)], FileUploadType.avatar);
    bool isOk = false;
    String? message;

    if(uploadRes.hasResult1()){
      final data = uploadRes.result1![Keys.data];

      if(data is List) {
        final media = MediaModel.fromMap(data[0]['file']);

        isOk = await requestUpdateAvatar(media);

        if(isOk){
          media.path = filePath;
          user.avatarModel = media;
          Session.sinkUserInfo(user);
        }
      }
    }
    else {
      final res = uploadRes.result2!.data;

      if(res != null){
        final js = JsonHelper.jsonToMap(res)?? {};
        message = js['message'];
      }
    }

    hideLoading();

    if(message != null){
      AppSnack.showInfo(context, message);
    }
    else {
      if(isOk) {
        AppSnack.showSnack$operationSuccess(context);
      }
      else {
        AppSnack.showSnack$errorCommunicatingServer(context);
      }
    }

    assistCtr.updateHead();
  }

  void deleteAvatar(){
    AppSheet.closeSheet(context);

    final js = <String, dynamic>{};


    requester.httpRequestEvents.onAnyState = (req) async {
      await hideLoading();
    };

    requester.httpRequestEvents.onFailState = (req, r) async {
      AppSnack.showSnack$OperationFailed(context);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      user.avatarModel = null;

      //AppBroadcast.avatarNotifier.notifyAll(null);
      Session.sinkUserInfo(user);
    };

    showLoading();
    requester.bodyJson = js;
    //requester.prepareUrl();

    requester.request(context, false);
  }

  void sendChanges(){
    final name = nameTextCtr.text.trim();
    final family = familyTextCtr.text.trim();
    final email = emailTextCtr.text.trim();

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

    if(currentGender == null){
      AppSnack.showError(context, AppMessages.genderNotDefined);
      return;
    }

    requestUpdate();
  }

  void requestProfile(){
    requester.httpRequestEvents.onStatusOk = (req, data) async {
      final js = JsonHelper.jsonToMap(data)!;
      final message = js['message'];
      final dataText = js['data'];

      if(message != null) {
        AppSnack.showInfo(context, message);
      }

      if(dataText != null) {
        final temp = UserModel.fromMap(dataText);

        final user = Session.getLastLoginUser()!;
        user.matchBy(temp);

        user.mobile ??= userFixInfo[Keys.mobileNumber];

        Session.sinkUserInfo(user);

        prepare();
        assistCtr.updateHead();
      }
    };

    requester.prepareUrl(pathUrl: '/profile?ClientSecret=${DeviceInfoTools.deviceId}');
    requester.methodType = MethodType.get;
    requester.request(context, false);
  }

  void requestUpdate(){
    final name = nameTextCtr.text.trim();
    final family = familyTextCtr.text.trim();
    final email = emailTextCtr.text.trim();

    requester.httpRequestEvents.onAnyState = (req) async {
      await hideLoading();
    };

    requester.httpRequestEvents.onFailState = (req, res) async {
      if(res != null){
        final js = JsonHelper.jsonToMap(res.data)!;
        final message = js['message'];

        if(message != null){
          AppSnack.showInfo(context, message);
          return;
        }
      }

      AppSnack.showInfo(context, 'خطایی رخ داده است');
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      final js = JsonHelper.jsonToMap(data)!;
      final message = js['message'];

      if(message != null) {
        AppSnack.showInfo(context, message);
      }
      else {
        AppSnack.showInfo(context, 'ثبت شد');
      }

      final user = Session.getLastLoginUser()!;
      user.name = name;
      user.lastName = family;
      user.email = email;
      user.gender = currentGender;
      user.birthDate = birthDate;

      Session.sinkUserInfo(user);
    };


    final js = <String, dynamic>{};
    js['firstName'] = name;
    js['lastName'] = family;
    js['gender'] = currentGender;
    js['birthDate'] = DateHelper.dateOnlyToStamp(birthDate!);

    if(email.isNotEmpty){
      js['email'] = email;
    }

    requester.bodyJson = js;
    requester.prepareUrl(pathUrl: '/profile/update');
    requester.methodType = MethodType.put;

    showLoading();
    requester.request(context, false);
  }

  Future<bool> requestUpdateAvatar(MediaModel media){
    Completer<bool> result = Completer();

    requester.httpRequestEvents.onFailState = (req, res) async {
      result.complete(false);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      result.complete(true);
    };

    final js = <String, dynamic>{};
    js['avatarId'] = media.id;


    requester.bodyJson = js;
    requester.prepareUrl(pathUrl: '/profile/update');
    requester.methodType = MethodType.put;

    requester.request(context, false);

    return result.future;
  }
}
