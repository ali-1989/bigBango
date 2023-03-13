import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/managers/systemParameterManager.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/courseLevelModel.dart';
import 'package:app/structures/models/userModel.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appSnack.dart';

class ChangeLanguageLevelSheet extends StatefulWidget {
  const ChangeLanguageLevelSheet({Key? key}) : super(key: key);

  @override
  State<ChangeLanguageLevelSheet> createState() => _ChangeLanguageLevelSheetState();
}
///=========================================================================================================
class _ChangeLanguageLevelSheetState extends StateBase<ChangeLanguageLevelSheet> {
  CourseLevelModel? selectedLevel;
  Requester requester = Requester();
  UserModel? user;

  @override
  void initState(){
    super.initState();

    user = Session.getLastLoginUser();

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
                      Text(AppMessages.selectLevelTitle, style: const TextStyle(fontSize: 18)),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Text(AppMessages.selectLanguageLevelDescription1, textAlign: TextAlign.center,
                        style: const TextStyle(height: 1.4)
                    ),
                  ),

                  const SizedBox(height: 25),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 17),
                      child: ListView(
                        children: [
                          SizedBox(
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
                                    Text(AppMessages.selectLevelTerm1, style: TextStyle(color: AppColors.red)),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 25),

                          ...buildChoice(),

                          const SizedBox(height: 30),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                onPressed: sendClick,
                                child: Text(AppMessages.send)
                            ),
                          ),

                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              )
          ),
        );
      },
    );
  }

  List<Widget> buildChoice(){
    List<Widget> res = [];

    for(final k in SystemParameterManager.systemParameters.courseLevels){
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
                RichText(
                  text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'سطح ',
                          style: TextStyle(color: Colors.black),
                        ),

                        TextSpan(
                          text: k.name,
                          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
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
      AppSnack.showSnack$OperationFailed(context);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      final user = Session.getLastLoginUser()!;
      user.courseLevel = selectedLevel;
      await Session.sinkUserInfo(user);
      AppSnack.showSnack$operationSuccess(context);

      AppBroadcast.reBuildMaterial();
      AppBroadcast.homePageKey.currentState?.requestLessons();
      AppBroadcast.homePageKey.currentState?.assistCtr.updateHead();

      Future.delayed(Duration(seconds: 1), (){
        AppRoute.popTopView(context: context);
      });
    };

    requester.bodyJson = {'courseLevelId' : selectedLevel!.id};
    requester.prepareUrl(pathUrl: '/profile/update');
    requester.methodType = MethodType.put;

    showLoading();
    requester.request(context, false);
  }
}
