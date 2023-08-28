
enum GenderType {
  unKnow(-1),
  woman(0),
  man(1);

  final int number;

  const GenderType(this.number);

  factory GenderType.from(dynamic numberOrString){
    if(numberOrString is String){
      return values.firstWhere((element) => element.name == numberOrString, orElse: ()=> unKnow);
    }

    if(numberOrString is int){
      return values.firstWhere((element) => element.number == numberOrString, orElse: ()=> unKnow);
    }

    return GenderType.unKnow;
  }

  String getTypeHuman(){
    switch(number){
      case -1:
        return 'نامشخص';
      case 0:
        return 'زن';
      case 1:
        return 'مرد';
    }

    return 'ن م';
  }
}