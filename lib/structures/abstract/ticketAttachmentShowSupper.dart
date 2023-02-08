import 'package:flutter/material.dart';

import 'package:iris_tools/widgets/irisImageView.dart';

import 'package:app/structures/enums/enums.dart';
import 'package:app/structures/models/ticketModels/ticketReplyModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appNavigator.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/tools/app/appSizes.dart';
import 'package:app/views/components/fullScreenImageComponent.dart';
import 'package:app/views/widgets/customCard.dart';

abstract class TicketAttachmentShowSupper {

  void showAttachment(BuildContext context, TicketReplyModel ticketReply) {
    AppSheet.showSheetCustom(
        context,
        builder: (ctx) => attachmentView(ctx, ticketReply),
        routeName: 'attachment',
      contentColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  Widget attachmentView(BuildContext context, TicketReplyModel ticketReply){

    return Card(
      margin: EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: SizedBox(
        height: AppSizes.getScreenHeight(context) * 3/4,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 22,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('پیوست ها').bold().fsR(2),
                      ],
                    ),
                  ),

                  Positioned(
                    left: 10,
                    child: GestureDetector(
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
                  ),
                ],
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
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: AspectRatio(
                          aspectRatio: 3/2,
                          child: Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: GestureDetector(
                                onTap: (){
                                  showFullScreen(itm.fileLocation!);
                                },
                                child: IrisImageView(
                                  url: itm.fileLocation,
                                  //imagePath: ,
                                  fit: BoxFit.contain,
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
                              ),
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

  void showFullScreen(String pathOrUrl) {
    final view = FullScreenImageComponent(
      heroTag: 'heroTag',
      imageObj: pathOrUrl,
      imageType: ImageType.network,
      appBarColor: Colors.black,
    );

    AppNavigator.pushNextPageExtra(AppRoute.getLastContext()!, view, name: FullScreenImageComponent.screenName);
  }
}
