
import 'package:app/structures/abstract/ticketAttachmentShowSupper.dart';
import 'package:app/structures/enums/enums.dart';
import 'package:app/structures/injectors/ticketDetailUserBubbleInjector.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appDirectories.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/dateTools.dart';

import 'package:flutter/material.dart';
import 'package:iris_tools/api/helpers/localeHelper.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/system/extensions.dart';
import 'package:iris_tools/widgets/irisImageView.dart';


class TicketDetailUserBubbleComponent extends StatefulWidget {
  final TicketDetailBubbleInjector injector;

  const TicketDetailUserBubbleComponent({
    required this.injector,
    Key? key
  }) : super(key: key);

  @override
  State<TicketDetailUserBubbleComponent> createState() => TicketDetailUserBubbleComponentState();
}
///=================================================================================================================
class TicketDetailUserBubbleComponentState extends StateBase<TicketDetailUserBubbleComponent> with TicketAttachmentShowSupper  {
  late Radius radius;

  @override
  void initState(){
    super.initState();

    radius = Radius.circular(12);
  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
        builder: (ctx, ctr, data){
          return buildBody();
        }
    );
  }

  Widget buildBody(){
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  //mainAxisSize: MainAxisSize.min,  for date and time position
                  children: [
                    Icon(AppIcons.calendar, size: 13).alpha(),
                    SizedBox(width: 8),
                    Text(DateTools.dateAndHmRelative(widget.injector.ticketReply.createdAt)).alpha(),
                    SizedBox(width: 8),

                    Visibility(
                      visible: widget.injector.ticketReply.attachments.isNotEmpty,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 17,
                        splashRadius: 14,
                        constraints: BoxConstraints.tightFor(),
                        visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                          onPressed: (){
                            showAttachment(context, widget.injector.ticketReply);
                          },
                          icon: Icon(AppIcons.attach, size: 17, color: AppColors.red),
                      ),
                    ),
                    SizedBox(width: 60),
                  ],
                ),

                SizedBox(height: 3),

                ClipRRect(
                  borderRadius: BorderRadius.only(topLeft: radius, bottomLeft: radius, bottomRight: radius),
                  child: ColoredBox(
                    color: Colors.grey.shade100,
                    child: ConstrainedBox(
                      //constraints: BoxConstraints.tightFor(width: 70), if need bubble be small
                      constraints: BoxConstraints.tightFor(width: sw),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(10, 26, 10, 14),
                        child: Text(widget.injector.ticketReply.description,
                          textDirection: LocaleHelper.autoDirection(widget.injector.ticketReply.description),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            /// avatar
            Positioned(
                top: 0,
                right: 15,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey.shade100,
                  child: ClipOval(
                    child: ColoredBox(
                      color: Colors.white,
                      child: SizedBox(
                          width: 33,
                          height: 33,
                          child: Builder(
                            builder: (context) {
                              if(widget.injector.ticketReply.creator.hasAvatar()) {
                                return IrisImageView(
                                  url: widget.injector.ticketReply.creator.avatar!.fileLocation,
                                  imagePath: AppDirectories.getSavePathUri(widget.injector.ticketReply.creator.avatar!.fileLocation, SavePathType.userProfile, null),
                                  beforeLoadWidget: Icon(AppIcons.personLogin, size: 17),
                                );
                              }

                              return Icon(AppIcons.personLogin, size: 17);
                            }
                          )
                      ),
                    ),
                  ),
                )
            )
          ],
        ),
      ),
    );
  }


}


