enum QuizType {
  unKnow(-1),
  multipleChoice(1),
  fillInBlank(2),
  recorder(3),
  makeSentence(4);

  final int number;

  const QuizType(this.number);

  static QuizType fromType(int type){
    for(final v in QuizType.values){
      if(v.number == type){
        return v;
      }
    }

    return QuizType.unKnow;
  }

  static QuizType fromName(String name){
    for(final v in QuizType.values){
      if(v.name == name){
        return v;
      }
    }

    return QuizType.unKnow;
  }
}