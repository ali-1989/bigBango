
enum NotificationType {
  unKnow(-1),
  paid(1),
  cancelled(2);

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
        return 'پرداخت نشده';
      case 2:
        return 'پرداخت شده';
    }

    return 'ن م';
  }
}