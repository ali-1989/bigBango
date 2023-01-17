import 'dart:async';
import 'dart:io';

import 'package:app/pages/support_page.dart';
import 'package:app/services/file_upload_service.dart';
import 'package:app/services/pages_event_service.dart';
import 'package:app/structures/enums/fileUploadType.dart';
import 'package:app/structures/models/ticketModels/ticketModel.dart';
import 'package:app/system/keys.dart';

import 'package:app/tools/app/appSnack.dart';
import 'package:app/tools/app/appToast.dart';
import 'package:app/views/components/attachmentFileTicketComponent.dart';
import 'package:flutter/material.dart';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:iris_tools/api/converter.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/middleWare/requester.dart';
import 'package:app/structures/models/ticketModels/ticketRole.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/system/extensions.dart';
import 'package:app/views/widgets/customCard.dart';

//todo.im
// بعد از ثبت  باید یک رکورد اضافه شود. اطلاعات بک اند ناقص است

class AddTicketComponent extends StatefulWidget {
  final List<TicketRole> ticketRoles;

  const AddTicketComponent({
    required this.ticketRoles,
    Key? key,
  }) : super(key: key);

  @override
  State<AddTicketComponent> createState() => _AddTicketComponentState();
}
///==================================================================================================
class _AddTicketComponentState extends StateBase<AddTicketComponent> {
  Requester requester = Requester();
  TextEditingController titleCtr = TextEditingController();
  TextEditingController descriptionCtr = TextEditingController();
  String selectedTicketRoleId = '';
  List<DropdownMenuItem<String>> dropList = [];
  List<File> attachmentFiles = <File>[];
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

    boldStyle = TextStyle(fontWeight: FontWeight.w700, fontSize: 11);

    inputDecoration = InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
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
                          Row(
                            children: [
                              Icon(AppIcons.addCircle, color: AppColors.red),
                              SizedBox(width: 6),
                              Text('ایجاد تیکت', style: TextStyle(fontWeight: FontWeight.w700)),
                            ],
                          ),

                          GestureDetector(
                            onTap: (){
                              AppRoute.popTopView(context);
                            },
                            child: CustomCard(
                                color: Colors.grey.shade200,
                                padding: EdgeInsets.symmetric(horizontal: 7, vertical: 6),
                                radius: 4,
                                child: Icon(AppIcons.close, size: 10)
                            ),
                          ),
                        ],
                      ),

                      Expanded(
                          child: ListView(
                            shrinkWrap: true,
                            children: [
                              SizedBox(height: 20),
                              Text('موضوع', style: boldStyle),
                              SizedBox(height: 5),

                              TextField(
                                controller: titleCtr,
                                decoration: inputDecoration,
                              ),

                              SizedBox(height: 10),
                              Text('بخش مربوطه', style: boldStyle),
                              SizedBox(height: 5),

                              DecoratedBox(
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(6)
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2<String>(
                                    items: dropList,
                                    value: selectedTicketRoleId,
                                    offset: Offset(0,0),
                                    buttonPadding: EdgeInsets.symmetric(horizontal: 5),
                                    itemHeight: 30,
                                    buttonHeight: 50,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedTicketRoleId = value as String;
                                        assistCtr.updateHead();
                                      });
                                    },
                                  ),
                                ),
                              ),

                              SizedBox(height: 10),
                              Text('توضیحات', style: boldStyle),
                              SizedBox(height: 5),

                              TextField(
                                controller: descriptionCtr,
                                minLines: 5,
                                maxLines: 5,
                                decoration: inputDecoration,
                              ),

                              SizedBox(height: 15),
                              Visibility(
                                visible: attachmentFiles.isNotEmpty,
                                  child: Text('تعداد فایل ها: ${attachmentFiles.length}').subFont().fsR(-2),
                              ),
                              SizedBox(height: 15),

                              Row(
                                children: [
                                  ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                      icon: Icon(AppIcons.attach),
                                      onPressed: showAttachmentDialog,
                                      label: Text('فایل ها')
                                  ),

                                  SizedBox(width: 10),

                                  Expanded(
                                    child: ElevatedButton(
                                        onPressed: sendClick,
                                        child: Text('ارسال')
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
    if(attachmentFiles.isEmpty){
      requestSendTicket();
    }
    else {
      final files = await requestUploadFiles();

      if(files != null){
        requestSendTicket(attachments: files.map<String>((e) => e['file']['id']).toList());
      }
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

    final title = titleCtr.text.trim();
    final description = descriptionCtr.text.trim();

    final body = <String, dynamic>{};
    body['title'] = title;
    body['trackingRoleId'] = selectedTicketRoleId;
    body['description'] = description;

    if(attachments != null) {
      body['attachments'] = attachments;
    }

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

      PagesEventService.getEventBus(SupportPage.pageEventId).callEvent(SupportPage.eventFnId$addTicket, tik);

      final message = res['message']?? 'تیکت ثبت شد';

      AppSheet.showSheetOneAction(context, message, (){AppRoute.popTopView(context);},
        buttonText:  'بله',
        dismissOnAction: true,
      );
    };

    showLoading();
    requester.methodType = MethodType.post;
    requester.prepareUrl(pathUrl: '/tickets/add');
    requester.bodyJson = body;
    requester.request(context);
  }
}