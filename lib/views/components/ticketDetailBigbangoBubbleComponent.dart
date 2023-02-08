import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/localeHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/irisImageView.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/abstract/ticketAttachmentShowSupper.dart';
import 'package:app/structures/injectors/ticketDetailUserBubbleInjector.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/dateTools.dart';

class TicketDetailBigbangoBubbleComponent extends StatefulWidget {
  final TicketDetailBubbleInjector injector;

  const TicketDetailBigbangoBubbleComponent({
    required this.injector,
    Key? key
  }) : super(key: key);

  @override
  State<TicketDetailBigbangoBubbleComponent> createState() => TicketDetailBigbangoBubbleComponentState();
}
///=================================================================================================================
class TicketDetailBigbangoBubbleComponentState extends StateBase<TicketDetailBigbangoBubbleComponent> with TicketAttachmentShowSupper  {
  late Radius radius;
  late Radius radius2;

  @override
  void initState(){
    super.initState();

    radius = Radius.circular(12);
    radius2 = Radius.circular(11);
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
    return Align(
      alignment: Alignment.topLeft,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: DecoratedBox(
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(topRight: radius, bottomLeft: radius, bottomRight: radius),
                side: BorderSide(color: Colors.black, width: 0.8)
              )
            ),
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: ClipRRect(
                borderRadius: BorderRadius.only(topRight: radius2, bottomLeft: radius2, bottomRight: radius2),
                child: ColoredBox(
                  color: Colors.grey.shade100,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8.0),
                    child: IntrinsicWidth(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(width: 5),
                              Image.asset(AppImages.bigbangoTicket),
                              SizedBox(width: 12),
                              Text(DateTools.dateAndHmRelative(widget.injector.ticketReply.createdAt)).alpha(),

                              Visibility(
                                visible: widget.injector.ticketReply.attachments.isNotEmpty,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(width: 8),
                                    IconButton(
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
                                  ],
                                ),
                              ),
                            ],
                          ),

                          Align(
                            alignment: LocaleHelper.detectDirection(widget.injector.ticketReply.description) == TextDirection.rtl
                                ? Alignment.centerRight : Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(left: 5, right: 5, top: 10 ),
                              child: Text(widget.injector.ticketReply.description),
                            ),
                          ),
                        ],
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


}


