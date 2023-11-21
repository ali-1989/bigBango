import 'package:flutter/material.dart';

import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/managers/settings_manager.dart';
import 'package:app/services/session_service.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/enums/app_events.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/courseLevelModel.dart';
import 'package:app/structures/models/user_model.dart';
import 'package:app/tools/app/app_broadcast.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_snack.dart';
import 'package:app/tools/route_tools.dart';

class ChangeLanguageLevelSheet extends StatefulWidget {
  const ChangeLanguageLevelSheet({Key? key}) : super(key: key);

  @override
  State<ChangeLanguageLevelSheet> createState() => _ChangeLanguageLevelSheetState();
}
///=========================================================================================================
class _ChangeLanguageLevelSheetState extends StateSuper<ChangeLanguageLevelSheet> {
  CourseLevelModel? selectedLevel;
  Requester requester = Requester();
  UserModel? user;

  @override
  void initState(){
    super.initState();

    user = SessionService.getLastLoginUser();

    if(user != null && user!.courseLevel != null){
      selectedLevel = user!.courseLevel;
    }
  }

  @override
  void dispose(){
    super.dispose();

    requester.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
      builder: (ctx, ctr, data){
        return Material(
          color: Colors.transparent,
          child: SizedBox.expand(
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(AppImages.selectLevelIco2),
                      const SizedBox(width: 8),
                      Text('تغییر سطح', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
                    ],
                  ),

                  //const SizedBox(height: 20),
                  /*Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Text(AppMessages.selectLanguageLevelDescription1, textAlign: TextAlign.center,
                        style: const TextStyle(height: 1.4)
                    ),
                  ),*/

                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: Card(
                        color: ColorHelper.getColorFromHex('#FEEFE9'),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 13),
                          child: Row(
                            children: [
                              Image.asset(AppImages.atentionIco),
                              const SizedBox(width: 12),
                              Text(AppMessages.selectLevelTerm1, style: const TextStyle(color: AppDecoration.red)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 17),
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: ListView(
                          children: [

                            const SizedBox(height: 25),

                            ...buildChoice(),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          onPressed: sendClick,
                          child: Text(AppMessages.register)
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),
                ],
              )
          ),
        );
      },
    );
  }

  List<Widget> buildChoice(){
    List<Widget> res = [];

    for(final k in SettingsManager.globalSettings.courseLevels){
      final itm = GestureDetector(
        onTap: (){
          selectedLevel = k;
          assistCtr.updateHead();
        },
        child: Card(
          color: Colors.grey.shade100,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 13),
            child: Row(
              children: [
                Builder(
                    builder: (ctx){
                      if(selectedLevel == k){
                        return getSelectedBox();
                      }

                      return getEmptyBox();
                    }
                ),
                const SizedBox(width: 18),
                Text.rich(
                   TextSpan(
                      children: [
                        const TextSpan(
                          text: 'سطح ',
                          style: TextStyle(color: Colors.black),
                        ),

                        TextSpan(
                          text: k.name,
                          style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
                        ),
                      ]
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      res.add(itm);
    }

    return res;
  }

 Widget getEmptyBox(){
    return Image.asset(AppImages.emptyBoxIco);
  }

  Widget getSelectedBox(){
    return Image.asset(AppImages.selectLevelIco);
  }

  void sendClick(){
    requester.httpRequestEvents.onAnyState = (req) async {
      await hideLoading();
    };

    requester.httpRequestEvents.onFailState = (req, data) async {
      AppSnack.showSnackText(context, AppMessages.operationFailed);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      final user = SessionService.getLastLoginUser()!;
      user.courseLevel = selectedLevel;
      await SessionService.sinkUserInfo(user);
      AppSnack.showSnackText(context, AppMessages.operationSuccess);

      AppBroadcast.reBuildMaterial();
      AppBroadcast.homePageKey.currentState?.requestLessons();
      AppBroadcast.homePageKey.currentState?.assistCtr.updateHead();

      Future.delayed(const Duration(seconds: 1), (){
        EventNotifierService.notify(AppEvents.languageLevelChanged);
        if(mounted) {
          RouteTools.popTopView(context: context);
        }
      });
    };

    requester.bodyJson = {'courseLevelId' : selectedLevel!.id};
    requester.prepareUrl(pathUrl: '/profile/update');
    requester.methodType = MethodType.put;

    showLoading();
    requester.request();
  }
}
