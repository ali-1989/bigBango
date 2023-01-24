
enum GenderType {
  unKnow(-1),
  woman(0),
  man(1);

  final int number;

  const GenderType(this.number);

  static GenderType fromType(int num){
    for(final x in GenderType.values){
      if(x.number == num){
        return x;
      }
    }

    return GenderType.unKnow;
  }

  static GenderType fromName(String name){
    for(final x in GenderType.values){
      if(x.name == name){
        return x;
      }
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