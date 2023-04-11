
//return SizedBox(width: 100, height: 100, child: ColoredBox(color: ColorHelper.getRandomRGB()));

class IrisRuntimeStore {
  static final List<RuntimeKv> _list = [];

  IrisRuntimeStore._();

  static bool store(RuntimeKv kv){
    if(find(kv.scope, kv.key) == null) {
      _list.add(kv);
      return true;
    }

    return false;
  }

  static bool storeWith<K, V>(RuntimeScope scope, K key, V value){
    final rt = RuntimeKv<K, V>(scope, key);
    rt.value = value;

    return store(rt);
  }

  static bool storeOrUpdate<K, V>(RuntimeScope scope, K key, V value, {Duration? updateDuration}){
    RuntimeKv? rt;

    rt = find(scope, key);

    if(rt != null){
      rt.value = value;
      return true;
    }

    rt = RuntimeKv<K, V>(scope, key);
    rt.value = value;
    rt.updateDuration = updateDuration;

    return store(rt);
  }

  static RuntimeKv? find(RuntimeScope scope, dynamic key){
    for(final itm in _list){
      if(itm.scope == scope && itm.key == key){
        return itm;
      }
    }

    return null;
  }

  static void remove(RuntimeKv kv){
    _list.removeWhere((element) {
      return element.scope == kv.scope && element.key == kv.key;
    });
  }

  static void removeBy(RuntimeScope scope, dynamic key){
    _list.removeWhere((element) {
      return element.scope == scope && element.key == key;
    });
  }

  static bool isUpdate(RuntimeScope scope, dynamic key, {Duration? duration, bool defaultResult = false}){
    final kv = find(scope, key);

    if(kv != null){
      if(duration != null){
        return kv.isUpdateFrom(duration);
      }

      return kv.isUpdate();
    }

    return defaultResult;
  }

  static void resetUpdateTime(RuntimeScope scope, dynamic key){
    final kv = find(scope, key);

    if(kv != null){
      kv.resetUpdateTime();
    }
  }
}

///==========================================
class RuntimeScope {}
///==========================================
class RuntimeKv<K,V> {
  late RuntimeScope scope;
  late K key;
  V? _value;
  DateTime? lastUpdate;
  Duration? updateDuration;

  RuntimeKv(this.scope, this.key);

  RuntimeKv.fill(this.scope, this.key, V value, {this.lastUpdate, this.updateDuration}) : _value = value {
    lastUpdate = DateTime.now();
  }

  set value(V? value){
    _value = value;
    lastUpdate = DateTime.now();
  }

  V? get value => _value;

  bool isUpdateFrom(Duration duration){
    return lastUpdate != null && lastUpdate!.add(duration).isAfter(DateTime.now());
  }

  bool isUpdate(){
    if(updateDuration == null){
      return false;
    }

    return lastUpdate != null && lastUpdate!.add(updateDuration!).isAfter(DateTime.now());
  }

  void resetUpdateTime(){
    lastUpdate = null;
  }

  void changeUpdateTime(DateTime dt){
    lastUpdate = dt;
  }
}