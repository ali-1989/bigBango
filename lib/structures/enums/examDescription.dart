enum ExamDescription {
  unKnow(-1),
  multipleChoice(1),
  fillInBlank(2),
  recorder(3);

  final int number;

  const ExamDescription(this.number);

  factory ExamDescription.from(dynamic numberOrString){
    if(numberOrString is String){
      return values.firstWhere((element) => element.name == numberOrString, orElse: ()=> unKnow);
    }

    if(numberOrString is int){
      return values.firstWhere((element) => element.number == numberOrString, orElse: ()=> unKnow);
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