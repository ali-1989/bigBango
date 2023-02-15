
enum NotificationType {
  unKnow(-1),
  ticket(1),
  timeTable(2),
  withdrawWallet(3),
  other(100);

  final int number;

  const NotificationType(this.number);

  static NotificationType fromType(int num){
    for(final x in NotificationType.values){
      if(x.number == num){
        return x;
      }
    }

    return NotificationType.unKnow;
  }

  static NotificationType fromName(String name){
    for(final x in NotificationType.values){
      if(x.name == name){
        return x;
      }
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