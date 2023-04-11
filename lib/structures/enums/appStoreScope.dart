import 'package:app/irisRuntimeStore.dart';

enum AppStoreScope implements RuntimeScope {
  user$supportTime(100),
  languageLevelChanged(130);

  final int _number;

  const AppStoreScope(this._number);

  int getNumber(){
    return _number;
  }
}
