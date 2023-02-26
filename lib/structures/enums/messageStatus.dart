
enum MessageStatus {
  unKnow(-1),
  unRead(1),
  read(2);

  final int number;

  const MessageStatus(this.number);

  static MessageStatus fromType(int num){
    for(final x in MessageStatus.values){
      if(x.number == num){
        return x;
      }
    }

    return MessageStatus.unKnow;
  }

  static MessageStatus fromName(String name){
    for(final x in MessageStatus.values){
      if(x.name == name){
        return x;
      }
    }

    return MessageStatus.unKnow;
  }

  String getTypeHuman(){
    switch(number){
      case 1:
        return 'خوانده نشده';
      case 2:
        return 'خوانده شده';
    }

    return 'ن م';
  }
}