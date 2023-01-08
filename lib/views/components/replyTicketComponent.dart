import 'dart:io';

import 'package:app/pages/support_page.dart';
import 'package:app/services/pages_event_service.dart';
import 'package:app/structures/models/ticketModels/ticketDetailModel.dart';
import 'package:app/structures/models/ticketModels/ticketModel.dart';
import 'package:app/views/components/attachmentFileTicketComponent.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/middleWare/requester.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/system/extensions.dart';
import 'package:app/views/widgets/customCard.dart';

class ReplyTicketComponent extends StatefulWidget {
  final TicketDetailModel ticketDetailModel;

  const ReplyTicketComponent({
    required this.ticketDetailModel,
    Key? key,
  }) : super(key: key);

  @override
  State<ReplyTicketComponent> createState() => _ReplyTicketComponentState();
}
///==================================================================================================
class _ReplyTicketComponentState extends StateBase<ReplyTicketComponent> {
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
                              onPressed: requestSendTicket,
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

  void requestSendTicket(){
    FocusHelper.hideKeyboardByUnFocusRoot();

    final body = <String, dynamic>{};
    body['description'] = descriptionCtr.text.trim();
    //body['attachments'] = ;

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
