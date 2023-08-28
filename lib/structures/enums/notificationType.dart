
enum NotificationType {
  unKnow(-1),
  ticket(1),
  timeTable(2),
  withdrawWallet(3),
  other(100);

  final int number;

  const NotificationType(this.number);

  factory NotificationType.from(dynamic numberOrString){
    if(numberOrString is String){
      return values.firstWhere((element) => element.name == numberOrString, orElse: ()=> unKnow);
    }

    if(numberOrString is int){
      return values.firstWhere((element) => element.number == numberOrString, orElse: ()=> unKnow);
    }

    return NotificationType.unKnow;
  }

  String getTypeHuman(){
    switch(number){
      case 1:
        return 'تیکت';
      case 2:
        return 'پشتیبان';
      case 3:
        return 'برداشت پول';
      case 100:
        return 'عمومی';
    }

    return 'ن م';
  }
}