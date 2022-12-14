enum QuizType {
  unKnow(-1),
  multipleChoice(1),
  fillInBlank(2),
  recorder(3);

  final int _type;

  const QuizType(this._type);

  int type(){
    return _type;
  }

  static QuizType from(int type){
    for(final v in QuizType.values){
      if(v._type == type){
        return v;
      }
    }

    return QuizType.unKnow;
  }
}