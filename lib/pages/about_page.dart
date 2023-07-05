import 'package:app/managers/settings_manager.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/urlHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/customCard.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appDecoration.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/views/components/backBtn.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:app/views/states/waitToLoad.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  State<AboutPage> createState() => _AboutPageState();
}
///==============================================================================================
class _AboutPageState extends StateBase<AboutPage> {
  Color backColor = const Color(0xFFFFDFD0);

  @override
  void initState(){
    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
        builder: (_, ctr, data){
          return Scaffold(
            body: buildBody(),
          );
        }
    );
  }

  Widget buildBody(){
    if(assistCtr.hasState(AssistController.state$loading)){
      return const WaitToLoad();
    }

    if(assistCtr.hasState(AssistController.state$error)){
      return ErrorOccur(backButton: const BackBtn());
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [backColor, backColor.withAlpha(100)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter
        )
      ),
      child: ListView(
        children: [
          const SizedBox(height: 10),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                ],
              ),

              RotatedBox(
                  quarterTurns: 2,
                  child: BackButton()
              ),
            ],
          ),

          //const SizedBox(height: 10),
          Image.asset(AppImages.bigbangoSmallText2, height: 40,),
          const SizedBox(height: 40),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomCard(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    radius: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: const Text('آشنایی بیشتر با ما').color(Colors.red),
                    )
                ),

                const Text('A  B  O  U  T   U  S').englishFont().alpha(alpha: 100).bold(weight: FontWeight.w400),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: CustomCard(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              radius: 0,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text('${SettingsManager.globalSettings.contact['description']}'),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CustomCard(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                        radius: 0,
                        child: Image.asset(AppImages.callUsIco)
                    ),

                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('شماره تماس'),
                        //SizedBox(height: 2),
                        TextButton(
                          style: TextButton.styleFrom(
                            visualDensity: const VisualDensity(horizontal: -4),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: EdgeInsets.zero,
                            foregroundColor: Colors.blueAccent.shade700,
                          ),
                            onPressed: (){
                             UrlHelper.launchLink('tel://${SettingsManager.globalSettings.contact['supportPhoneNumber']}');
                            },
                            child: Text('${SettingsManager.globalSettings.contact['supportPhoneNumber']}').bold(),
                        )
                      ],
                    ),
                  ],
                ),

                Row(
                  children: [
                    CustomCard(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    radius: 0,
                        child: Image.asset(AppImages.rulesIco)
                    ),

                    const SizedBox(width: 2),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blueAccent.shade700,
                      ),
                        onPressed: (){
                          UrlHelper.launchLink('${SettingsManager.globalSettings.contact['conditionTermsLink']}');//http://
                        },
                        child: const Text('مشاهده قوانین')
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
            child: Image.asset(AppImages.aboutUs),
          ),
        ],
      ),
    );
  }
}
