
enum MessageStatus {
  unKnow(-1),
  unRead(1),
  read(2);

  final int number;

  const MessageStatus(this.number);

  factory MessageStatus.from(dynamic numberOrString){
    if(numberOrString is String){
      return values.firstWhere((element) => element.name == numberOrString, orElse: ()=> unKnow);
    }

    if(numberOrString is int){
      return values.firstWhere((element) => element.number == numberOrString, orElse: ()=> unKnow);
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