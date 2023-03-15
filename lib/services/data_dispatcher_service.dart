import 'dart:async';

import 'package:iris_tools/api/generator.dart';


typedef DataFunction<T> = void Function(T data);
///==============================================================================
class DataDispatcherService {
  static final Map<KeyDispatcher, List<DataFunction>> _functions = {};
  static final Map<KeyDispatcher, StreamController<dynamic>> _streams = {};

  DataDispatcherService._();

  static void attachFunction(KeyDispatcher key, DataFunction func){
    if(!_functions.containsKey(key)){
      _functions[key] = <DataFunction>[];
    }

    if(_functions[key]!.contains(func)){
      return;
    }

    _functions[key]?.add(func);
  }

  static void deAttachFunction(KeyDispatcher key, DataFunction func){
    if(!_functions.containsKey(key)){
      return;
    }

    if(_functions[key]!.remove(func)){
      return;
    }
  }

  static Stream<dynamic> getStream(KeyDispatcher key){
    if(!_streams.containsKey(key)){
      _streams[key] = StreamController.broadcast();
    }

    return _streams[key]!.stream;
  }

  static notify(KeyDispatcher key, dynamic data){
    for (final ef in _functions.entries) {
      if (ef.key == key) {
        for (final f in ef.value) {
          try {
            f.call(data);
          }
          catch (e) {
            /**/
          }
        }
        break;
      }
    }

    for(final ef in _streams.entries){
      if(ef.key == key){
        try{
          ef.value.sink.add(data?? Generator.getRandomInt(10, 9999));
        }
        catch(e){/**/}
        break;
      }
    }
  }

  static notifyFor(List<KeyDispatcher> keys, dynamic data){
    for(final k in keys){
      notify(k, data);
    }
  }
}
///==============================================================================
abstract class KeyDispatcher {
  
}
