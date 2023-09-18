import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/custom_card.dart';

import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/models/examModels/speakingModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/views/components/playVoiceView.dart';

class SpeakingCorrectAnswerSheet extends StatefulWidget {
  final SpeakingModel speakingModel;

  const SpeakingCorrectAnswerSheet({
    Key? key,
    required this.speakingModel,
  }) : super(key: key);

  @override
  State<SpeakingCorrectAnswerSheet> createState() => _SpeakingCorrectAnswerSheetState();
}
///==================================================================================================
class _SpeakingCorrectAnswerSheetState extends StateSuper<SpeakingCorrectAnswerSheet> {
  PlayVoiceController playController = PlayVoiceController();

  @override
  void dispose(){
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Assist(
        controller: assistCtr,
        builder: (_, ctr, data) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: CustomCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Column(
                  children: [
                    const Text('پاسخ صحیح').bold().fsR(4),
                    const SizedBox(height: 25),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: CustomCard(
                          padding: const EdgeInsets.all(5),
                          color: Colors.grey.shade200,
                          child: Row(
                            children: [
                              Expanded(
                                  child: PlayVoiceView(
                                      address: widget.speakingModel.correctAnswerVoice!.fileLocation!,
                                      controller: playController,
                                    isUrl: true,
                                  )
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).wrapDotBorder(
                        color: Colors.black,
                        alpha: 100,
                        dashPattern: [4,8]
                    ),

                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: (){
                            RouteTools.popTopView(context: context);
                          },
                          child: const Text('بستن')
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
    );
  }
}
