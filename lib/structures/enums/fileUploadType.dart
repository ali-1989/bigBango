enum FileUploadType {
  unKnow(-1),
  avatar(1),
  autodidact(2),
  ticket(3);

  final int number;

  const FileUploadType(this.number);

  static FileUploadType fromType(int type){
    for(final k in FileUploadType.values){
      if(k.number == type){
        return k;
      }
    }

    return FileUploadType.unKnow;
  }

  static FileUploadType fromName(String name){
    for(final k in FileUploadType.values){
      if(k.name == name){
        return k;
      }
    }

    return FileUploadType.unKnow;
  }
}