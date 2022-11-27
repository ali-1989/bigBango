import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';


class ChangeLevel extends StatefulWidget {
  const ChangeLevel({Key? key}) : super(key: key);

  @override
  State<ChangeLevel> createState() => _ChangeLevelState();
}
///=========================================================================================================
class _ChangeLevelState extends StateBase<ChangeLevel> {
  int selectValue = 0;

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
      builder: (ctx, ctr, data){
        return Scaffold(
          backgroundColor: Colors.white,
          body: SizedBox.expand(
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
                    child: Text(AppMessages.selectLevelDescription, textAlign: TextAlign.center, style: const TextStyle(height: 1.4)),
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

                          GestureDetector(
                            onTap: (){
                              selectValue = 0;
                              assistCtr.updateMain();
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
                                          if(selectValue == 0){
                                            return getSelectedBox();
                                          }

                                          return getEmptyBox();
                                        }
                                    ),
                                    const SizedBox(width: 18),
                                    RichText(
                                      text: const TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'سطح ',
                                              style: TextStyle(color: Colors.black),
                                            ),

                                            TextSpan(
                                              text: 'پایه',
                                              style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
                                            ),
                                          ]
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                            ),
                          ),

                          GestureDetector(
                            onTap: (){
                              selectValue = 1;
                              assistCtr.updateMain();
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
                                          if(selectValue == 1){
                                            return getSelectedBox();
                                          }

                                          return getEmptyBox();
                                        }
                                    ),

                                    const SizedBox(width: 18),
                                    RichText(
                                      text: const TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'سطح ',
                                              style: TextStyle(color: Colors.black),
                                            ),

                                            TextSpan(
                                              text: 'مبتدی',
                                              style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
                                            ),
                                          ]
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          GestureDetector(
                            onTap: (){
                              selectValue = 2;
                              assistCtr.updateMain();
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
                                          if(selectValue == 2){
                                            return getSelectedBox();
                                          }

                                          return getEmptyBox();
                                        }
                                    ),

                                    const SizedBox(width: 18),
                                    RichText(
                                      text: const TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'سطح ',
                                              style: TextStyle(color: Colors.black),
                                            ),

                                            TextSpan(
                                              text: 'متوسط',
                                              style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
                                            ),
                                          ]
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          GestureDetector(
                            onTap: (){
                              selectValue = 3;
                              assistCtr.updateMain();
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
                                          if(selectValue == 3){
                                            return getSelectedBox();
                                          }

                                          return getEmptyBox();
                                        }
                                    ),

                                    const SizedBox(width: 18),
                                    RichText(
                                      text: const TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'سطح ',
                                              style: TextStyle(color: Colors.black),
                                            ),

                                            TextSpan(
                                              text: 'پیشرفته',
                                              style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
                                            ),
                                          ]
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

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

  Widget getEmptyBox(){
    return Image.asset(AppImages.emptyBoxIco);
  }

  Widget getSelectedBox(){
    return Image.asset(AppImages.selectLevelIco);
  }

  void sendClick(){}

}