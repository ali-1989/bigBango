import 'package:iris_tools/modules/stateManagers/assist.dart';

enum AssistGroup implements GroupId {
  updateOnLessonChange(100),
  voicePlayerGroupId$vocabPage(110),
  voicePlayerGroupId$vocabClickable(120);

  final int _number;

  const AssistGroup(this._number);

  int getNumber(){
    return _number;
  }
}
