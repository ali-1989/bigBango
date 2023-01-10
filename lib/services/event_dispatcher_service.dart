
import 'dart:async';

import 'package:iris_tools/api/generator.dart';

typedef EventFunction = void Function();
///==============================================================================
class EventDispatcherService {
  static final Map<EventDispatcher, List<EventFunction>> _functions = {};
  static final Map<EventDispatcher, StreamController<int>> _streams = {};

  EventDispatcherService._();

  static void attachFunction(EventDispatcher event, EventFunction func){
    if(!_functions.containsKey(event)){
      _functions[event] = <EventFunction>[];
    }

    if(_functions[event]!.contains(func)){
      return;
    }

    _functions[event]?.add(func);
  }

  static void deAttachFunction(EventDispatcher event, EventFunction func){
    if(!_functions.containsKey(event)){
      return;
    }

    if(_functions[event]!.remove(func)){
      return;
    }
  }

  static Stream<int> getStream(EventDispatcher event){
    if(!_streams.containsKey(event)){
      _streams[event] = StreamController.broadcast();
    }

    return _streams[event]!.stream;
  }

  static notify(EventDispatcher event){
    for(final ef in _functions.entries){
      if(ef.key == event){
        for(final f in ef.value){
          try{
            f.call();
          }
          catch(e){/**/}
        }
        break;
      }
    }

    for(final ef in _streams.entries){
      if(ef.key == event){
        try{
          ef.value.sink.add(Generator.getRandomInt(10, 9999));
        }
        catch(e){/**/}
        break;
      }
    }
  }

  static notifyFor(List<EventDispatcher> events){
    for(final e in events){
      notify(e);
    }
  }
}
///==============================================================================
enum EventDispatcher {
  networkConnected(100),
  networkDisConnected(101),
  networkStateChange(102),
  userProfileChange(103);

  final int _number;

  const EventDispatcher(this._number);
}