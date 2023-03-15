
/*
  Usage:
    static final StateNotifier<MessageStateStructure, Map> messageNotifier = StateNotifier(MessageManager.messageStateStructure);
    class MessageStateStructure<String> extends StateHolder<String> {}
    OR
    static final StateNotifier<StateHolder, Map> messageNotifier = StateNotifier(MessageManager.messageStateStructure);
    static final StateNotifier messageNotifier = StateNotifier(MessageManager.messageStateStructure);
 */


typedef StateListenerFunction<T> = void Function(StateNotifier notifier, {T? data});
///==============================================================================
class StateNotifier<SH extends StateHolder, T> {
  late final SH states;
  final Map<String, dynamic> stores = {};
  final List<StateListenerFunction<T>> _functions = [];

  StateNotifier(this.states);

  void addListener(StateListenerFunction<T> func){
    if(!_functions.contains(func)){
      _functions.add(func);
    }
  }

  void removeListener(StateListenerFunction func){
    _functions.remove(func);
  }

  void clearListeners(){
    _functions.clear();
  }

  void notify({Set states = const {}, T? data}){
    this.states._states.addAll(states);

    for(final ef in _functions){
      try{
        ef.call(this, data: data);
      }
      catch (e){}
    }
  }

  void addValue(String key, dynamic value){
    stores[key] = value;
  }

  void removeValue(String key){
    stores.remove(key);
  }

  dynamic getValue(String key){
    if(existKey(key)) {
      return stores[key];
    }

    return null;
  }

  bool existKey(String key){
    return stores.containsKey(key);
  }

  void clearValues(){
    stores.clear();
  }
}
///=============================================================================
abstract class StateHolder<S> {
  final Set<S> _states = {};

  Set<S> getStates(){
    return _states;
  }

  void addState(S state){
    _states.add(state);
  }

  void addStates(Set<S> states){
    _states.addAll(states);
  }

  void removeState(S state){
    _states.remove(state);
  }

  bool hasState(S state){
    return _states.contains(state);
  }

  bool hasStates(Set<S> states){
    for(final x in states){
      if(!_states.contains(x)){
        return false;
      }
    }

    return true;
  }
}