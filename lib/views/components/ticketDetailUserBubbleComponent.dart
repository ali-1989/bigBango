
import 'package:app/structures/injectors/ticketDetailUserBubbleInjector.dart';
import 'package:app/tools/app/appIcons.dart';

import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:iris_tools/widgets/icon/circularIcon.dart';


class TicketDetailUserBubbleComponent extends StatefulWidget {
  final TicketDetailUserBubbleInjector injector;

  const TicketDetailUserBubbleComponent({
    required this.injector,
    Key? key
  }) : super(key: key);

  @override
  State<TicketDetailUserBubbleComponent> createState() => TicketDetailUserBubbleComponentState();
}
///=================================================================================================================
class TicketDetailUserBubbleComponentState extends StateBase<TicketDetailUserBubbleComponent> {
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
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Stack(
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Icon(AppIcons.calendar, size: 13),
                    SizedBox(width: 8,),
                    Text('20223/01/02  7:20'),

                  ],
                ),

                SizedBox(height: 3),

                ClipRRect(
                  borderRadius: BorderRadius.only(topLeft: radius, bottomLeft: radius, bottomRight: radius),
                  child: ColoredBox(
                    color: Colors.grey.shade100,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(10, 26, 10, 14),
                      child: Text('ali ali ali ali ali ali ali ali ali ali ali ali ali ali ali ali ali ali ali ali ali ali ali ali '),
                    ),
                  ),
                ),
              ],
            ),

            Positioned(
              top: 0,
                right: 18,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey.shade100,
                  child: ClipOval(
                    child: ColoredBox(
                      color: Colors.white,
                      child: SizedBox(
                        width: 33,
                          height: 33,
                          child: Icon(AppIcons.email, size: 15,)
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


