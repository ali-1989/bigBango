
class Constants {
  Constants._();

  /// used for (app folder, send to server)
  static const appName = 'BigBango';
  /// used for (app title)
  static String appTitle = 'Big Bango';
  static const _major = 1;
  static const _minor = 0;
  static const _patch = 4;

  static String appVersionName = '$_major.$_minor.$_patch';
  static int appVersionCode = _major *10000 + _minor *100 + _patch;
}
