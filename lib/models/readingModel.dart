import 'package:app/models/mediaModel.dart';
import 'package:flutter/material.dart';


class ReadingModel {
  String id = '';
  String title = '';
  String titleTranslation = '';
  int order = 0;
  MediaModel? media;
  List<SegmentOfReadingModel> segments = [];

  ///------------------------------------
  List<InlineSpan> spans = [];
  List<InlineSpan> spansTranslate = [];

  ReadingModel();

  ReadingModel.fromMap(Map map) {
    id = map['id'];
    title = map['title'];
    titleTranslation = map['translation']?? '';
    order = map['order']?? 0;

    final video = map['voice'];
    final segment = map['segments'];

    if(video != null) {
      media = MediaModel.fromMap(video);
    }

    if(segment is List) {
      for(final itm in segment){
        final s = SegmentOfReadingModel.fromMap(itm);
        segments.add(s);
      }
    }
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map['id'] = id;
    map['title'] = title;
    map['translation'] = titleTranslation;
    map['voice'] = media?.toMap();
    map['segments'] = segments.map((e) => e.toMap()).toList();

    return map;
  }

  void prepareSpans(int readIndex, TextStyle normalStyle, TextStyle readStyle){
    spans.clear();
    spansTranslate.clear();

    for(int i=0; i<segments.length; i++){
      final k = segments[i];

      final s = TextSpan(text: '${k.text} ', style: i == readIndex ? readStyle : normalStyle);
      final st = TextSpan(text: '${k.translation} ', style: i == readIndex ? readStyle : normalStyle);

      spans.add(s);
      spansTranslate.add(st);
    }
  }
}
///=====================================================================================
class SegmentOfReadingModel {
  String id = '';
  Duration? start;
  Duration? end;
  String? text;
  String? translation;

  SegmentOfReadingModel.fromMap(Map map) {
    id = map['id'];
    //start = Duration(milliseconds: ((DateHelper.tsToSystemDate('1970-01-01 ${map['start']}.0')?.millisecondsSinceEpoch)?? 0) +12600000);
    start = Duration(milliseconds: map['startMilliSeconds']);
    end = Duration(milliseconds: map['endMilliSeconds']);
    text = map['text'];
    translation = map['translation'];
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map['id'] = id;
    map['startMilliSeconds'] = start?.inMilliseconds;
    map['endMilliSeconds'] = end?.inMilliseconds;
    map['text'] = text;
    map['translation'] = translation;

    return map;
  }
}