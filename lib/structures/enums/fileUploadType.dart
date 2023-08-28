enum FileUploadType {
  unKnow(-1),
  avatar(1),
  autodidact(2),
  ticket(3);

  final int number;

  const FileUploadType(this.number);

  factory FileUploadType.from(dynamic numberOrString){
    if(numberOrString is String){
      return values.firstWhere((element) => element.name == numberOrString, orElse: ()=> unKnow);
    }

    if(numberOrString is int){
      return values.firstWhere((element) => element.number == numberOrString, orElse: ()=> unKnow);
    }

    return FileUploadType.unKnow;
  }
}