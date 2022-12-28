enum AutodidactReplyType {
  unKnow(-1),
  text(1),
  voice(2);

  final int _type;

  const AutodidactReplyType(this._type);

  int type(){
    return _type;
  }

  static AutodidactReplyType from(int type){
    for(final v in AutodidactReplyType.values){
      if(v._type == type){
        return v;
      }
    }

    return AutodidactReplyType.unKnow;
  }
}