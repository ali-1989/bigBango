enum FileUploadType {
  unKnow(0),
  avatar(1),
  autodidact(2),
  ticket(3);

  final int _type;

  const FileUploadType(this._type);

  int number(){
    return _type;
  }

  static FileUploadType from(int type){
    for(final k in FileUploadType.values){
      if(k._type == type){
        return k;
      }
    }

    return FileUploadType.unKnow;
  }
}