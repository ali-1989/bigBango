import 'package:url_launcher/url_launcher.dart';

class UriTools {
  UriTools._();

  static String addHttpIfNeed(String? path){
    if(path == null) {
      return '';
    }

    if(path.contains('http')) {
      return path;
    }

    return 'http://$path';
  }

  static Future<bool> openUrl(String link) async {
    if (await canLaunchUrl(Uri.parse(link))) {
      return launchUrl(Uri.parse(link));
    }
    else {
      throw 'Could not launch $link';
    }
  }
}
