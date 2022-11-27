import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/models/ticketRole.dart';
import 'package:app/system/requester.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/views/widgets/customCard.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

class AddTicketPage extends StatefulWidget {
  final List<TicketRole> ticketRoles;

  const AddTicketPage({
    required this.ticketRoles,
    Key? key,
  }) : super(key: key);

  @override
  State<AddTicketPage> createState() => _AddTicketPageState();
}
///==================================================================================================
class _AddTicketPageState extends StateBase<AddTicketPage> {
  Requester requester = Requester();
  TextEditingController titleCtr = TextEditingController();
  TextEditingController descriptionCtr = TextEditingController();
  String selectedTicketRoleId = '';
  List<DropdownMenuItem<String>> dropList = [];
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
                                        assistCtr.updateMain();
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
                              ElevatedButton(
                                  onPressed: requestSendTicket,
                                  child: Text('ارسال')
                              )
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

  void requestSendTicket(){
    FocusHelper.hideKeyboardByUnFocusRoot();

    final body = <String, dynamic>{};
    body['title'] = titleCtr.text.trim();
    body['trackingRoleId'] = selectedTicketRoleId;
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
    requester.debug = true;
    requester.request(context);
  }
}
