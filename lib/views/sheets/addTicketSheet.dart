import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_tools/api/converter.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/customCard.dart';

import 'package:app/services/file_upload_service.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/enums/fileUploadType.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/ticketModels/ticketModel.dart';
import 'package:app/structures/models/ticketModels/ticketRole.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appDecoration.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/tools/app/appSnack.dart';
import 'package:app/tools/app/appToast.dart';
import 'package:app/tools/routeTools.dart';
import 'package:app/views/components/attachmentFileTicketComponent.dart';

class AddTicketSheet extends StatefulWidget {
  final List<TicketRole> ticketRoles;

  const AddTicketSheet({
    required this.ticketRoles,
    Key? key,
  }) : super(key: key);

  @override
  State<AddTicketSheet> createState() => _AddTicketSheetState();
}
///==================================================================================================
class _AddTicketSheetState extends StateBase<AddTicketSheet> {
  Requester requester = Requester();
  TextEditingController titleCtr = TextEditingController();
  TextEditingController descriptionCtr = TextEditingController();
  String selectedTicketRoleId = '';
  List<DropdownMenuItem<String>> dropList = [];
  List<File> attachmentFiles = <File>[];
  List<String> attachmentIdsList = [];
  late TextStyle boldStyle;
  late InputDecoration inputDecoration;

  @override
  void dispose(){
    requester.dispose();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();

    for(final k in widget.ticketRoles){
      final h = DropdownMenuItem<String>(value: k.id, child: Text(k.name));
      dropList.add(h);
    }

    selectedTicketRoleId = dropList[0].value!;

    boldStyle = const TextStyle(fontWeight: FontWeight.w700, fontSize: 11);

    inputDecoration = InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      isDense: true,
      filled: true,
      fillColor: Colors.grey.shade100,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
        controller: assistCtr,
        builder: (_, ctr, data) {
          final x = MediaQuery.of(context).viewInsets;

          return SizedBox(
            width: double.infinity,
            height: x.collapsedSize.height < 10 ? sh *3/4 : sh - x.collapsedSize.height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 14),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(AppIcons.addCircle, color: AppDecoration.red),
                              SizedBox(width: 6),
                              Text('ایجاد تیکت', style: TextStyle(fontWeight: FontWeight.w700)),
                            ],
                          ),

                          GestureDetector(
                            onTap: (){
                              RouteTools.popTopView(context: context);
                            },
                            child: CustomCard(
                                color: Colors.grey.shade200,
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
                                radius: 4,
                                child: const Icon(AppIcons.close, size: 10)
                            ),
                          ),
                        ],
                      ),

                      Expanded(
                          child: ListView(
                            shrinkWrap: true,
                            children: [
                              const SizedBox(height: 20),
                              Text('موضوع', style: boldStyle),
                              const SizedBox(height: 5),

                              TextField(
                                controller: titleCtr,
                                decoration: inputDecoration,
                              ),

                              const SizedBox(height: 10),
                              Text('بخش مربوطه', style: boldStyle),
                              const SizedBox(height: 5),

                              DecoratedBox(
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(6)
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2<String>(
                                    items: dropList,
                                    value: selectedTicketRoleId,
                                    dropdownStyleData: DropdownStyleData(
                                      //width: 150,
                                      elevation: 0,
                                      isOverButton: false,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 5),
                                      scrollbarTheme: ScrollbarThemeData(
                                          radius: const Radius.circular(4),
                                          thickness: MaterialStateProperty.all<double>(5)
                                      ),
                                    ),
                                    menuItemStyleData: const MenuItemStyleData(
                                      height: 40,
                                      padding: EdgeInsets.symmetric(horizontal: 5),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedTicketRoleId = value as String;
                                        assistCtr.updateHead();
                                      });
                                    },
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),
                              Text('توضیحات', style: boldStyle),
                              const SizedBox(height: 5),

                              TextField(
                                controller: descriptionCtr,
                                minLines: 5,
                                maxLines: 5,
                                decoration: inputDecoration,
                              ),

                              const SizedBox(height: 15),
                              Visibility(
                                visible: attachmentFiles.isNotEmpty,
                                  child: Text('تعداد فایل ها: ${attachmentFiles.length}').thinFont().fsR(-2),
                              ),
                              const SizedBox(height: 15),

                              Row(
                                children: [
                                  ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                      icon: const Icon(AppIcons.attach),
                                      onPressed: showAttachmentDialog,
                                      label: const Text('فایل ها')
                                  ),

                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: ElevatedButton(
                                        onPressed: sendClick,
                                        child: const Text('ارسال')
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        }
    );
  }

  void showAttachmentDialog() async {
    attachmentIdsList.clear();

    await AppSheet.showSheetCustom(
      context,
      builder: (ctx) => AttachmentFileTicketComponent(files: attachmentFiles),
      routeName: 'openNewReply',
      contentColor: Colors.transparent,
      isScrollControlled: true,
    );

    assistCtr.updateHead();
  }

  void sendClick() async {
    if(attachmentFiles.isNotEmpty && attachmentIdsList.isEmpty){
      final files = await requestUploadFiles();

      if(files != null){
        attachmentIdsList = files.map<String>((e) => e['file']['id']).toList();
      }
    }

    if(attachmentIdsList.isNotEmpty){
      requestSendTicket(attachments: attachmentIdsList);
    }
    else {
      requestSendTicket();
    }
  }

  Future<List<Map>?> requestUploadFiles() async {
    FocusHelper.hideKeyboardByUnFocusRoot();

    final title = titleCtr.text.trim();
    final description = descriptionCtr.text.trim();

    if(title.isEmpty) {
      AppToast.showToast(context, 'لطفا موضوع را وارد کنید');
      return null;
    }

    if(title.length < 6) {
      AppToast.showToast(context, 'موضوع کوتاه است');
      return null;
    }

    if(description.isEmpty) {
      AppToast.showToast(context, 'لطفا توضیحات را وارد کنید');
      return null;
    }

    if(description.length < 6) {
      AppToast.showToast(context, 'توضیحات کوتاه است');
      return null;
    }

    showLoading();
    final uploadRes = await FileUploadService.uploadFiles(attachmentFiles, FileUploadType.ticket);
    await hideLoading();

    if(uploadRes.hasResult2()){
      final res = uploadRes.result2!.data;

      final js = JsonHelper.jsonToMap(res)?? {};
      final message = js['message']?? 'خطایی رخ داد';

      AppSnack.showInfo(context, message);
      return null;
    }

    if(uploadRes.hasResult1()){
      final data = uploadRes.result1![Keys.data];

      if(data is List) {
        return Converter.correctList<Map>(data);
      }
      else{
        AppSnack.showInfo(context, 'متاسفانه انجام نشد');
      }
    }

    return null;
  }

  void requestSendTicket({List<String>? attachments}){
    FocusHelper.hideKeyboardByUnFocusRoot();


    requester.httpRequestEvents.onFailState = (req, res) async {
      hideLoading();

      String msg = 'خطایی اتفاق افتاده است';

      if(res != null && res.data != null){
        final js = JsonHelper.jsonToMap(res.data)!;
        msg = js['message'];
      }

      AppSheet.showSheetOk(context, msg);
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      hideLoading();

      final data = res['data'];
      final id = data['id'];
      final number = data['number']?? 0;

      final tik = TicketModel();
      tik.id = id;
      tik.number = number;
      tik.title = titleCtr.text.trim();
      tik.trackingRoleName = widget.ticketRoles.firstWhere((element) => element.id == selectedTicketRoleId).name;
      tik.createdAt = DateHelper.getNowAsUtcZ();

      DataNotifierService.notify(AppBroadcast.addTicketNotifier, tik);

      final message = res['message']?? 'تیکت ثبت شد';

      AppSheet.showSheetOneAction(context, message, builder: (){RouteTools.popTopView(context: context);},
        buttonText:  'بله',
        dismissOnAction: true,
      );
    };

    final title = titleCtr.text.trim();
    final description = descriptionCtr.text.trim();

    final body = <String, dynamic>{};
    body['title'] = title;
    body['trackingRoleId'] = selectedTicketRoleId;
    body['description'] = description;

    if(attachments != null) {
      body['attachmentIds'] = attachments;
    }

    showLoading();
    requester.methodType = MethodType.post;
    requester.prepareUrl(pathUrl: '/tickets/add');
    requester.bodyJson = body;
    requester.request(context);
  }
}
