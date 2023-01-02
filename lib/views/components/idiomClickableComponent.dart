import 'package:app/structures/models/vocabModels/idiomModel.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/system/extensions.dart';
import 'package:flutter/material.dart';

class IdiomClickableComponent extends StatefulWidget {
  final IdiomModel idiomModel;

  const IdiomClickableComponent({
    required this.idiomModel,
    Key? key
  }) : super(key: key);

  @override
  State<IdiomClickableComponent> createState() => _IdiomClickableComponentState();
}
///====================================================================================
class _IdiomClickableComponentState extends State<IdiomClickableComponent> {
  late IdiomModel idiomModel;


  @override
  void initState(){
    super.initState();

    idiomModel = widget.idiomModel;
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
                    Text(idiomModel.content).bold(),
                  ],
                ),

                SizedBox(height: 10),
                Text(idiomModel.translation),

                Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    style: IconButton.styleFrom(
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity(horizontal: -4, vertical: -4)
                    ),
                    onPressed: (){AppRoute.popTopView(context);},
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
}
