
enum WalletAmountType {
  unKnow(-1),
  removable(1),
  unermovable(2);

  final int number;

  const WalletAmountType(this.number);

  static WalletAmountType fromType(int num){
    for(final x in WalletAmountType.values){
      if(x.number == num){
        return x;
      }
    }

    return WalletAmountType.unKnow;
  }

  static WalletAmountType fromName(String name){
    for(final x in WalletAmountType.values){
      if(x.name == name){
        return x;
      }
    }

    return WalletAmountType.unKnow;
  }

  String getTypeHuman(){
    switch(number){
      case 1:
        return 'قابل برداشت';
      case 2:
        return 'غیرقابل برداشت';
    }

    return 'ن م';
  }
}