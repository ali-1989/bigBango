enum QuizType {
  unKnow(-1),
  multipleChoice(1),
  fillInBlank(2),
  recorder(3),
  makeSentence(4);

  final int number;

  const QuizType(this.number);

  factory QuizType.from(dynamic numberOrString){
    if(numberOrString is String){
      return values.firstWhere((element) => element.name == numberOrString, orElse: ()=> unKnow);
    }

    if(numberOrString is int){
      return values.firstWhere((element) => element.number == numberOrString, orElse: ()=> unKnow);
    }

    return QuizType.unKnow;
  }
}