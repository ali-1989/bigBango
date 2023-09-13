import 'package:flutter/material.dart';

import 'package:animator/animator.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/customCard.dart';

import 'package:app/services/audio_player_service.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/enums/assist_groups.dart';
import 'package:app/structures/models/vocabModels/clickableVocabModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_toast.dart';
import 'package:app/tools/route_tools.dart';

class VocabClickableComponent extends StatefulWidget {
  final ClickableVocabModel clickableVocabModel;

  const VocabClickableComponent({
    required this.clickableVocabModel,
    Key? key
  }) : super(key: key);

  @override
  State<VocabClickableComponent> createState() => _VocabClickableComponentState();
}
///====================================================================================
class _VocabClickableComponentState extends StateSuper<VocabClickableComponent> {
  late ClickableVocabModel vocabModel;
  String id$usVoicePlayerSectionId = 'usVoicePlayerSectionId';
  String id$ukVoicePlayerSectionId = 'ukVoicePlayerSectionId';
  String? voiceUrl;
  String selectedPlayerId = '';

  @override
  void initState(){
    super.initState();

    vocabModel = widget.clickableVocabModel;
  }

  @override
  void dispose(){
    if(assistCtr.getValueOr('play', false)){
      AudioPlayerService.stopPlayer();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 18, 8, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(vocabModel.word).bold(),
                    SizedBox(width: 10),
                    Text('[${vocabModel.pronunciation}]').englishFont(),

                    SizedBox(width: 20),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: (){
                            selectedPlayerId = id$usVoicePlayerSectionId;
                            voiceUrl = vocabModel.americanVoice?.fileLocation;
                            playSound(id$usVoicePlayerSectionId);
                          },
                          child: Assist(
                            controller: assistCtr,
                            id: id$usVoicePlayerSectionId,
                            groupIds: [AppAssistKeys.voicePlayerGroupId$vocabClickable],
                            builder: (_, ctr, data){
                              return AnimateWidget(
                                resetOnRebuild: true,
                                triggerOnRebuild: true,
                                duration: Duration(milliseconds: 500),
                                cycles: data == 'prepare' ? 100 : 1,
                                builder: (_, animate){
                                  Color color = Colors.grey.shade200;
                                  if(data == 'prepare'){
                                    color = animate.fromTween((v) => ColorTween(begin: AppDecoration.red, end: AppDecoration.red.withAlpha(50)))!;
                                  }
                                  else if(data == 'play'){
                                    color = AppDecoration.red;
                                  }

                                  return CustomCard(
                                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 7),
                                    color: color,
                                    child: Column(
                                      children: [
                                        Image.asset(AppImages.speaker2Ico, height: 16, width: 20),
                                        SizedBox(height: 3),
                                        Text('US', style: TextStyle(fontSize: 9))
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),

                        SizedBox(width: 10),

                        GestureDetector(
                          onTap: (){
                            selectedPlayerId = id$ukVoicePlayerSectionId;
                            voiceUrl = vocabModel.britishVoice?.fileLocation;

                            playSound(id$ukVoicePlayerSectionId);
                          },
                          child: Assist(
                            controller: assistCtr,
                            id: id$ukVoicePlayerSectionId,
                            groupIds: [AppAssistKeys.voicePlayerGroupId$vocabClickable],
                            builder: (_, ctr, data){
                              return AnimateWidget(
                                resetOnRebuild: true,
                                triggerOnRebuild: true,
                                duration: Duration(milliseconds: 500),
                                cycles: data == 'prepare' ? 100 : 1,
                                builder: (_, animate){
                                  Color color = Colors.grey.shade200;
                                  if(data == 'prepare'){
                                    color = animate.fromTween((v) => ColorTween(begin: AppDecoration.red, end: AppDecoration.red.withAlpha(50)))!;
                                  }
                                  else if(data == 'play'){
                                    color = AppDecoration.red;
                                  }

                                  return CustomCard(
                                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 7),
                                      color: color,
                                      child: Column(
                                        children: [
                                          Image.asset(AppImages.speaker2Ico, height: 16, width: 20),
                                          SizedBox(height: 3),
                                          Text('UK', style: TextStyle(fontSize: 9),)
                                        ],
                                      )
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),

                SizedBox(height: 10),
                Text(vocabModel.descriptions),

                SizedBox(height: 10),
                Text(vocabModel.translation),

                Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    style: IconButton.styleFrom(
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity(horizontal: -4, vertical: -4)
                    ),
                    onPressed: (){RouteTools.popTopView(context: context);},
                    icon: Icon(AppIcons.close, color: Colors.red, size: 14,),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void playSound(String sectionId){
    if(voiceUrl == null){
      AppToast.showToast(context, 'صدایی ثبت نشده');
      return;
    }

    assistCtr.updateGroup(AppAssistKeys.voicePlayerGroupId$vocabClickable, stateData: null);
    assistCtr.updateAssist(sectionId, stateData: 'prepare');

    AudioPlayerService.getPlayerWithUrl(voiceUrl!).then((twoState) async {
      if(sectionId != selectedPlayerId){
        return;
      }

      if(twoState.hasResult1()){
        assistCtr.setKeyValue('play', true);
        assistCtr.updateAssist(sectionId, stateData: 'play');

        await twoState.result1!.play();

        assistCtr.setKeyValue('play', false);
        assistCtr.updateAssist(sectionId, stateData: null);
        twoState.result1!.stop();
      }
      else {
        AppToast.showToast(context, 'متاسفانه امکان پخش صدا نیست');
      }
    });
  }

}
