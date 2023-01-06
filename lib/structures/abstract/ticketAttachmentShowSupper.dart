import 'package:app/structures/models/ticketModels/ticketReplyModel.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/tools/app/appSizes.dart';
import 'package:app/system/extensions.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/widgets/irisImageView.dart';

abstract class TicketAttachmentShowSupper {

  void showAttachment(BuildContext context, TicketReplyModel ticketReply) {
    AppSheet.showSheetCustom(
        context,
        builder: (ctx) => attachmentView(ctx, ticketReply),
        routeName: 'attachment',
      contentColor: Colors.white,
      isScrollControlled: true,
    );
  }

  Widget attachmentView(BuildContext context, TicketReplyModel ticketReply){

    return SizedBox(
      height: AppSizes.getScreenHeight(context) * 3/4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Center(
                child: Text('پیوست ها').bold().fsR(2)
            ),
            SizedBox(height: 14),
            Divider(),
            SizedBox(height: 10),


            Expanded(
              child: ListView.builder(
                itemCount: ticketReply.attachments.length,
                itemBuilder: (_, idx){
                  return listBuilder(_, idx, ticketReply);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget listBuilder(_, idx, TicketReplyModel ticketReply){
    final itm = ticketReply.attachments[idx];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: ColoredBox(
          color: Colors.grey.shade200,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Builder(
                builder: (__){
                  if(itm.fileType == 1){
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: IrisImageView(
                        url: itm.fileLocation,
                        beforeLoadWidget: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: 120),
                          child: Center(
                            child: SizedBox(
                                width: 50,
                                height: 50,
                                child: CircularProgressIndicator()
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return Icon(Icons.broken_image);
                }
            ),
          ),
        ),
      ),
    );
  }
}