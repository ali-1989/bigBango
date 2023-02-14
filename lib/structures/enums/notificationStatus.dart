
enum NotificationStatus {
  unKnow(-1),
  paid(1),
  cancelled(2);

  final int number;

  const NotificationStatus(this.number);

  static NotificationStatus fromType(int num){
    for(final x in NotificationStatus.values){
      if(x.number == num){
        return x;
      }
    }

    return NotificationStatus.unKnow;
  }

  static NotificationStatus fromName(String name){
    for(final x in NotificationStatus.values){
      if(x.name == name){
        return x;
      }
    }

    return NotificationStatus.unKnow;
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