import 'dart:io';

import 'package:flutter/material.dart';

import 'package:iris_tools/api/converter.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/custom_card.dart';
import 'package:iris_tools/widgets/icon/circular_icon.dart';

import 'package:app/services/file_upload_service.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/enums/fileUploadType.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/ticketModels/ticketDetailModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/app/app_sheet.dart';
import 'package:app/tools/app/app_snack.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/views/components/attachmentFileTicketComponent.dart';

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
class _ReplyTicketSheetState extends StateSuper<ReplyTicketSheet> {
  Requester requester = Requester();
  TextEditingController descriptionCtr = TextEditingController();
  List<File> attachmentFiles = <File>[];
  List<String> attachmentIdsList = [];

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
                        const Row(
                          children: [
                            Icon(AppIcons.addCircle, color: AppDecoration.red),
                            SizedBox(width: 6),
                            Text('پاسخ تیکت', style: TextStyle(fontWeight: FontWeight.w700)),
                          ],
                        ),

                        GestureDetector(
                          onTap: (){
                            RouteTools.popTopView(context: context);
                          },
                          child: CustomCard(
                              color: Colors.grey.shade200,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                              radius: 5,
                              child: const Icon(AppIcons.close, size: 14)
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: descriptionCtr,
                      minLines: 8,
                      maxLines: 8,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                        isDense: true,
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                    ).wrapDotBorder(
                      padding: EdgeInsets.zero,
                      color: Colors.black,
                      alpha: 200,
                    ),

                    const SizedBox(height: 15),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('تعداد فایل ها: ${attachmentFiles.length}').thinFont().fsR(-2),

                        GestureDetector(
                          onTap: showAttachmentDialog,
                          child: const CircularIcon(
                            icon: AppIcons.add,
                            backColor: AppDecoration.mainColor,
                            size: 30,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),
                    Row(
                      children: [
                        /*ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14)
                          ),
                          icon: const Icon(AppIcons.attach, size: 16),
                            onPressed: showAttachmentDialog,
                            label: const Text('فایل ها').bold(weight: FontWeight.normal)
                        ),*/

                        Expanded(
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14)
                              ),
                              onPressed: sendClick,
                              child: const Text('ارسال').bold(weight: FontWeight.normal)
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
        attachmentIdsList = files.map<String>((e) => e['file']['id']).toList();//fileLocation
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
      body['attachmentIds'] = attachments;
    }

    requester.httpRequestEvents.onFailState = (req, res) async {
      hideLoading();

      String msg = 'خطایی اتفاق افتاده است';

      if(res != null && res.data != null){
        final js = JsonHelper.jsonToMap(res.data)!;
        msg = js['message']?? msg;
      }

      AppSheet.showSheetOk(context, msg);
    };

    requester.httpRequestEvents.onStatusOk = (req, res) async {
      hideLoading();

      attachmentIdsList.clear();

      final message = res['message']?? 'تیکت ثبت شد';

      AppSheet.showSheetOneAction(context, message, onButton: (){RouteTools.popTopView(context: context, data: true);},
        buttonText:  'بله',
        dismissOnAction: true,
      );
    };

    showLoading();
    requester.methodType = MethodType.post;
    requester.prepareUrl(pathUrl: '/tickets/reply');
    requester.bodyJson = body;
    requester.request();
  }
}
