enum ExamDescription {
  unKnow(-1),
  multipleChoice(1),
  fillInBlank(2),
  recorder(3);

  final int number;

  const ExamDescription(this.number);

  static ExamDescription fromType(int type){
    for(final v in ExamDescription.values){
      if(v.number == type){
        return v;
      }
  }

  return ExamDescription.unKnow;
  }

  static ExamDescription fromName(String name){
    for(final v in ExamDescription.values){
      if(v.name == name){
        return v;
      }
    }

    return ExamDescription.unKnow;
  }

  String getTypeHuman(){
    switch(number){
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