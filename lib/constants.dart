
class Constants {
  Constants._();

  /// used for (app folder, send to server)
  static const appName = 'BigBango';
  /// used for (app title)
  static String appTitle = 'Big Bango';
  static final _major = 0;         //match by pubspec.yaml
  static final _minor = 0;
  static final _patch = 1;

  static String appVersionName = '$_major.$_minor.$_patch';
  static int appVersionCode = _major *10000 + _minor *100 + _patch;
}
