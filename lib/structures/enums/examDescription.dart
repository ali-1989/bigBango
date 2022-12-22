enum ExamDescription {
  unKnow(-1),
  multipleChoice(1),
  fillInBlank(2),
  recorder(3);

  final int _type;

  const ExamDescription(this._type);

  int type(){
    return _type;
  }

  static ExamDescription from(int type){
    for(final v in ExamDescription.values){
      if(v._type == type){
        return v;
      }
  }

  return ExamDescription.unKnow;
  }

  String getText(){
    switch(_type){
      case 1:
        return 'گزینه ی مناسب را انتخاب کنید';
      case 2:
        return 'جای خالی را پر کنید';
      case 3:
        return 'کلمات را در جای مناسب قرار دهید';
    }

    return '';
  }
}