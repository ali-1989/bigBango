
class Clone {
  Clone._();

  static dynamic clone<T>(dynamic obj){
    if(obj is List){
      return listDeepCopy(obj).map((e) => e as T).toList();
    }

    if(obj is Set){
      return setDeepCopy(obj) as T;
    }

    if(obj is Map){
      return mapDeepCopy(obj) as T;
    }

    return null;
  }

  static List<T> listDeepCopy<T>(List list){
    final newList = <T>[];

    for (final itm in list) {
      newList.add(
          itm is Map ? mapDeepCopy(itm) :
          itm is List ? listDeepCopy(itm) :
          itm is Set ? setDeepCopy(itm) : itm
      );
    }

    return newList;
  }

  static Set<T> setDeepCopy<T>(Set orgSet){
    final newSet = <T>{};

    for (final itm in orgSet) {
      newSet.add(
          itm is Map ? mapDeepCopy(itm) :
          itm is List ? listDeepCopy(itm) :
          itm is Set ? setDeepCopy(itm) :
          itm
      );
    }

    return newSet;
  }

  static Map<K,V> mapDeepCopy<K,V>(Map map){
    final newMap = <K,V>{};

    map.forEach((key, value){
      newMap[key] = (
      value is Map ? mapDeepCopy(value) :
      value is List ? listDeepCopy(value) :
      value is Set ? setDeepCopy(value) :
      value
      ) /*as V*/;
    });

    return newMap;
  }
}