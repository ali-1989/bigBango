import 'dart:io';

import 'package:flutter/material.dart';

import 'package:iris_tools/api/converter.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/services/file_upload_service.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/enums/fileUploadType.dart';
import 'package:app/structures/middleWare/requester.dart';
import 'package:app/structures/models/ticketModels/ticketDetailModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/tools/app/appSnack.dart';
import 'package:app/views/components/attachmentFileTicketComponent.dart';
import 'package:app/views/widgets/customCard.dart';

class ReplyTicketSheet extends StatefulWidget {
  final TicketDetailModel ticketDetailModel;

  const ReplyTicketSheet({
    required this.ticketDetailModel,
    Key? key,
  }) : super(key: key);

  @override
  State<ReplyTicketSheet> createState() => _ReplyTicketSheetState();
}
///==================================================================================================
class _ReplyTicketSheetState extends StateBase<ReplyTicketSheet> {
  Requester requester = Requester();
  TextEditingController descriptionCtr = TextEditingController();
  List<File> attachmentFiles = <File>[];

  @override
  void dispose(){
    requester.dispose();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
        controller: assistCtr,
        builder: (_, ctr, data) {

          return Padding(
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
                            Text('پاسخ تیکت', style: TextStyle(fontWeight: FontWeight.w700)),
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

                    SizedBox(height: 20),

                    TextField(
                      controller: descriptionCtr,
                      minLines: 5,
                      maxLines: 5,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                        isDense: true,
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                    ).wrapDotBorder(
                      padding: EdgeInsets.zero,
                      color: Colors.black,
                      alpha: 200,
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
                    )
                  ],
                ),
              ),
            ),
          );
        }
    );
  }

  void showAttachmentDialog(){
    AppSheet.showSheetCustom(
      context,
      builder: (ctx) => AttachmentFileTicketComponent(files: attachmentFiles),
      routeName: 'openNewReply',
      contentColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  void sendClick() async {
    if(attachmentFiles.isEmpty){
      requestSendTicket();
    }
    else {
      final files = await requestUploadFiles();

      if(files != null){
        requestSendTicket(attachments: files.map<String>((e) => e['file']['fileLocation']).toList());
      }
    }
  }

  Future<List<Map>?> requestUploadFiles() async {
    FocusHelper.hideKeyboardByUnFocusRoot();

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

    final body = <String, dynamic>{};
    body['ticketId'] = widget.ticketDetailModel.id;
    body['description'] = descriptionCtr.text.trim();

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

      //final data = res['data'];

      /*final trm = TicketReplyModel();
      trm.creator = widget.ticketDetailModel.firstTicket.creator;
      trm.description = ;
      trm.createdAt = DateHelper.getNowAsUtcZ();
      widget.ticketDetailModel.replies.add(trm);*/


      final message = res['message']?? 'تیکت ثبت شد';

      AppSheet.showSheetOneAction(context, message, (){AppRoute.popTopView(context, data: true);},
        buttonText:  'بله',
        dismissOnAction: true,
      );
    };

    showLoading();
    requester.methodType = MethodType.post;
    requester.prepareUrl(pathUrl: '/tickets/reply');
    requester.bodyJson = body;
    requester.request(context);
  }
}
