import 'package:app/structures/models/mediaModel.dart';
import 'package:app/system/extensions.dart';
import 'package:iris_tools/api/generator.dart';

import 'package:app/structures/enums/quizType.dart';
import 'package:app/structures/models/examModels/examSuperModel.dart';

class ExamModel extends ExamSuperModel {
  late String id;
  String? title;
  QuizType quizType = QuizType.unKnow;
  List<ExamItem> items = [];
  MediaModel? voice;
  MakeSentenceExtra? sentenceExtra;

  //----------- local
  bool showAnswer = false;
  bool isPrepare = false;

  ExamModel(this.id);

  ExamModel.fromMap(Map js){
    quizType = QuizType.fromType(js['exerciseType']);
    title = js['title'];

    if(js['items'] is List){
      items = js['items'].map<ExamItem>((e) => ExamItem.fromMap(e, quizType)).toList();
    }

    id = items[0].id;

    if(js['voice'] is Map) {
      voice = MediaModel.fromMap(js['voice']);
    }
  }

  Map<String, dynamic> toMap(){
    final js = <String, dynamic>{};

    js['id'] = id;
    js['title'] = title;
    js['exerciseType'] = quizType.number;
    js['items'] = items.map((e) => e.toMap()).toList();
    //js['solveItems'] = solvedOptions.map((e) => e.toMap()).toList();
    js['voice'] = voice?.toMap();

    return js;
  }

  ExamItem _getFirst(){
    return items[0];
  }

  ExamItem getExamItem(){
    return items[0];
  }

  void prepare(){
    if(quizType == QuizType.multipleChoice){
      _getFirst()._generateUserAnswer();
    }

    if(quizType == QuizType.recorder){
      _getFirst()._doSplitQuestion();

      _getFirst().shuffleWords = [..._getFirst().teacherOptions];
      _getFirst().shuffleWords.shuffle();
    }

    if(quizType == QuizType.fillInBlank){
      _getFirst()._doSplitQuestion();
    }

    if(quizType == QuizType.makeSentence){
      sentenceExtra = MakeSentenceExtra(items);
    }

    isPrepare = true;
  }

  @override
  String toString(){
    return '::ExamModel::[title:$title | quizType: ${quizType.name} | items:$items]';
  }
}
///==================================================================================================
class ExamItem {
  late String id;
  late String question;
  int order = 1;
  List<ExamOptionModel> teacherOptions = [];
  late QuizType quizType;
  //------- local
  List<ExamOptionModel> userAnswers = [];
  List<String> questionSplit = [];
  List<ExamOptionModel> shuffleWords = [];

  ExamItem(this.quizType);

  ExamItem.fromMap(Map js, this.quizType){
    id = js['id']?? '';
    question = js['question']?? '';
    order = js['order']?? 1;

    if(js['choices'] is List){
      teacherOptions = js['choices'].map<ExamOptionModel>((e) => ExamOptionModel.fromMap(e)).toList();
    }

    //----------- local
    if(js['userAnswers'] is List){
      userAnswers = js['userAnswers'].map<ExamOptionModel>((e) => ExamOptionModel.fromMap(e)).toList();
    }
  }

  Map<String, dynamic> toMap(){
    final js = <String, dynamic>{};

    js['id'] = id;
    js['question'] = question;
    js['order'] = order;
    js['choices'] = teacherOptions.map((e) => e.toMap()).toList();

    //----------- local
    js['userAnswers'] = userAnswers.map((e) => e.toMap()).toList();

    return js;
  }

  void _generateUserAnswer(){
    userAnswers.clear();
  }

  void _doSplitQuestion(){
    if(question.startsWith('**')){
      /// this trick used if question start with ** for correct splitting
      question = '\u2060$question';
    }

    questionSplit = question.split('**');
    userAnswers.clear();

    for(int i = 1; i < questionSplit.length; i++) {
      final ex = ExamOptionModel()..order = i;

      if(quizType == QuizType.multipleChoice){
        ex.id = '';
      }

      userAnswers.add(ex);
    }
  }

  int getIndexOfCorrectOption(){
    for(int i = 0; i< teacherOptions.length; i++){
      if(teacherOptions[i].isCorrect){
        return i;
      }
    }

    return -1;
  }

  ExamOptionModel? getCorrectOption(){
    for(int i = 0; i< teacherOptions.length; i++){
      if(teacherOptions[i].isCorrect){
        return teacherOptions[i];
      }
    }

    return null;
  }

  ExamOptionModel? getTeacherOptionByOrder(int order){
    for(int i = 0; i < teacherOptions.length; i++){
      if(teacherOptions[i].order == order){
        return teacherOptions[i];
      }
    }

    return null;
  }

  ExamOptionModel? getTeacherOptionById(String id){
    for(int i = 0; i< teacherOptions.length; i++){
      if(teacherOptions[i].id == id){
        return teacherOptions[i];
      }
    }

    return null;
  }

  ExamOptionModel? getUserOptionByOrder(int order){
    for(int i = 0; i < userAnswers.length; i++){
      if(userAnswers[i].order == order){
        return userAnswers[i];
      }
    }

    return null;
  }

  ExamOptionModel? getUserOptionById(String id){
    for(int i = 0; i < userAnswers.length; i++){
      if(userAnswers[i].id == id){
        return userAnswers[i];
      }
    }

    return null;
  }

  String getUserAnswerText(){
    if(quizType == QuizType.multipleChoice){
      if(userAnswers.isNotEmpty){
        return getTeacherOptionById(userAnswers[0].id)!.text;
      }

      return 'بدون پاسخ';
    }
    else if (quizType == QuizType.recorder){
      var txt = question;
      var order = 1;

      while(txt.contains('**')){
        final ans = getUserOptionByOrder(order)?.text?? '';

        txt = txt.replaceFirst('**', '[${ans.isEmpty? 'بدون پاسخ': ans}]');
        order++;
      }

      return txt;
    }
    else if (quizType == QuizType.fillInBlank){
      var txt = question;
      var order = 1;

      while(txt.contains('**')){
        final ans = getUserOptionByOrder(order)?.text?? '';

        txt = txt.replaceFirst('**', '[${ans.isEmpty? 'بدون پاسخ': ans}]');
        order++;
      }

      return txt;
    }

    return 'بدون پاسخ';
  }

  bool isUserAnswerCorrect(){
    if(quizType == QuizType.multipleChoice){
      if(userAnswers.isEmpty){
        return false;
      }

      return userAnswers[0].id == getCorrectOption()!.id;
    }
    else if (quizType == QuizType.recorder){
      for (final k in userAnswers) {
        if (k.id.isEmpty) {
          return false;
        }
      }

      for(int i=1; i <= teacherOptions.length; i++){
        final correctAnswer = getTeacherOptionByOrder(i)!.text;
        final userAnswer = getUserOptionByOrder(i)?.text;

        if(correctAnswer != userAnswer){
          return false;
        }
      }

      return true;
    }
    else if (quizType == QuizType.fillInBlank){
      for(int i = 1; i <= teacherOptions.length; i++){
        final correctAnswer = getTeacherOptionByOrder(i)?.text;
        final userAnswer = getUserOptionByOrder(i)?.text;

        if(correctAnswer != userAnswer){
          return false;
        }
      }

      return true;
    }

    return false;
  }

  bool isUserAnswer(){
    if(quizType == QuizType.multipleChoice){
      return userAnswers.isNotEmpty;
    }
    else if (quizType == QuizType.recorder){
      for (final k in userAnswers) {
        if (k.id.isEmpty) {
          return false;
        }
      }

      return true;
    }
    else if (quizType == QuizType.fillInBlank){
      for(int i = 1; i <= teacherOptions.length; i++){
        final userAnswer = getUserOptionByOrder(i)?.text;

        if(userAnswer == null){
          return false;
        }
      }

      return true;
    }

    return false;
  }

  @override
  String toString(){
    return '::ExamItem::[id:$id | question: $question | order:$order    | \n options: $teacherOptions]';
  }
}
///==================================================================================================
class ExamOptionModel {
  String id = '';
  String text = '';
  bool isCorrect = false;
  int order = 1;

  ExamOptionModel(): id = Generator.generateKey(5);

  ExamOptionModel.fromMap(Map js){
    id = js['id']?? Generator.generateKey(5);
    text = js['text'];
    isCorrect = js['isCorrect']?? false;
    order = js['order']?? 1;
  }

  Map<String, dynamic> toMap(){
    final js = <String, dynamic>{};

    js['id'] = id;
    js['text'] = text;
    js['isCorrect'] = isCorrect;
    js['order'] = order;

    return js;
  }

  @override
  String toString(){
    return '::ExamOption::[id: $id,  text: $text,  isCorrect: $isCorrect,  order:$order]';
  }
}
///==================================================================================================
class ExamOptionModelForMakeSentence extends ExamOptionModel {
  String quizId = '';
  String answer = '';

  ExamOptionModelForMakeSentence();

  ExamOptionModelForMakeSentence.fromMap(Map js): super.fromMap(js){
    quizId = js['quizId'];
    answer = js['answer'];
  }

  @override
  Map<String, dynamic> toMap(){
    final js = super.toMap();

    js['quizId'] = quizId;
    js['answer'] = answer;

    return js;
  }

  @override
  String toString(){
    return '::SolvedOption::[quizId: $quizId, answer: $answer, isCorrect: $isCorrect]';
  }
}
///=====================================================================================
class MakeSentenceExtra {
  late List<ExamItem> items;
  Map<String, List<ExamOptionModel>> selectedWords = {};
  Map<String, List<ExamOptionModel>> shuffleWords = {};
  int currentIndex = 0;

  MakeSentenceExtra(this.items){
    for(final x in items){
      final lis = x.teacherOptions.toList();
      lis.shuffle();

      selectedWords[x.id] = [];
      shuffleWords[x.id] = lis;
    }
  }

  List<ExamOptionModel> getShuffleForIndex({int? idx}){
    idx ??= currentIndex;

    if(shuffleWords.length > idx) {
      return shuffleWords.values.toList()[idx];
    }

    return [];
  }

  List<ExamOptionModel> getShuffleForId(String id){
    final f = shuffleWords[id];

    return f?? [];
  }

  List<ExamOptionModel> getSelectedWordsForIndex({int? idx}){
    idx ??= currentIndex;

    if(selectedWords.length > idx) {
      return selectedWords.values.toList()[idx];
    }

    return [];
  }

  List<ExamOptionModel> getSelectedWordsForId(String id){
    final f = selectedWords[id];

    return f?? [];
  }

  bool isSentenceFullByIndex({int? idx}){
    idx ??= currentIndex;

    if(selectedWords.length > idx) {
      return getSelectedWordsForIndex(idx: idx).length == getShuffleForIndex(idx: idx).length;
    }

    return false;
  }

  bool isSentenceFullById(String id){
    return getSelectedWordsForId(id).length == getShuffleForId(id).length;
  }

  bool hasAnswer(){
    return selectedWords.values.toList()[0].isNotEmpty;
  }

  void forward(){
    if(currentIndex < shuffleWords.length-1) {
      currentIndex++;
    }
  }

  void back(){
    final lis = getSelectedWordsForIndex();

    if(lis.isNotEmpty){
      lis.clear();
    }
    else {
      currentIndex--;

      if(currentIndex < 0){
        currentIndex = 0;
      }

      getSelectedWordsForIndex().clear();
    }
  }

  String joinUserAnswer() {
    String txt = '';

    for(int i =0; i < selectedWords.length; i++){
      final x = selectedWords.values.toList()[i];

      for(final x2 in x){
        txt += ' ${x2.text}';
      }

      if(x.length == getShuffleForIndex(idx: i).length) {
        if(!txt.endsWith('.')) {
          txt += '.';
        }
      }
    }

    return txt.trim();
  }

  String joinCorrectAnswer() {
    String txt = '';

    for(int i =0; i < items.length; i++){
      final x = items[i];

      for(final x2 in x.teacherOptions){
        txt += ' ${x2.text}';
      }

      if(!txt.endsWith('.')) {
        txt += '.';
      }
    }

    return txt.trim();
  }

  String joinUserAnswerById(String id) {
    String txt = '';
    final user = selectedWords[id]!.toList();

    if(user.isEmpty){
      return 'بدون پاسخ';
    }

    for(final w in user){
      txt += ' ${w.text}';
    }

    return txt.trim();
  }

  bool isCorrectAll(){
    for(int i =0; i < items.length; i++){
      final itm = items[i];
      final user = selectedWords.values.toList()[i];

      if(itm.teacherOptions.length != user.length){
        return false;
      }

      for(int j=0; j < itm.teacherOptions.length; j++){
        if(itm.teacherOptions[j].text != user[j].text){
          return false;
        }
      }
    }

    return true;
  }

  bool isCorrectById(String id){
    final user = getSelectedWordsForId(id);
    final itm = items.firstWhereSafe((elm) => elm.id == id);

    if(user.isEmpty || itm == null){
      return false;
    }

    for(int j=0; j < itm.teacherOptions.length; j++){
      if(itm.teacherOptions[j].text != user[j].text){
        return false;
      }
    }

    return true;
  }
}
