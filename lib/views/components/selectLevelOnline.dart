import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:flutter/material.dart';


class SelectLevelOnline extends StatefulWidget {
  const SelectLevelOnline({Key? key}) : super(key: key);

  @override
  State<SelectLevelOnline> createState() => _SelectLevelOnlineState();
}
///=========================================================================================================
class _SelectLevelOnlineState extends StateBase<SelectLevelOnline> {
  int currentQuestion = 0;


  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(AppImages.selectLevelIco3),
                  const SizedBox(width: 10),
                  Text(AppMessages.selectLevelOnline, style: const TextStyle(fontSize: 17)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(AppMessages.selectLevelDescription, textAlign: TextAlign.start, style: const TextStyle(height: 1.4)),
          ),

          const SizedBox(height: 25),
          SizedBox(
            height: 0.5,
            width: double.infinity,
            child: ColoredBox(color: Colors.black.withAlpha(120)),
          ),

          const SizedBox(height: 17),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(' 20   /',
                      style: TextStyle(fontSize: 15)
                  ),

                  const SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: ColoredBox(
                      color: Colors.grey[200]!,
                      child: const SizedBox(
                        width: 25,
                        height: 25,
                        child: Center(
                          child: Text('1',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Text(AppMessages.chooseTheCorrectAnswer,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
              ),
            ],
          ),

          const SizedBox(height: 12),
          Directionality(
            textDirection: TextDirection.ltr,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                backgroundColor: Colors.red.withAlpha(30),
                color: AppColors.red,
                value: 0.5,
                minHeight: 5,
              ),
            ),
          ),

          Expanded(
              child: SizedBox(),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal:10.0, vertical: 14),
                child: Row(
                  children: [
                    TextButton.icon(
                        onPressed: (){
                          Session.getLastLoginUser()?.courseLevelId = 0;
                          AppBroadcast.reBuildMaterial();
                        },
                        icon: Image.asset(AppImages.arrowRightIco),
                        label: Text('Next', style: TextStyle(fontSize: 14))
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal:10.0, vertical: 14),
                child: Row(
                  children: [
                    Text('Prev', style: TextStyle(fontSize: 14),),
                    Image.asset(AppImages.arrowLeftIco),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

}

/*
* SizedBox(
                width: 110,
                child: ElevatedButton(
                    onPressed: null,
                    child: Text(AppMessages.register),
                ),
              ),*/