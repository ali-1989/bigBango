import 'dart:collection';
import 'dart:core' as core;
import 'dart:core';


class StackList<T> {
  final ListQueue<T> _list = ListQueue();
  final int noLimit = -1;

  /// the maximum number of entries allowed on the stack. -1 = no limit.
  int _sizeMax = 0;

  StackList() {
    _sizeMax = noLimit;
  }

  StackList.sized(int sizeMax) {
    if(sizeMax < 2) {
      throw Exception(
          'Error: stack size must be 2 entries or more '
      );
    }
    else {
      _sizeMax = sizeMax;
    }
  }

  bool get isEmpty => _list.isEmpty;

  bool get isNotEmpty => _list.isNotEmpty;

  int get length => _list.length;

  void push(T e) {
    if(_sizeMax == noLimit || _list.length < _sizeMax) {
      _list.addLast(e);
    }
    else {
      throw Exception(
          'Error: cannot add element. Stack already at maximum size of: $_sizeMax elements');
    }
  }

  T pop() {
    if (isEmpty) {
      throw Exception(
        'Can\'t use pop with empty stack\n consider '
            'checking for size or isEmpty before calling pop',
      );
    }

    T res = _list.last;
    _list.removeLast();

    return res;
  }

  T? popUntil(T until) {
    if (isNotEmpty) {
      T res = _list.last;

      while(res != until && _list.isNotEmpty){
        _list.removeLast();
        res = _list.last;
      }

      if(res == until) {
        return res;
      }
    }

    return null;
  }

  T top() {
    if (isEmpty) {
      throw Exception(
        'Can\'t use top with empty stack\n consider '
            'checking for size or isEmpty before calling top',
      );
    }

    return _list.last;
  }

  bool contains(T x) {
    return _list.contains(x);
  }

  void clear() {
    while (isNotEmpty) {
      _list.removeLast();
    }
  }

  List<T> toList() => _list.toList();

  /*void print() {
    for (var item in List<T>.from(_list).reversed) {
      core.print(item);
    }
  }*/
}