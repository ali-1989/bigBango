enum AutodidactReplyType {
  unKnow(-1),
  text(1),
  voice(2);

  final int number;

  const AutodidactReplyType(this.number);

  static AutodidactReplyType fromType(int type){
    for(final v in AutodidactReplyType.values){
      if(v.number == type){
        return v;
      }
    }

    return AutodidactReplyType.unKnow;
  }

  static AutodidactReplyType fromName(String name){
    for(final v in AutodidactReplyType.values){
      if(v.name == name){
        return v;
      }
    }

    return AutodidactReplyType.unKnow;
  }
}