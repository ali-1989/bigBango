import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:animate_do/animate_do.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_pic_editor/pic_editor.dart';
import 'package:iris_tools/api/checker.dart';
import 'package:iris_tools/api/helpers/clone.dart';
import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/api/helpers/fileHelper.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/api/helpers/inputFormatter.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/helpers/textHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/features/overlayDialog.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/icon/circular_icon.dart';
import 'package:iris_tools/widgets/iris_image_view.dart';
import 'package:mask_input_formatter/mask_input_formatter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:persian_modal_date_picker/button.dart';
import 'package:persian_modal_date_picker/persian_date_picker.dart';
import 'package:shamsi_date/shamsi_date.dart';

import 'package:app/services/file_upload_service.dart';
import 'package:app/services/session_service.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/enums/app_events.dart';
import 'package:app/structures/enums/enums.dart';
import 'package:app/structures/enums/fileUploadType.dart';
import 'package:app/structures/enums/genderType.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/cityModel.dart';
import 'package:app/structures/models/mediaModel.dart';
import 'package:app/structures/models/provinceModel.dart';
import 'package:app/structures/models/user_model.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_directories.dart';
import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_sheet.dart';
import 'package:app/tools/app/app_snack.dart';
import 'package:app/tools/date_tools.dart';
import 'package:app/tools/device_info_tools.dart';
import 'package:app/tools/permission_tools.dart';

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
class _ProfilePageState extends StateSuper<ProfilePage> {
  TextEditingController nameTextCtr = TextEditingController();
  TextEditingController familyTextCtr = TextEditingController();
  TextEditingController emailTextCtr = TextEditingController();
  TextEditingController mobileTextCtr = TextEditingController();
  TextEditingController ibanTextCtr = TextEditingController();
  late MaskInputFormatter ibanFormatter;
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
  String assistId$city = 'assistId_city';
  List<DropdownMenuItem<ProvinceModel>> provinceDropDownList = [];
  List<DropdownMenuItem<CityModel>> cityDropDownList = [];
  List<ProvinceModel> provinceList = [];
  List<CityModel> cityList = [];
  CityModel? city;
  ProvinceModel? province;

  @override
  void initState(){
    super.initState();

    user = widget.userModel;

    List<GenderType> genders = GenderType.values.where((element) => element.number > -1).toList();

    final temp = genders.map<DropdownMenuItem<int>>((k){
      return DropdownMenuItem<int>(value: k.number, child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(k.getTypeHuman()),
      ));
    }).toList();

    genderList.addAll(temp);

    ibanFormatter = MaskInputFormatter(mask: '## #### #### #### #### ######');

    inputDecoration = InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      filled: true,
      fillColor: Colors.grey.shade100,
      hintStyle: const TextStyle(color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      isDense: true,
    );

    prepare();
    requestProvinces();
  }

  @override
  void dispose(){
    nameTextCtr.dispose();
    familyTextCtr.dispose();
    emailTextCtr.dispose();
    mobileTextCtr.dispose();
    ibanTextCtr.dispose();
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
              child: Scaffold(
                body: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    //const SizedBox(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 10),
                            Image.asset(AppImages.changeImage, color: AppDecoration.red),
                            const SizedBox(width: 8),
                            const Text('پروفایل و اطلاعات', style: TextStyle(fontSize: 17)),
                          ],
                        ),

                        const RotatedBox(
                          quarterTurns: 2,
                            child: BackButton()
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    Visibility(
                        visible: !user.hasAvatar(),
                        child: Image.asset(AppImages.profileBig, height: 70),
                    ),

                    Visibility(
                        visible: user.hasAvatar(),
                        child: Center(
                          child: IrisImageView(
                            height: 70,
                            width: 70,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                            beforeLoadWidget: const SizedBox(
                              height: 70,
                                width: 70,
                                child: UnconstrainedBox(
                                  child: SizedBox(
                                      height: 30,
                                      width: 30,
                                      child: CircularProgressIndicator()
                                  ),
                                )
                            ),
                            bytes: user.avatarModel?.bytes,
                            url: user.avatarModel?.fileLocation,
                            onDownloadFn: (bytes, path){
                              user.avatarModel?.bytes = bytes;
                            },
                          ),
                        ),
                    ),

                    const SizedBox(height: 10),
                    Center(
                      child: IntrinsicWidth(
                        child: Column(
                          children: [
                            const Divider(color: Colors.black54),
                            const SizedBox(height: 5),

                            GestureDetector(
                              onTap: changeAvatarClick,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(AppImages.changeImage, width: 20),
                                  const SizedBox(width: 10),
                                  const Text('تغییر تصویر پروفایل')
                                ],
                              ),
                            ),

                            const SizedBox(height: 5),
                            const Divider(color: Colors.black54),
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
                              const Text('نام').color(Colors.grey),
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

                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('نام خانوادگی').color(Colors.grey),
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
                        const Text('شماره موبایل').color(Colors.grey),
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
                        const Text('ایمیل').color(Colors.grey),
                        const SizedBox(height: 6),

                        TextField(
                          controller: emailTextCtr,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (t){
                            userChangeInfo['email'] = t;
                            compareChanges();
                          },
                          decoration: inputDecoration
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Text('محل سکونت', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 6),

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
                                      color: Colors.grey.shade100,
                                      child: DropdownButton2<ProvinceModel>(
                                        items: provinceDropDownList,
                                        value: province,
                                        barrierColor: Colors.black26,
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
                                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                                          child: SizedBox(
                                            width: 12,
                                            height: 12,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
                                        ),
                                        menuItemStyleData: const MenuItemStyleData(
                                          height: 40,
                                          padding: EdgeInsets.symmetric(horizontal: 5),
                                        ),
                                        buttonStyleData: ButtonStyleData(
                                          height: 40,
                                          width: double.infinity,
                                          overlayColor: MaterialStateProperty.all(Colors.transparent),
                                          padding: const EdgeInsets.symmetric(horizontal: 5),
                                        ),
                                        onChanged: (value) {
                                          province = value;
                                          city = null;
                                          generateCity();
                                          userChangeInfo['provinceId'] = value?.id;
                                          compareChanges();

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
                                      color: Colors.grey.shade100,
                                      child: DropdownButton2<CityModel>(
                                        items: cityDropDownList,
                                        value: city,
                                        barrierColor: Colors.black26,
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
                                        buttonStyleData: ButtonStyleData(
                                          height: 40,
                                          width: double.infinity,
                                          overlayColor: MaterialStateProperty.all(Colors.transparent),
                                          padding: const EdgeInsets.symmetric(horizontal: 5),
                                        ),
                                        onChanged: (value) {
                                          city = value;
                                          userChangeInfo['cityId'] = value?.id;
                                          compareChanges();

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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('جنسیت', style: TextStyle(color: Colors.grey)),
                                const SizedBox(height: 6),

                                SizedBox(
                                  width: double.infinity,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: ColoredBox(
                                      color: Colors.grey.shade100,
                                      child: DropdownButton2<int>(
                                        items: genderList,
                                        value: currentGender,
                                        barrierColor: Colors.black26,
                                        buttonStyleData: ButtonStyleData(
                                          height: 40,
                                          width: double.infinity,
                                          overlayColor: MaterialStateProperty.all(Colors.transparent),
                                          padding: const EdgeInsets.symmetric(horizontal: 5),
                                        ),
                                        dropdownStyleData: DropdownStyleData(
                                          width: ws/2,
                                          decoration:BoxDecoration(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 5),
                                          elevation: 8,
                                          isOverButton: false,
                                          scrollbarTheme: ScrollbarThemeData(
                                              radius: const Radius.circular(40),
                                              thickness: MaterialStateProperty.all<double>(5)
                                          ),
                                        ),
                                        menuItemStyleData: const MenuItemStyleData(
                                          height: 40,
                                          padding: EdgeInsets.symmetric(horizontal: 5),
                                        ),
                                        hint: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 10),
                                          child: Text('جنسیت', style: TextStyle(color: Colors.grey)),
                                        ),
                                        onChanged: (value) {
                                          currentGender = value;
                                          userChangeInfo[Keys.gender] = currentGender;
                                          compareChanges();
                                        },
                                        underline: const SizedBox(),
                                      ),
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
                                const Text('تاریخ تولد', style: TextStyle(color: Colors.grey)),
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

                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('شماره شبا').color(Colors.grey),
                            const SizedBox(width: 5),

                            GestureDetector(
                              onTap: onIbanQuestionMarkClick,
                              child: const CircularIcon(
                                size: 15,
                                icon: AppIcons.questionMark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: TextField(
                              controller: ibanTextCtr,
                              inputFormatters: [ibanFormatter],
                              onChanged: (t){
                                userChangeInfo['iban'] = t;
                                compareChanges();
                              },
                              decoration: inputDecoration.copyWith(
                                prefixIcon: const Text('  IR ').alpha(),
                                prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                              )
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                        onPressed: hasChanges? sendChanges : null,
                        child: const Text('ثبت تغییرات')
                    ),

                    const SizedBox(height: 20),
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
    ibanTextCtr.text = user.iban?? '';

    ibanTextCtr.text = ibanTextCtr.text.replaceAll('IR', '');

    if(ibanTextCtr.text.isNotEmpty) {
      final old = InputFormatter.genTextEditingValue('');
      final te = InputFormatter.genTextEditingValue(ibanTextCtr.text);
      ibanTextCtr.text = ibanFormatter.formatEditUpdate(old, te).text;
    }

    currentGender = user.gender;
    birthDate = user.birthDate;

    if(birthDate != null) {
      birthDateText = DateTools.dateOnlyRelative(birthDate!);
    }

    userFixInfo[Keys.firstName] = nameTextCtr.text;
    userFixInfo[Keys.lastName] = familyTextCtr.text;
    userFixInfo[Keys.mobileNumber] = mobileTextCtr.text;
    userFixInfo['email'] = emailTextCtr.text;
    userFixInfo['iban'] = ibanTextCtr.text;
    userFixInfo[Keys.gender] = currentGender;
    userFixInfo['cityId'] = user.cityModel?.id;
    userFixInfo['provinceId'] = user.cityModel?.provinceId;

    if(birthDate != null) {
      userFixInfo[Keys.birthdate] = DateHelper.toTimestampDateOnly(birthDate!);
    }

    /// create a copy of user for compare changes
    userChangeInfo = Clone.cloneShallow(userFixInfo);
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
       margin: const EdgeInsets.only(bottom: 50),
      (context, Date date) async {
        birthDate = date.toDateTime();
        birthDateText = DateTools.dateOnlyRelative(birthDate!);

        userChangeInfo[Keys.birthdate] = DateHelper.toTimestampDateOnly(birthDate!);
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
                const Icon(AppIcons.camera, size: 20),
                const SizedBox(width: 12),
                const Text('دوربین').bold(),
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
                const Icon(AppIcons.picture, size:20),
                const SizedBox(width: 12),
                const Text('گالری').bold(),
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
                  const Icon(AppIcons.delete, size: 20),
                  const SizedBox(width: 12),
                  const Text('حذف').bold(),
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
    final hasPermission = await PermissionTools.requestCameraStoragePermissions();

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
    final hasPermission = await PermissionTools.requestStoragePermissionWithOsVersion();

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

    final editOptions = EditOptions.byFile(imgPath);
    editOptions.cropBoxInitSize = const Size(200, 170);
    editOptions.primaryColor = ColorHelper.buildMaterialColor(Colors.black87);
    editOptions.secondaryColor = AppDecoration.red;
    editOptions.iconsColor = Colors.white;


    void onOk(EditOptions op) async {
      final pat = AppDirectories.getSavePathByPath(SavePathType.userProfile, imgPath)!;

      FileHelper.createNewFileSync(pat);
      FileHelper.writeBytesSync(pat, editOptions.imageBytes!);

      comp.complete(pat);
    }

    editOptions.callOnResult = onOk;
    final ov = OverlayScreenView(content: PicEditor(editOptions));
    OverlayDialog().show(context, ov).then((value){
      if(!comp.isCompleted){
        comp.complete(null/*imgPath*/);
      }
    });

    return comp.future;
  }

  void uploadAvatar(String filePath) async {
    showLoading(canBack: false);
    final twoResponse = await FileUploadService.uploadFiles([File(filePath)], FileUploadType.avatar);

    bool isOk = false;
    String? message;

    if(twoResponse.hasResult1()){
      final data = twoResponse.result1![Keys.data];

      if(data is List) {
        final media = MediaModel.fromMap(data[0]['file']);

        isOk = await requestUpdateAvatar(media);

        if(isOk){
          media.path = filePath;
          user.avatarModel = media;
          SessionService.sinkUserInfo(user);

          EventNotifierService.notify(AppEvents.userProfileChange);
        }
      }
    }
    else {
      final res = twoResponse.result2!.data;

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
        AppSnack.showSnackText(context, AppMessages.operationSuccess);
      }
      else {
        AppSnack.showSnackText(context, AppMessages.errorCommunicatingServer);
      }
    }

    assistCtr.updateHead();
  }

  void deleteAvatar(){
    AppSheet.closeSheet(context);


    requester.httpRequestEvents.onAnyState = (req) async {
      await hideLoading();
    };

    requester.httpRequestEvents.onFailState = (req, r) async {
      AppSnack.showSnackText(context, AppMessages.operationFailed);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      user.avatarModel = null;

      EventNotifierService.notify(AppEvents.userProfileChange);
      SessionService.sinkUserInfo(user);

      assistCtr.updateHead();
    };


    showLoading();
    requester.methodType = MethodType.delete;
    requester.prepareUrl(pathUrl: '/profile/deleteAvatar');

    requester.request(context, false);
  }

  void onIbanQuestionMarkClick(){
    OverlayDialog.showMiniInfo(
        context,
        child: const Text('شماره شبا برای برگرداندن اعتبار کیف پول به شما (در صورت نیاز) استفاده می شود'),
        builder :(_, c){
          return Bounce(child: c);
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

    if(city == null){
      AppSnack.showError(context, AppMessages.cityNotDefined);
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

        final user = SessionService.getLastLoginUser()!;
        temp.loginDate = user.loginDate;

        temp.avatarModel?.bytes = user.avatarModel?.bytes;

        user.matchBy(temp);

        user.mobile ??= userFixInfo[Keys.mobileNumber];

        SessionService.sinkUserInfo(user);

        prepare();
        assistCtr.updateHead();
      }
    };

    requester.prepareUrl(pathUrl: '/profile?ClientSecret=${DeviceInfoTools.deviceId}');
    requester.methodType = MethodType.get;
    requester.request(context, false);
  }

  void requestUpdate(){
    FocusHelper.hideKeyboardByUnFocusRoot();

    final name = nameTextCtr.text.trim();
    final family = familyTextCtr.text.trim();
    final email = emailTextCtr.text.trim();
    var iban = ibanTextCtr.text.trim();

    iban = iban.replaceAll(' ', '');

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

      final user = SessionService.getLastLoginUser()!;
      user.name = name;
      user.lastName = family;
      user.gender = currentGender;
      user.birthDate = birthDate;
      user.cityModel = cityList.firstWhereSafe((element) => element.id == city!.id);

      if(iban.isNotEmpty) {
        user.iban = iban;
      }

      if(email.isNotEmpty){
        user.email = email;
      }

      SessionService.sinkUserInfo(user);
      prepare();
      compareChanges();
      EventNotifierService.notify(AppEvents.userProfileChange);
    };


    final js = <String, dynamic>{};
    js['firstName'] = name;
    js['lastName'] = family;
    js['gender'] = currentGender;
    js['birthDate'] = DateHelper.toTimestampDateOnly(birthDate!);
    js['cityId'] = city?.id;

    if(iban.isNotEmpty) {
      if (!iban.startsWith('IR')){
        iban = 'IR$iban';
      }

      js['iban'] = iban;
    }

    if(email.isNotEmpty){
      js['email'] = email;
    }

    requester.bodyJson = js;
    requester.methodType = MethodType.put;
    requester.prepareUrl(pathUrl: '/profile/update');

    showLoading();
    requester.request(context, false);
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
        province = provinceList.firstWhereSafe((element) => element.id == user.cityModel?.provinceId)?? provinceList.first;

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
        cityList.clear();

        for(final x in data){
          cityList.add(CityModel.fromMap(x));
        }


        generateCity();
        city = cityList.firstWhereSafe((element) => element.id == user.cityModel?.id)?? cityList.first;

        assistCtr.updateAssist(assistId$city);
        requestProfile();
      }
    };

    requester.prepareUrl(pathUrl: '/cities');
    requester.methodType = MethodType.get;
    requester.request(context);
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
